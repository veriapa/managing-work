import AppKit

final class LoginItemDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let appURL = URL(fileURLWithPath: "/Applications/DeskClock.app")
        if FileManager.default.fileExists(atPath: appURL.path) {
            NSWorkspace.shared.open(appURL)
        } else {
            let fallbackURL = Bundle.main.bundleURL
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
            NSWorkspace.shared.open(fallbackURL)
        }
        NSApp.terminate(nil)
    }
}

@main
struct DeskClockLoginItemApp {
    static func main() {
        let delegate = LoginItemDelegate()
        NSApplication.shared.delegate = delegate
        _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
    }
}
