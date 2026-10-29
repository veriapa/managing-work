import AppKit

final class ClockView: NSView {
    private let timeLabel = NSTextField(labelWithString: "")
    private let dateLabel = NSTextField(labelWithString: "")
    private var timer: Timer?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.82).cgColor
        layer?.cornerRadius = 12
        layer?.masksToBounds = true

        timeLabel.font = .monospacedDigitSystemFont(ofSize: 40, weight: .bold)
        timeLabel.textColor = .white
        timeLabel.alignment = .center
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        dateLabel.font = .systemFont(ofSize: 13, weight: .medium)
        dateLabel.textColor = NSColor.white.withAlphaComponent(0.74)
        dateLabel.alignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(timeLabel)
        addSubview(dateLabel)
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            dateLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 1),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -13)
        ])

        updateClock()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateClock()
        }
    }

    private func updateClock() {
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "es_CL")
        timeFormatter.timeStyle = .medium
        timeLabel.stringValue = timeFormatter.string(from: Date())

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "es_CL")
        dateFormatter.dateStyle = .full
        dateLabel.stringValue = dateFormatter.string(from: Date())
    }
}

final class StopwatchView: NSView {
    private let timeLabel = NSTextField(labelWithString: "00:00.0")
    private let startPauseButton = NSButton(title: "Iniciar", target: nil, action: nil)
    private var startedAt: Date?
    private var elapsedBeforePause: TimeInterval = 0
    private var timer: Timer?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        timeLabel.font = .monospacedDigitSystemFont(ofSize: 38, weight: .bold)
        timeLabel.alignment = .center
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        startPauseButton.target = self
        startPauseButton.action = #selector(toggle)
        startPauseButton.bezelStyle = .rounded

        let resetButton = NSButton(title: "Reiniciar", target: self, action: #selector(reset))
        resetButton.bezelStyle = .rounded
        let buttons = NSStackView(views: [startPauseButton, resetButton])
        buttons.orientation = .horizontal
        buttons.spacing = 10
        buttons.translatesAutoresizingMaskIntoConstraints = false

        addSubview(timeLabel)
        addSubview(buttons)
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            buttons.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttons.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 14),
            buttons.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.refreshTime()
        }
    }

    @objc private func toggle() {
        if let startedAt {
            elapsedBeforePause += Date().timeIntervalSince(startedAt)
            self.startedAt = nil
            startPauseButton.title = "Continuar"
        } else {
            startedAt = Date()
            startPauseButton.title = "Pausar"
        }
        refreshTime()
    }

    @objc private func reset() {
        startedAt = nil
        elapsedBeforePause = 0
        startPauseButton.title = "Iniciar"
        refreshTime()
    }

    private func refreshTime() {
        let elapsed = elapsedBeforePause + (startedAt.map { Date().timeIntervalSince($0) } ?? 0)
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        let tenths = Int((elapsed * 10).rounded(.down)) % 10
        timeLabel.stringValue = String(format: "%02d:%02d.%d", minutes, seconds, tenths)
    }
}

final class ClockAppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var stopwatchWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        configureMenu()
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 390, height: 118),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Reloj Nativo"
        window.titlebarAppearsTransparent = false
        window.titleVisibility = .visible
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true
        window.level = .floating
        window.isReleasedWhenClosed = false
        window.contentView = ClockView(frame: NSRect(x: 0, y: 0, width: 390, height: 118))
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    private func configureMenu() {
        let mainMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Ocultar Reloj Nativo", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Salir de Reloj Nativo", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        let windowMenuItem = NSMenuItem()
        let windowMenu = NSMenu(title: "Ventana")
        windowMenu.addItem(withTitle: "Cronómetro…", action: #selector(showStopwatch), keyEquivalent: "t")
        windowMenu.addItem(NSMenuItem.separator())
        windowMenu.addItem(withTitle: "Cerrar ventana", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        windowMenuItem.submenu = windowMenu
        mainMenu.addItem(windowMenuItem)
        NSApp.mainMenu = mainMenu
        NSApp.windowsMenu = windowMenu
    }

    @objc private func showStopwatch() {
        if let stopwatchWindow {
            stopwatchWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let stopwatchWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 150),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        stopwatchWindow.title = "Cronómetro"
        stopwatchWindow.contentView = StopwatchView(frame: NSRect(x: 0, y: 0, width: 280, height: 150))
        stopwatchWindow.center()
        stopwatchWindow.isReleasedWhenClosed = false
        self.stopwatchWindow = stopwatchWindow
        stopwatchWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

let application = NSApplication.shared
let delegate = ClockAppDelegate()
application.delegate = delegate
application.run()
