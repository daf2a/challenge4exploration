//
//  GameKit.swift
//  challenge4exploration
//
//  Created by Ahmad Zuhal Zhafran on 05/06/25.
//

import SwiftUI

struct GameKit: View {
    var body: some View {
        VStack {
            Text("GameKit")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text("Game Center & Social Gaming")
                .font(.title2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    GameKit()
} 