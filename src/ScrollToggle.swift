import AppKit
import Foundation
import Darwin

enum ToggleError: LocalizedError {
    case failed(String)
    var errorDescription: String? { switch self { case .failed(let message): return message } }
}

let preferenceKey = "com.apple.swipescrolldirection" as CFString

func currentDirection() throws -> Bool {
    CFPreferencesSynchronize(kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesAnyHost)
    guard let value = CFPreferencesCopyValue(preferenceKey, kCFPreferencesAnyApplication,
        kCFPreferencesCurrentUser, kCFPreferencesAnyHost) as? NSNumber else {
        throw ToggleError.failed("無法讀取目前的自然捲動設定，未進行切換。")
    }
    return value.boolValue
}

func toggleDirection() throws -> Bool {
    let path = "/System/Library/PrivateFrameworks/PreferencePanesSupport.framework/PreferencePanesSupport"
    guard let library = dlopen(path, RTLD_LAZY) else {
        throw ToggleError.failed("目前的 macOS 無法立即套用捲動方向，未進行切換。")
    }
    defer { dlclose(library) }
    guard let symbol = dlsym(library, "setSwipeScrollDirection") else {
        throw ToggleError.failed("目前的 macOS 不支援此切換介面，未進行切換。")
    }
    let next = try !currentDirection()
    let setter = unsafeBitCast(symbol, to: (@convention(c) (Bool) -> Void).self)
    CFPreferencesSetValue(preferenceKey, next as CFBoolean, kCFPreferencesAnyApplication,
        kCFPreferencesCurrentUser, kCFPreferencesAnyHost)
    guard CFPreferencesSynchronize(kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) else {
        throw ToggleError.failed("無法儲存自然捲動設定。")
    }
    setter(next)
    guard try currentDirection() == next else {
        throw ToggleError.failed("自然捲動設定未成功更新。")
    }
    return next
}

// Draw the actual transparent window shape instead of clipping a behind-window
// visual-effect surface, whose compositor can escape a CALayer corner mask.
final class RoundedToastView: NSView {
    override var isOpaque: Bool { false }

    override func draw(_ dirtyRect: NSRect) {
        let dark = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        let outline = NSBezierPath(roundedRect: bounds.insetBy(dx: 10, dy: 10), xRadius: 20, yRadius: 20)
        NSGraphicsContext.saveGraphicsState()
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(dark ? 0.28 : 0.15)
        shadow.shadowBlurRadius = 8
        shadow.shadowOffset = NSSize(width: 0, height: -2)
        shadow.set()
        (dark ? NSColor(calibratedWhite: 0.08, alpha: 0.98) : NSColor.white.withAlphaComponent(0.98)).setFill()
        outline.fill()
        NSGraphicsContext.restoreGraphicsState()
        (dark ? NSColor.white.withAlphaComponent(0.13) : NSColor.black.withAlphaComponent(0.08)).setStroke()
        outline.lineWidth = 0.75
        outline.stroke()
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var panel: NSPanel?
    private var titleLabel: NSTextField?
    private var finish: DispatchWorkItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let index = CommandLine.arguments.firstIndex(of: "--preview"), CommandLine.arguments.count > index + 1 {
            NSApp.appearance = NSAppearance(named: CommandLine.arguments[index + 1] == "dark" ? .darkAqua : .aqua)
            showResult(true)
            // A finite, local preview for visual QA; never changes scroll settings.
            DispatchQueue.main.asyncAfter(deadline: .now() + 20) { NSApp.terminate(nil) }
        } else { toggle() }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        toggle()
        return false
    }

    private func toggle() {
        finish?.cancel()
        do {
            let natural = try toggleDirection()
            showResult(natural)
            let exitTask = DispatchWorkItem { NSApp.terminate(nil) }
            finish = exitTask
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: exitTask)
        } catch {
            panel?.orderOut(nil)
            NSApp.activate(ignoringOtherApps: true)
            let alert = NSAlert()
            alert.messageText = "自然捲動切換失敗"
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .warning
            alert.addButton(withTitle: "好")
            alert.runModal()
            NSApp.terminate(nil)
        }
    }

    private func showResult(_ natural: Bool) {
        if panel == nil {
            let frame = NSRect(x: 0, y: 0, width: 324, height: 84)
            let result = NSPanel(contentRect: frame, styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered, defer: false)
            result.isOpaque = false
            result.backgroundColor = .clear
            result.hasShadow = false
            result.ignoresMouseEvents = true
            result.level = .statusBar
            result.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
            let background = RoundedToastView(frame: frame)
            let icon = NSImageView(frame: NSRect(x: 29, y: 26, width: 30, height: 30))
            icon.image = NSImage(systemSymbolName: "arrow.up.arrow.down", accessibilityDescription: nil)
            icon.contentTintColor = NSColor(srgbRed: 10 / 255, green: 132 / 255, blue: 1, alpha: 1)
            background.addSubview(icon)
            let label = NSTextField(labelWithString: "")
            label.font = .systemFont(ofSize: 19, weight: .medium)
            label.frame = NSRect(x: 76, y: 27, width: 226, height: 28)
            background.addSubview(label)
            titleLabel = label
            result.contentView = background
            panel = result
        }
        titleLabel?.stringValue = natural ? "自然捲動：已開啟" : "自然捲動：已關閉"
        if let screen = NSScreen.main {
            panel?.setFrameOrigin(NSPoint(x: screen.visibleFrame.midX - 162, y: screen.visibleFrame.minY + 80))
        }
        panel?.orderFrontRegardless()
    }
}

if CommandLine.arguments.contains("--status") {
    do { print(try currentDirection() ? "on" : "off"); exit(0) }
    catch { fputs("\(error.localizedDescription)\n", stderr); exit(1) }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
withExtendedLifetime(delegate) { app.run() }
