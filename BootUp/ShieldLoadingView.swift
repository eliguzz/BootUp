//
//  ShieldLoadingView.swift
//  BootUp
//
//  Created by Eli on 5/13/26.
//

import SwiftUI

private let bootLines: [String] = [
    "Loading shaders",
    "Building engine",
    "Training AI model",
    "Compiling assets",
    "Allocating memory",
    "Warming up cache",
    "Syncing telemetry",
    "Calibrating sensors",
    "Initializing runtime",
    "Resolving dependencies",
    "Patching kernel",
    "Mounting volumes",
    "Verifying integrity",
    "Spawning threads",
    "Linking libraries",
]

struct ShieldLoadingView: View {

    let appName: String
    let bundleID: String
    let totalDuration: Double
    var onComplete: () -> Void

    @State private var currentPercent: Int = 0
    @State private var currentLine: String = bootLines.randomElement()!
    @State private var lineOpacity: Double = 1.0
    @State private var isComplete: Bool = false

    // Check if this app has a urlScheme so we can show appropriate end-state text
    private var hasURLScheme: Bool {
        knownApps.first(where: { $0.bundleID == bundleID })?.urlScheme != nil
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {

                Spacer()

                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("BOOTUP ENGINE")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(.terminalDim)

                    Text("INTERCEPTING \(appName.uppercased())")
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundColor(.terminalFaint)

                    Text(versionString)
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundColor(.terminalFaint)
                }

                Spacer()

                // Boot log line + percentage
                HStack(alignment: .bottom) {
                    Text(currentLine)
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .foregroundColor(.terminalDim)
                        .opacity(lineOpacity)
                        .animation(.easeInOut(duration: 0.4), value: lineOpacity)

                    Spacer()

                    Text("\(currentPercent)%")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.terminal)
                        .frame(width: 48, alignment: .trailing)
                        .contentTransition(.numericText())
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.terminalFaint)
                            .frame(height: 2)

                        Rectangle()
                            .fill(Color.terminal)
                            .frame(
                                width: geo.size.width * Double(currentPercent) / 100.0,
                                height: 2
                            )
                    }
                }
                .frame(height: 2)

                // Status line at bottom — varies based on hasURLScheme
                Text(statusText)
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundColor(.terminalDim)
                    .padding(.top, 4)

                Spacer()
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            startPercentTimer()
            startLineTimer()
        }
    }

    // Bundle version string from Info.plist
    private var versionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        return "v\(version)"
    }

    // Status text changes based on whether the app will auto-launch
    private var statusText: String {
        if isComplete {
            return hasURLScheme ? "READY." : "READY. OPEN \(appName.uppercased()) MANUALLY."
        } else if !hasURLScheme && currentPercent >= 85 {
            return "PREPARE TO OPEN \(appName.uppercased()) MANUALLY..."
        } else {
            return "STAND BY..."
        }
    }
    // Percent timer

    private func startPercentTimer() {
        scheduleNextIncrement()
    }

    private func scheduleNextIncrement() {
        guard currentPercent < 100 else { return }

        let averageDelay = totalDuration / 100.0
        let multiplier = randomHangMultiplier()
        let delay = averageDelay * multiplier

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.currentPercent += 1

            if self.currentPercent >= 100 {
                self.isComplete = true
                // Show "READY." for a moment before completing
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.onComplete()
                }
            } else {
                self.scheduleNextIncrement()
            }
        }
    }

    private func randomHangMultiplier() -> Double {
        let roll = Double.random(in: 0...1)
        switch roll {
        case 0..<0.60: return Double.random(in: 0.1...0.8)
        case 0.60..<0.80: return Double.random(in: 0.8...1.2)
        case 0.80..<0.93: return Double.random(in: 1.5...3.0)
        default: return Double.random(in: 3.0...6.0)
        }
    }

    // Line timer — rotates through boot log lines

    private func startLineTimer() {
        scheduleNextLine()
    }

    private func scheduleNextLine() {
        let delay = Double.random(in: 2.5...4.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard !isComplete else { return }
            withAnimation(.easeInOut(duration: 0.4)) { lineOpacity = 0.0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                var next = bootLines.randomElement()!
                while next == currentLine { next = bootLines.randomElement()! }
                currentLine = next
                withAnimation(.easeInOut(duration: 0.4)) { lineOpacity = 1.0 }
            }
            scheduleNextLine()
        }
    }
}
