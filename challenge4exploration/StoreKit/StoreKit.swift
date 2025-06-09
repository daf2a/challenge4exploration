//
//  StoreKit.swift
//  challenge4exploration
//
//  Created by Ahmad Zuhal Zhafran on 05/06/25.
//

import SwiftUI

struct StoreKit: View {
    var body: some View {
        VStack {
            Text("StoreKit")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text("In-App Purchases & Subscriptions")
                .font(.title2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    StoreKit()
} 