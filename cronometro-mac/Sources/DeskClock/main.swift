import SwiftUI
import AppKit
import ServiceManagement

@main
struct DeskClockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            StopwatchView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("Acerca del cronómetro") {
                    NSApp.orderFrontStandardAboutPanel(nil)
                }
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        registerLaunchAtLogin()

        DispatchQueue.main.async {
            guard let window = NSApp.windows.first else { return }
            window.title = "Cronómetro"
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.isMovableByWindowBackground = true
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = true
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
        }
    }

    private func registerLaunchAtLogin() {
        let loginItem = SMAppService.loginItem(identifier: "com.alexrowan.deskclock.loginitem")
        guard loginItem.status != .enabled else { return }

        do {
            try loginItem.register()
        } catch {
            NSLog("DeskClock could not register launch at login: \(error.localizedDescription)")
        }
    }
}

struct StopwatchView: View {
    @State private var launchAtLogin = SMAppService.loginItem(identifier: "com.alexrowan.deskclock.loginitem").status == .enabled
    @State private var isHovering = false
    @State private var isStopwatchRunning = false
    @State private var elapsedBeforeStart: TimeInterval = 0
    @State private var startUptime: TimeInterval = 0
    @State private var laps: [StopwatchLap] = []

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()

                Menu {
                    Button {
                        setLaunchAtLogin(!launchAtLogin)
                    } label: {
                        Label(
                            launchAtLogin ? "✓  Abrir al iniciar sesión" : "Abrir al iniciar sesión",
                            systemImage: launchAtLogin ? "checkmark.circle.fill" : "circle"
                        )
                    }
                    Divider()
                    Button("Salir del cronómetro") { NSApp.terminate(nil) }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white.opacity(isHovering ? 0.9 : 0.45))
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .menuStyle(.borderlessButton)
                .onHover { isHovering = $0 }
            }
            .padding(.horizontal, 34)
            .padding(.top, 26)

            Spacer(minLength: 10)
            stopwatchContent
            Spacer(minLength: 12)
        }
        .frame(width: 380, height: 380)
        .background {
            Circle()
                .fill(.black)
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.14), lineWidth: 1)
                }
        }
        .shadow(color: .black.opacity(0.45), radius: 20, y: 8)
        .padding(10)
    }

    private var stopwatchContent: some View {
        VStack(spacing: 14) {
            TimelineView(.periodic(from: .now, by: 0.01)) { _ in
                Text(formatStopwatch(currentElapsed))
                    .font(.system(size: 43, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 2)
                    .accessibilityLabel("Cronómetro: \(formatStopwatch(currentElapsed))")
            }

            Text("CRONÓMETRO")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .tracking(3)
                .foregroundStyle(.white.opacity(0.42))
                .padding(.top, -8)

            HStack(spacing: 12) {
                Button {
                    toggleStopwatch()
                } label: {
                    Label(
                        isStopwatchRunning ? "Pausar" : (currentElapsed == 0 ? "Iniciar" : "Seguir"),
                        systemImage: isStopwatchRunning ? "pause.fill" : "play.fill"
                    )
                }
                .buttonStyle(StopwatchButtonStyle(isPrimary: true, isCircular: false))
                .keyboardShortcut(.space, modifiers: [])
                .frame(width: 118)

                Button {
                    recordLap()
                } label: {
                    Image(systemName: "flag.fill")
                }
                .buttonStyle(StopwatchButtonStyle(isPrimary: false, isCircular: true))
                .help("Registrar vuelta")
                .disabled(!isStopwatchRunning)

                Button {
                    resetStopwatch()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                .buttonStyle(StopwatchButtonStyle(isPrimary: false, isCircular: true))
                .help("Reiniciar cronómetro")
                .disabled(currentElapsed == 0 && laps.isEmpty)
            }

            if !laps.isEmpty {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(laps.reversed()) { lap in
                            HStack {
                                Text(String(format: "VUELTA %02d", lap.number))
                                    .foregroundStyle(.white.opacity(0.48))
                                Spacer()
                                Text(formatStopwatch(lap.split))
                                    .foregroundStyle(.white.opacity(0.9))
                            }
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .monospacedDigit()
                            .padding(.vertical, 6)
                        }
                    }
                }
                .frame(height: 74)
                .padding(.horizontal, 40)
                .accessibilityLabel("Vueltas registradas")
            }
        }
    }

    private var currentElapsed: TimeInterval {
        elapsedBeforeStart + (isStopwatchRunning ? ProcessInfo.processInfo.systemUptime - startUptime : 0)
    }

    private func toggleStopwatch() {
        if isStopwatchRunning {
            elapsedBeforeStart = currentElapsed
            isStopwatchRunning = false
        } else {
            startUptime = ProcessInfo.processInfo.systemUptime
            isStopwatchRunning = true
        }
    }

    private func recordLap() {
        let total = currentElapsed
        let previousTotal = laps.last?.total ?? 0
        laps.append(StopwatchLap(number: laps.count + 1, total: total, split: total - previousTotal))
    }

    private func resetStopwatch() {
        isStopwatchRunning = false
        elapsedBeforeStart = 0
        startUptime = 0
        laps.removeAll()
    }

    private func formatStopwatch(_ interval: TimeInterval) -> String {
        let centiseconds = max(0, Int((interval * 100).rounded(.down)))
        let hours = centiseconds / 360_000
        let minutes = (centiseconds / 6_000) % 60
        let seconds = (centiseconds / 100) % 60
        let fraction = centiseconds % 100

        if hours > 0 {
            return String(format: "%02d:%02d:%02d.%02d", hours, minutes, seconds, fraction)
        }
        return String(format: "%02d:%02d.%02d", minutes, seconds, fraction)
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            let loginItem = SMAppService.loginItem(identifier: "com.alexrowan.deskclock.loginitem")
            if enabled {
                try loginItem.register()
            } else {
                try loginItem.unregister()
            }
            launchAtLogin = enabled
        } catch {
            NSLog("DeskClock login item error: \(error.localizedDescription)")
        }
    }
}

private struct StopwatchLap: Identifiable {
    let id = UUID()
    let number: Int
    let total: TimeInterval
    let split: TimeInterval
}

private struct StopwatchButtonStyle: ButtonStyle {
    let isPrimary: Bool
    let isCircular: Bool
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: isCircular ? 12 : 11, weight: .semibold))
            .foregroundStyle(isPrimary ? Color.black : .white.opacity(0.8))
            .frame(width: isCircular ? 38 : nil, height: 38)
            .background(
                isPrimary ? Color.white : Color.white.opacity(0.1),
                in: Capsule()
            )
            .opacity(configuration.isPressed ? 0.72 : 1)
            .opacity(isEnabled ? 1 : 0.38)
            .contentShape(Capsule())
    }
}
