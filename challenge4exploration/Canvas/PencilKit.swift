//
//  PencilKit.swift
//  challenge4exploration
//
//  Created by Ahmad Zuhal Zhafran on 05/06/25.
//

import SwiftUI
import PencilKit

struct PencilKit: View {
  @State private var canvasView = PKCanvasView()
  @State private var showToolPicker = true

  var body: some View {
      VStack {
          CanvasView(canvasView: $canvasView)
              .background(Color.white)
              .cornerRadius(10)
              .padding()

          Button("Clear") {
              canvasView.drawing = PKDrawing()
          }
          .padding()
      }
      .onAppear {
          if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
             let window = windowScene.windows.first {
              let toolPicker = PKToolPicker()
              toolPicker.setVisible(true, forFirstResponder: canvasView)
              toolPicker.addObserver(canvasView)
              canvasView.becomeFirstResponder()
          }
      }
  }
}

#Preview {
    PencilKit()
}
