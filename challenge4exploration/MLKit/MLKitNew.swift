//
//  MLKitNew.swift
//  challenge4exploration
//
//  Created by Ammar Alifian Fahdan on 16/06/25.
//

import CoreImage
import CoreML
import PencilKit
import SwiftUI
import Vision

struct MLKitNew: View {
    @State private var canvasView = PKCanvasView()

    var body: some View {
        VStack {
            Button("Trigger") {
                analyzeExtImage()
            }
        }
    }

    private func setupCanvas() {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.fountainPen, color: .black, width: 10)
        canvasView.backgroundColor = UIColor.white
        canvasView.frame = CGRect(x: 0, y: 0, width: 299, height: 299)
    }

    //    private func analyze() {
    //        // Read image
    //        let drawing = createImage(from: canvasView.drawing)
    //
    //        performMLPrediction(on: drawing)
    //
    //        // Do analysis
    //    }

    private func performMLPrediction(on image: UIImage) {

        // Load model directly without Vision wrapper first
        guard let mlModel = try? ImageDetectorDoodle(configuration: MLModelConfiguration()) else {
            return
        }

        // Convert UIImage to CVPixelBuffer
        guard
            let pixelBuffer = convertToPixelBuffer(
                image: image, size: CGSize(width: 299, height: 299))
        else {
            print("Failed to convert UIImage to CVPixelBuffer.")
            return
        }

        // DEBUG: print hash for each pixelbuffer run
//        guard let normalizedBuffer = normalizePixelBuffer(pixelBuffer) else {
//            print("Failed to normalize pixel buffer")
//            return
//        }
        print("PixelBuffer Hash: \(hashPixelBuffer(pixelBuffer))")

        do {
            // Perform prediction directly with CoreML model
            let prediction = try mlModel.prediction(image: pixelBuffer)
            print(prediction.targetProbability)
        } catch {

            // Fallback to Vision framework approach
            //                self.performVisionBasedPrediction(on: image)
        }
    }

    //    private func createImage(from drawing: PKDrawing) -> UIImage {
    //
    //        // Use full canvas size instead of drawing bounds
    //        let canvasFrame = canvasView.frame
    //        let canvasSize = CGSize(width: canvasFrame.width, height: canvasFrame.height, )  // 300 is the frame height from UI
    //
    //        // Create white background image with full canvas size
    //        let renderer = UIGraphicsImageRenderer(size: canvasSize)
    //        let imageWithWhiteBackground = renderer.image { context in
    //            // Fill with white background
    //            context.cgContext.setFillColor(UIColor.white.cgColor)
    //            context.cgContext.fill(CGRect(origin: .zero, size: canvasSize))
    //
    //            // Draw the entire PKDrawing on the full canvas
    //            // We need to render the drawing with the full canvas bounds, not just drawing bounds
    //            let fullCanvasRect = CGRect(origin: .zero, size: canvasSize)
    //
    //            // Get the drawing image that covers the full canvas area
    //            let drawingImage = drawing.image(from: fullCanvasRect, scale: 1.0)
    //            drawingImage.draw(in: fullCanvasRect)
    //        }
    //
    //        return imageWithWhiteBackground
    //    }

    func convertToPixelBuffer(image: UIImage, size: CGSize) -> CVPixelBuffer? {
        let attrs =
            [
                kCVPixelBufferCGImageCompatibilityKey: true,
                kCVPixelBufferCGBitmapContextCompatibilityKey: true,
            ] as CFDictionary

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            299,
            299,
            kCVPixelFormatType_32BGRA,  // use RGB or ARGB depending on your model
            attrs,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }

//        CVPixelBufferLockBaseAddress(buffer, [])
//        let context = CGContext(
//            data: CVPixelBufferGetBaseAddress(buffer),
//            width: Int(size.width),
//            height: Int(size.height),
//            bitsPerComponent: 8,
//            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
//            space: CGColorSpaceCreateDeviceRGB(),
//            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
//        )
//
//        guard let ctx = context else {
//            CVPixelBufferUnlockBaseAddress(buffer, [])
//            return nil
//        }
//
//        UIGraphicsPushContext(ctx)
//        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
//        UIGraphicsPopContext()
//        CVPixelBufferUnlockBaseAddress(buffer, [])

        return buffer
    }

    private func analyzeExtImage() {
        guard
            let image = UIImage(
                contentsOfFile:
                    "/Users/kerupuksambel/Projects/Academy/challenge4exploration/challenge4exploration/MLKit/input/alarm_clock_001.jpg"
            )
        else {
            return
        }

        performMLPrediction(on: image)
    }

    func hashPixelBuffer(_ buffer: CVPixelBuffer) -> Int {
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(buffer)!
        let byteCount = CVPixelBufferGetBytesPerRow(buffer) * CVPixelBufferGetHeight(buffer)
        let data = Data(bytes: baseAddress, count: byteCount)
        CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
        return data.hashValue  // or just return data for full compare
    }
//
//    func normalizePixelBuffer(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
//        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//        let context = CIContext(options: nil)
//
//        var normalizedBuffer: CVPixelBuffer?
//
//        let attrs =
//            [
//                kCVPixelBufferCGImageCompatibilityKey: true,
//                kCVPixelBufferCGBitmapContextCompatibilityKey: true,
//            ] as CFDictionary
//
//        let width = CVPixelBufferGetWidth(pixelBuffer)
//        let height = CVPixelBufferGetHeight(pixelBuffer)
//
//        CVPixelBufferCreate(
//            kCFAllocatorDefault,
//            width,
//            height,
//            kCVPixelFormatType_32BGRA,
//            attrs,
//            &normalizedBuffer)
//
//        if let normalizedBuffer = normalizedBuffer {
//            context.render(
//                ciImage
//                    .applyingFilter(
//                        "CIColorControls",
//                        parameters: [
//                            "inputBrightness": 0, "inputContrast": 1, "inputSaturation": 1,
//                        ]),
//                to: normalizedBuffer)
//        }
//
//        return normalizedBuffer
//    }

}

#Preview {
    MLKitNew()
}
