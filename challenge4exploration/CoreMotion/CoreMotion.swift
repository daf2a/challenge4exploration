//
//  CoreMotion.swift
//  challenge4exploration
//
//  Created by Ahmad Zuhal Zhafran on 05/06/25.
//

import SwiftUI
import CoreMotion

struct CoreMotion: View {
    @State private var x: Double = 0.0  // 2️⃣ Posisi sumbu X
    @State private var y: Double = 0.0  // 2️⃣ Posisi sumbu Y
    @State private var z: Double = 0.0  // 2️⃣ Posisi sumbu Z

    let motion = CMMotionManager()  // 3️⃣ Objek utama untuk sensor motion

    var body: some View {
<<<<<<< HEAD
        VStack(spacing: 20) {
            Text("Accelerometer Data")
                .font(.title)
                .bold()
            Text("X: \(x, specifier: "%.2f")")
            Text("Y: \(y, specifier: "%.2f")")
            Text("Z: \(z, specifier: "%.2f")")
        }
        .onAppear {
            startAccelerometer()
        }
    }

    func startAccelerometer() {
        if motion.isAccelerometerAvailable {  // 4️⃣ Cek apakah perangkat punya sensor ini
            motion.accelerometerUpdateInterval = 0.1  // 5️⃣ Update tiap 0.1 detik
            motion.startAccelerometerUpdates(to: .main) { data, error in  // 6️⃣ Mulai mengambil data
                guard let data = data else { return }  // 7️⃣ Pastikan data tidak nil
                x = data.acceleration.x  // 8️⃣ Update nilai X
                y = data.acceleration.y  // 8️⃣ Update nilai Y
                z = data.acceleration.z  // 8️⃣ Update nilai Z
            }
=======
        VStack {
            Text("CoreMotion")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text("Accelerometer, Gyroscope, and Pedometer")
                .font(.title2)
                .foregroundColor(.secondary)
>>>>>>> a9bd00e22d095a1fda8f0794ac82ca62c607bff7
        }
    }
}

#Preview {
    CoreMotion()
}
