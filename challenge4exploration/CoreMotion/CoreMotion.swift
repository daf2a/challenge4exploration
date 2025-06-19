//
//  CoreMotion.swift
//  challenge4exploration
//
//  Created by Ahmad Zuhal Zhafran on 05/06/25.
//

import CoreMotion
import SwiftUI

struct CoreMotion: View {
    // Posisi bola (mulai dari tengah layar)
    @State private var ballPosition = CGPoint(
        x: UIScreen.main.bounds.width / 2,
        y: UIScreen.main.bounds.height / 2
    )

    // Ukuran bola
    let ballSize: CGFloat = 50

    // Motion Manager untuk ambil data accelerometer
    let motionManager = CMMotionManager()

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)  // Latar belakang putih

            Circle()
                .fill(Color.blue)
                .frame(width: ballSize, height: ballSize)
                .position(ballPosition)  // Posisi bola
        }
        .onAppear {
            startMotionUpdates()
        }
    }

    func startMotionUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.02  // Update setiap 20ms
            motionManager.startAccelerometerUpdates(to: .main) { data, error in
                guard let acceleration = data?.acceleration else { return }

                // Sensitivitas gerakan
                let sensitivity: CGFloat = 20.0

                // Update posisi berdasarkan kemiringan
                let newX =
                    ballPosition.x + CGFloat(acceleration.x) * sensitivity * -1
                let newY =
                    ballPosition.y + CGFloat(acceleration.y) * sensitivity

                // Batasan agar bola tidak keluar layar
                let maxX = UIScreen.main.bounds.width - ballSize / 2
                let maxY = UIScreen.main.bounds.height - ballSize / 2
                let minX = ballSize / 2
                let minY = ballSize / 2

                // Update posisi secara aman
                ballPosition = CGPoint(
                    x: min(max(newX, minX), maxX),
                    y: min(max(newY, minY), maxY)
                )
            }
        }
    }
}

#Preview {
    CoreMotion()
}
