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
        Tab("GamePlayKit", systemImage: "dice"){
            GamePlayKit()
        }
        Tab("SpriteKit", systemImage: "figure.run"){
            SpriteKit()
        }
        Tab("MultipeerConnectivity", systemImage: "network"){
            MultipeerConnectivity()
        }
        Tab("VisionKit", systemImage: "viewfinder"){
            VisionKit()
        }
<<<<<<< HEAD
=======
        Tab("MLKit", systemImage: "brain.head.profile"){
            MLKit()
        }
>>>>>>> a9bd00e22d095a1fda8f0794ac82ca62c607bff7
    }
  }
}

#Preview {
  ContentView()
}
