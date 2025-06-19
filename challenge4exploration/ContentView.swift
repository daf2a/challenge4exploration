import SwiftUI

struct ContentView: View {
  var body: some View {
    TabView {
        Tab("PencilKit", systemImage: "pencil"){
            PencilKit()
        }
        Tab("CoreMotion", systemImage: "gyroscope"){
            CoreMotion()
        }
        Tab("SceneKit", systemImage: "cube.transparent"){
            SceneKit()
        }
        Tab("StoreKit", systemImage: "cart"){
            StoreKit()
        }
        Tab("GameKit", systemImage: "gamecontroller"){
            GameKit()
        }
        Tab("Card Memory", systemImage: "dice"){
            CardMemoryView()
        }
        Tab("SpriteKit", systemImage: "figure.run"){
            SpriteKitView()
        }
        Tab("MultipeerConnectivity", systemImage: "network"){
            MultipeerConnectivity()
        }
        Tab("VisionKit", systemImage: "viewfinder"){
            VisionKit()
        }
        Tab("MLKit", systemImage: "brain.head.profile"){
            MLKit()
        }
    }
  }
}

#Preview {
  ContentView()
        .preferredColorScheme(.light)
}
