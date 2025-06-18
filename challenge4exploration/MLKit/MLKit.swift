//
//  MLKit.swift
//  challenge4exploration
//
//  Created by Ahmad Zuhal Zhafran on 05/06/25.
//

import SwiftUI
import PencilKit
import CoreML
import Vision
import UIKit

struct MLKit: View {
    @State private var canvasView = PKCanvasView()
    @State private var currentObject = ""
    @State private var predictionResult = ""
    @State private var confidence: Float = 0.0
    @State private var showResult = false
    @State private var isAnalyzing = false
    
    // List objek yang harus digambar
    private let objects = [
        "key", "ice cream", "shorts", "hand", "fish", 
        "van", "hamburger", "alarm clock", "candle", "grapes"
    ]
    
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
        VStack {
                Text("🎨 Drawing Challenge")
                .font(.largeTitle)
                .fontWeight(.bold)
                
                Text("Draw the object below and let AI guess!")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            // Current object to draw
            VStack {
                Text("Draw this:")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(currentObject.uppercased())
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(15)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            // Canvas for drawing
            VStack {
                Text("Drawing Area")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                CanvasView(canvasView: $canvasView)
                    .frame(width: 299, height: 299)
                    .background(Color.white)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(radius: 5)
            }
            .padding(.horizontal)
            
            // Control buttons
            HStack(spacing: 20) {
                Button("🎲 New Challenge") {
                    generateNewChallenge()
                }
                .buttonStyle(CustomButtonStyle(color: .green))
                
                Button("🗑️ Clear") {
                    clearCanvas()
                }
                .buttonStyle(CustomButtonStyle(color: .orange))
                
                Button("🤖 Analyze") {
                    analyzeDrawing()
                }
                .buttonStyle(CustomButtonStyle(color: .blue))
                .disabled(isAnalyzing)
            }
            .padding(.horizontal)
            
            // Loading indicator
            if isAnalyzing {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Analyzing your drawing...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            // Results
            if showResult {
                VStack(spacing: 10) {
                    Text("🎯 AI Prediction Result")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Target:")
                                .fontWeight(.semibold)
                            Text(currentObject)
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text("AI Guess:")
                                .fontWeight(.semibold)
                            Text(predictionResult.isEmpty ? "Unknown" : predictionResult)
                                .foregroundColor(.purple)
                        }
                        
                        HStack {
                            Text("Confidence:")
                                .fontWeight(.semibold)
                            Text("\(Int(confidence * 100))%")
                                .foregroundColor(confidence > 0.7 ? .green : confidence > 0.4 ? .orange : .red)
                                .fontWeight(.bold)
                        }
                        
                        // Accuracy assessment
                        let isCorrect = predictionResult.lowercased().contains(currentObject.lowercased()) || 
                                       currentObject.lowercased().contains(predictionResult.lowercased())
                        
                        HStack {
                            Text("Result:")
                                .fontWeight(.semibold)
                            Text(isCorrect ? "✅ Correct!" : "❌ Try Again")
                                .foregroundColor(isCorrect ? .green : .red)
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .transition(.scale.combined(with: .opacity))
            }
            
            Spacer()
        }
        .onAppear {
            setupCanvas()
            generateNewChallenge()
        }
        .animation(.easeInOut(duration: 0.3), value: showResult)
        .animation(.easeInOut(duration: 0.3), value: isAnalyzing)
    }
    
    // MARK: - Functions
    
    private func setupCanvas() {
        print("[MLKit] 🎨 Setting up canvas...")
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 4)
        canvasView.backgroundColor = UIColor.white
        canvasView.frame = CGRect(x: 0, y: 0, width: 299, height: 299)
        print("[MLKit] ✅ Canvas setup completed")
    }
    
    private func generateNewChallenge() {
        let newObject = objects.randomElement() ?? "key"
        print("[MLKit] 🎲 Generating new challenge...")
        print("[MLKit] 📝 New object to draw: \(newObject)")
        currentObject = newObject
        clearCanvas()
        hideResult()
        print("[MLKit] ✅ New challenge ready!")
    }
    
    private func clearCanvas() {
        print("[MLKit] 🗑️ Clearing canvas...")
        canvasView.drawing = PKDrawing()
        hideResult()
        print("[MLKit] ✅ Canvas cleared")
    }
    
    private func hideResult() {
        print("[MLKit] 👁️ Hiding previous results...")
        showResult = false
        predictionResult = ""
        confidence = 0.0
        print("[MLKit] ✅ Results hidden")
    }
    
    private func analyzeDrawing() {
        print("[MLKit] 🤖 Starting analysis...")
        print("[MLKit] 📏 Drawing bounds: \(canvasView.drawing.bounds)")
        
//        guard !canvasView.drawing.bounds.isEmpty else {
//            print("[MLKit] ⚠️ Warning: Drawing is empty!")
//            predictionResult = "Please draw something first!"
//            confidence = 0.0
//            showResult = true
//            return
//        }
        
        print("[MLKit] ✅ Drawing detected, proceeding with analysis")
        isAnalyzing = true
        hideResult()
        
        // Convert drawing to image with white background
        print("[MLKit] 🖼️ Converting drawing to image with white background...")
        let originalImage = createImageWithWhiteBackground(from: canvasView.drawing)
        print("[MLKit] 📐 Original image size: \(originalImage.size)")
        
        // Export original image for debugging
        exportImageForDebugging(originalImage, objectName: currentObject, suffix: "_original")
        
        // Perform ML prediction with original size
        print("[MLKit] 🧠 Starting ML prediction with original size on background thread...")
        DispatchQueue.global(qos: .userInitiated).async {
            performMLPrediction(on: originalImage)
        }
    }
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        print("[MLKit] 🎨 Resizing image from \(image.size) to \(targetSize)")
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: CGSize(width: 299, height: 299)))
        }
        print("[MLKit] ✅ Image resize completed")
        return resizedImage
    }
    
//    private func performMLPrediction(on image: UIImage) {
//        print("[MLKit] 🏗️ Loading CoreML model...")
//        
//        // Load model directly without Vision wrapper first
//        guard let mlModel = try? ImageDetectorDoodle(configuration: MLModelConfiguration()) else {
//            print("[MLKit] ❌ Error: Failed to load ImageDetectorDoodle model")
//            DispatchQueue.main.async {
//                self.predictionResult = "Model loading failed"
//                self.confidence = 0.0
//                self.showResult = true
//                self.isAnalyzing = false
//            }
//            return
//        }
//        
//        print("[MLKit] ✅ CoreML model loaded successfully")
//        
//        // Convert UIImage to CVPixelBuffer
//        print("[MLKit] 🔄 Converting UIImage to CVPixelBuffer...")
//        guard let pixelBuffer = convertToPixelBuffer(image: image) else {
//            print("[MLKit] ❌ Error: Failed to convert UIImage to CVPixelBuffer")
//            DispatchQueue.main.async {
//                self.predictionResult = "Image conversion to CVPixelBuffer failed"
//                self.confidence = 0.0
//                self.showResult = true
//                self.isAnalyzing = false
//            }
//            return
//        }
//        
//        print("[MLKit] ✅ CVPixelBuffer created successfully")
//        
//        // Export CVPixelBuffer as image for debugging
//        if let debugImage = convertPixelBufferToUIImage(pixelBuffer: pixelBuffer) {
//            DispatchQueue.main.async {
//                self.exportImageForDebugging(debugImage, objectName: self.currentObject, suffix: "_cvpixelbuffer")
//            }
//        }
//        
//        print("[MLKit] 🎯 Performing direct CoreML prediction...")
//        
//        do {
//            // Perform prediction directly with CoreML model
//            let prediction = try mlModel.prediction(image: pixelBuffer)
//            print("[MLKit] ✅ ML prediction completed successfully")
//            
//            // Process the prediction result
//            DispatchQueue.main.async {
//                self.processDirectMLResults(prediction: prediction)
//            }
//            
//        } catch {
//            print("[MLKit] ❌ Error during direct CoreML prediction: \(error.localizedDescription)")
//            
//            // Fallback to Vision framework approach
//            print("[MLKit] 🔄 Trying fallback with Vision framework...")
//            self.performVisionBasedPrediction(on: image)
//        }
//    }
    

    /// Compiles a .mlmodel in the app bundle and returns the compiled modelimport CoreML
//    import Vision
//    import UIKit

    private func performMLPrediction(on image: UIImage) {
        print("[MLKit] 🏗️ Loading and compiling CoreML model...")


        do {
            guard let mlModel = try? ImageDetectorDoodle(configuration: MLModelConfiguration()) else {
                return
            }
            
            print("[MLKit] ✅ Model compiled and loaded")
            
            guard
                let pixelBuffer = convertToPixelBuffer(
                    image: image)
            else {
                print("Error on converting UIImage to CVPixelBuffer")
            }

        } catch {
            print("[MLKit] ❌ Compilation or model error: \(error.localizedDescription)")
            self.predictionResult = "Model load error"
            self.confidence = 0.0
            self.isAnalyzing = false
        }
    }


    
    private func convertToPixelBuffer(image: UIImage) -> CVPixelBuffer? {
        // Use original image size (no resize)
        let originalSize = CGSize(width: 299, height: 299)
        print("[MLKit] 🎨 Creating CVPixelBuffer with original size: \(originalSize)")
        
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            299,
            299,
            kCVPixelFormatType_32BGRA,
            attrs,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            print("[MLKit] ❌ CVPixelBufferCreate failed with status: \(status)")
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        defer { CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0)) }
        
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let context = CGContext(
            data: pixelData,
            width: 299,
            height: 299,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            print("[MLKit] ❌ Failed to create CGContext")
            return nil
        }
        
        // Fill with white background first (important for doodles)
        print("[MLKit] ⚪ Filling CVPixelBuffer with white background...")
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: originalSize))
        
        // Draw the image (already has white background from createImageWithWhiteBackground)
        if let cgImage = image.cgImage {
            context.draw(cgImage, in: CGRect(origin: .zero, size: originalSize))
            print("[MLKit] ✅ Image drawn to CVPixelBuffer with white background")
        }
        
        print("[MLKit] ✅ CVPixelBuffer conversion completed")
        return buffer
    }
//    
//    private func processDirectMLResults(prediction: ImageDetectorDoodleOutput) {
//        print("[MLKit] 📊 Processing direct CoreML results...")
//        self.isAnalyzing = false
//        
//        // Get target probability dictionary
//        let targetProbability = prediction.targetProbability
//        print("[MLKit] 📊 Raw targetProbability: \(targetProbability)")
//        
//        // Find the highest prediction
//        let sortedPredictions = targetProbability.sorted { $0.value > $1.value }
//        
//        // Log all predictions for debugging
//        print("[MLKit] 📋 All predictions (sorted by confidence):")
//        for (index, (className, probability)) in sortedPredictions.enumerated() {
//            print("[MLKit] Result \(index + 1): \(className) - \(String(format: "%.2f", probability * 100))%")
//        }
//        
//        // Get top prediction
//        guard let topPrediction = sortedPredictions.first else {
//            print("[MLKit] ❌ Error: No predictions found")
//            self.predictionResult = "No predictions available"
//            self.confidence = 0.0
//            self.showResult = true
//            return
//        }
//        
//        let topClassName = topPrediction.key
//        let topConfidence = topPrediction.value
//        
//        print("[MLKit] 🏆 Top prediction: \(topClassName)")
//        print("[MLKit] 📈 Top confidence: \(String(format: "%.2f", topConfidence * 100))%")
//        print("[MLKit] 🎯 Target object: \(currentObject)")
//        
//        // Get confidence for the current target object
//        let normalizedCurrentObject = currentObject.lowercased().replacingOccurrences(of: " ", with: "_")
//        var targetConfidence: Double = 0.0
//        var foundTarget = false
//        
//        // Check different possible formats of the target object
//        let possibleKeys = [
//            currentObject,                                          // exact match
//            currentObject.lowercased(),                            // lowercase
//            normalizedCurrentObject,                               // with underscore
//            currentObject.replacingOccurrences(of: " ", with: "_") // original with underscore
//        ]
//        
//        for key in possibleKeys {
//            if let confidence = targetProbability[key] {
//                targetConfidence = confidence
//                foundTarget = true
//                print("[MLKit] ✅ Found target '\(currentObject)' as key '\(key)' with confidence: \(String(format: "%.2f", targetConfidence * 100))%")
//                break
//            }
//        }
//        
//        if !foundTarget {
//            print("[MLKit] ⚠️ Warning: Target object '\(currentObject)' not found in predictions")
//            print("[MLKit] 🔍 Available keys: \(Array(targetProbability.keys))")
//        }
//        
//        // Check if prediction matches target (either top prediction is correct OR target has high confidence)
//        let isTopPredictionCorrect = topClassName.lowercased().contains(currentObject.lowercased()) || 
//                                   currentObject.lowercased().contains(topClassName.lowercased())
//        
//        let isTargetConfident = targetConfidence > 0.5 // 50% threshold
//        let isCorrect = isTopPredictionCorrect || (foundTarget && isTargetConfident)
//        
//        print("[MLKit] 🎯 Target object confidence: \(String(format: "%.2f", targetConfidence * 100))%")
//        print("[MLKit] ✅ Is prediction correct? \(isCorrect ? "YES" : "NO")")
//        
//        if isTopPredictionCorrect {
//            print("[MLKit] 🎉 Top prediction matches target!")
//        } else if foundTarget && isTargetConfident {
//            print("[MLKit] 🎉 Target object has high confidence!")
//        }
//        
//        // Set results for UI display
//        self.predictionResult = topClassName
//        self.confidence = Float(max(topConfidence, targetConfidence)) // Use higher confidence
//        self.showResult = true
//        
//        print("[MLKit] 🎉 Results displayed to user!")
//    }
    
    // MARK: - Image Processing Functions
    
    private func createImageWithWhiteBackground(from drawing: PKDrawing) -> UIImage {
        print("[MLKit] 🎨 Creating image with white background from full canvas...")
        
        // Use full canvas size instead of drawing bounds
        let canvasFrame = canvasView.frame
        let canvasSize = CGSize(width: canvasFrame.width, height: 300) // 300 is the frame height from UI
        
        print("[MLKit] 📏 Canvas frame: \(canvasFrame)")
        print("[MLKit] 📐 Full canvas size: \(canvasSize)")
        
        // Create white background image with full canvas size
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        let imageWithWhiteBackground = renderer.image { context in
            // Fill with white background
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: canvasSize))
            
            // Draw the entire PKDrawing on the full canvas
            // We need to render the drawing with the full canvas bounds, not just drawing bounds
            let fullCanvasRect = CGRect(origin: .zero, size: canvasSize)
            
            // Get the drawing image that covers the full canvas area
            let drawingImage = drawing.image(from: fullCanvasRect, scale: 1.0)
            drawingImage.draw(in: fullCanvasRect)
        }
        
        print("[MLKit] ✅ Full canvas image created with white background successfully")
        return imageWithWhiteBackground
    }
    
    // MARK: - Debug Image Export Functions
    
    private func exportImageForDebugging(_ image: UIImage, objectName: String, suffix: String = "") {
        print("[MLKit] 💾 Exporting debug image...")
        
        // Use specific path as requested
        let specificPath = "/Users/kerupuksambel/Projects/Academy/challenge4exploration/challenge4exploration/MLKit/aset"
        let mlkitFolder = URL(fileURLWithPath: specificPath)
        
        do {
            try FileManager.default.createDirectory(at: mlkitFolder, withIntermediateDirectories: true, attributes: nil)
            print("[MLKit] 📁 Target folder: \(specificPath)")
        } catch {
            print("[MLKit] ❌ Error creating aset folder at \(specificPath): \(error)")
            return
        }
        
        // Create filename with timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        
        let filename = "debug_\(objectName.replacingOccurrences(of: " ", with: "_"))_\(timestamp)\(suffix).png"
        let fileURL = mlkitFolder.appendingPathComponent(filename)
        
        // Convert UIImage to PNG data and save
        guard let pngData = image.pngData() else {
            print("[MLKit] ❌ Error: Could not convert image to PNG data")
            return
        }
        
        do {
            try pngData.write(to: fileURL)
            print("[MLKit] ✅ Debug image saved successfully!")
            print("[MLKit] 📁 File location: \(fileURL.path)")
            print("[MLKit] 📏 Image size: \(image.size)")
            print("[MLKit] 🎯 Target object: \(objectName)")
        } catch {
            print("[MLKit] ❌ Error saving debug image: \(error)")
        }
    }
    
    private func convertPixelBufferToUIImage(pixelBuffer: CVPixelBuffer) -> UIImage? {
        print("[MLKit] 🔄 Converting CVPixelBuffer back to UIImage for debugging...")
        
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0)) }
        
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let context = CGContext(
            data: baseAddress,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            print("[MLKit] ❌ Error: Could not create CGContext from CVPixelBuffer")
            return nil
        }
        
        guard let cgImage = context.makeImage() else {
            print("[MLKit] ❌ Error: Could not create CGImage from context")
            return nil
        }
        
        let uiImage = UIImage(cgImage: cgImage)
        print("[MLKit] ✅ CVPixelBuffer converted back to UIImage successfully")
        return uiImage
    }
    
//    private func performVisionBasedPrediction(on image: UIImage) {
//        print("[MLKit] 🔄 Fallback: Using Vision framework...")
//        
//        guard let model = try? VNCoreMLModel(for: ImageDetectorDoodle().model) else {
//            print("[MLKit] ❌ Error: Failed to load model for Vision framework")
//            DispatchQueue.main.async {
//                self.predictionResult = "Vision model loading failed"
//                self.confidence = 0.0
//                self.showResult = true
//                self.isAnalyzing = false
//            }
//            return
//        }
//        
//        let request = VNCoreMLRequest(model: model) { request, error in
//            print("[MLKit] 📡 Received Vision framework response")
//            DispatchQueue.main.async {
//                self.processMLResults(request: request, error: error)
//            }
//        }
//        
//        // Set image crop and scale option for better compatibility
//        request.imageCropAndScaleOption = .centerCrop
//        
//        guard let cgImage = image.cgImage else {
//            print("[MLKit] ❌ Error: Failed to convert UIImage to CGImage for Vision")
//            DispatchQueue.main.async {
//                self.predictionResult = "Vision image conversion failed"
//                self.confidence = 0.0
//                self.showResult = true
//                self.isAnalyzing = false
//            }
//            return
//        }
//        
//        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//        
//        do {
//            try handler.perform([request])
//            print("[MLKit] ✅ Vision framework request sent successfully")
//        } catch {
//            print("[MLKit] ❌ Vision framework error: \(error.localizedDescription)")
//            DispatchQueue.main.async {
//                self.predictionResult = "Vision prediction failed: \(error.localizedDescription)"
//                self.confidence = 0.0
//                self.showResult = true
//                self.isAnalyzing = false
//            }
//        }
//    }
    
    private func processMLResults(request: VNRequest, error: Error?) {
        print("[MLKit] 📊 Processing ML results...")
        self.isAnalyzing = false
        
        if let error = error {
            print("[MLKit] ❌ ML Error: \(error.localizedDescription)")
            self.predictionResult = "Error: \(error.localizedDescription)"
            self.confidence = 0.0
            self.showResult = true
            return
        }
        
        print("[MLKit] ✅ No errors, processing results...")
        
        guard let results = request.results as? [VNClassificationObservation] else {
            print("[MLKit] ❌ Error: Cannot cast results to VNClassificationObservation")
            self.predictionResult = "Results parsing failed"
            self.confidence = 0.0
            self.showResult = true
            return
        }
        
        print("[MLKit] 📋 Total classification results: \(results.count)")
        
        // Log all results for debugging
        for (index, result) in results.enumerated() {
            print("[MLKit] Result \(index + 1): \(result.identifier) - \(Int(result.confidence * 100))%")
        }
        
        guard let topResult = results.first else {
            print("[MLKit] ❌ Error: No classification results found")
            self.predictionResult = "No results found"
            self.confidence = 0.0
            self.showResult = true
            return
        }
        
        print("[MLKit] 🏆 Top prediction: \(topResult.identifier)")
        print("[MLKit] 📈 Confidence: \(Int(topResult.confidence * 100))%")
        print("[MLKit] 🎯 Target object: \(currentObject)")
        
        // Check if prediction matches target
        let isCorrect = topResult.identifier.lowercased().contains(currentObject.lowercased()) || 
                       currentObject.lowercased().contains(topResult.identifier.lowercased())
        print("[MLKit] ✅ Is prediction correct? \(isCorrect ? "YES" : "NO")")
        
        self.predictionResult = topResult.identifier
        self.confidence = topResult.confidence
        self.showResult = true
        
        print("[MLKit] 🎉 Results displayed to user!")
    }
}

// MARK: - Custom Button Style
struct CustomButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(color)
            .cornerRadius(25)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Canvas View Integration
struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 4)
        canvasView.backgroundColor = UIColor.white
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

#Preview {
    MLKit()
} 
