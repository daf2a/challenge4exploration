import SwiftUI

struct ContentView: View {
  var body: some View {
    TabView {
      Tab("PencilKit", systemImage: "pencil"){
        PencilKit()
      }
      Tab("CoreMotion", systemImage: "circle.dotted.and.circle"){
        CoreMotion()
      }
    }
  }
}

#Preview {
  ContentView()
}
