import SwiftUI
import PencilKit

struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
