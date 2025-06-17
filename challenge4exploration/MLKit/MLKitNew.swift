//
//  MLKitNew.swift
//  challenge4exploration
//
//  Created by Ammar Alifian Fahdan on 17/06/25.
//

import SwiftUI
import CoreML

struct MLKitNew: View {
    var body: some View {
        Button("Analyze"){
            analyze()
        }
    }
    
    private func analyze(){
        let image = UIImage(contentsOfFile: "/Users/kerupuksambel/Projects/Academy/challenge4exploration/challenge4exploration/MLKit/input/alarm_clock_001.jpg")!
        performMLKit(image: image)
    }
    
    private func performMLKit(image: UIImage) {
        guard let pixelBuffer = convertToPixelBuffer(image: image) else {
            print("[MLKit] ❌ Error: Failed to convert UIImage to CVPixelBuffer")
            return
        }
        
        guard let mlModel = try? ImageDetectorDoodle(configuration: MLModelConfiguration()) else {
            print("[MLKit] ❌ Error: Failed to load ImageDetectorDoodle model")
            return
        }
        
        let options = MLPredictionOptions()
        options.usesCPUOnly = true
        
        do {
            let prediction = try mlModel.prediction(input: ImageDetectorDoodleInput(image: pixelBuffer), options: options)
            
            print(prediction.targetProbability)
        }catch{
            print("Error: \(error)")
        }
        
    }
    
    private func convertToPixelBuffer(image: UIImage) -> CVPixelBuffer? {
        // Use original image size (no resize)
        let originalSize = image.size
        print("[MLKit] 🎨 Creating CVPixelBuffer with original size: \(originalSize)")
        
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(originalSize.width),
            Int(originalSize.height),
            kCVPixelFormatType_32ARGB,
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
            width: Int(originalSize.width),
            height: Int(originalSize.height),
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
}

#Preview {
    MLKitNew()
}
