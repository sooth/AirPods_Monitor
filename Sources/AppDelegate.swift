import AppKit
import Combine
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var bluetoothMonitor = BluetoothMonitor()
    private var cancellables = Set<AnyCancellable>()
    private var preferencesWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupBluetoothMonitoring()
        setupPreferenceNotifications()
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let statusItem = statusItem else { return }
        
        statusItem.button?.title = "❓ No Device"
        statusItem.button?.target = self
        statusItem.button?.action = #selector(statusItemClicked)
        
        updateMenuBarTitle()
    }
    
    private func setupBluetoothMonitoring() {
        bluetoothMonitor.$currentDevice
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateMenuBarTitle()
                self?.updateMenu()
            }
            .store(in: &cancellables)
        
        bluetoothMonitor.startMonitoring()
    }
    
    private func setupPreferenceNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ShowTextPreferenceChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateMenuBarTitle()
        }
    }
    
    private func updateMenuBarTitle() {
        guard let statusItem = statusItem else { return }
        
        let showText = UserDefaults.standard.object(forKey: "ShowText") as? Bool ?? true
        
        if let device = bluetoothMonitor.currentDevice {
            if showText {
                statusItem.button?.title = "\(device.profile.icon) \(device.profile.displayName)"
            } else {
                statusItem.button?.title = device.profile.icon
            }
            statusItem.button?.toolTip = "\(device.name) in \(device.profile.displayName) mode - Codec: \(device.audioCodec)"
        } else {
            if showText {
                statusItem.button?.title = "❓ No Device"
            } else {
                statusItem.button?.title = "❓"
            }
            statusItem.button?.toolTip = "No AirPods connected"
        }
    }
    
    @objc private func statusItemClicked() {
        guard let statusItem = statusItem else { return }
        
        let menu = NSMenu()
        
        if let device = bluetoothMonitor.currentDevice {
            menu.addItem(NSMenuItem(title: "Device: \(device.name)", action: nil, keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "Profile: \(device.profile.displayName)", action: nil, keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "Codec: \(device.audioCodec)", action: nil, keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
        } else {
            menu.addItem(NSMenuItem(title: "No AirPods Connected", action: nil, keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
        }
        
        menu.addItem(NSMenuItem(title: "Refresh Now", action: #selector(refreshNow), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(showPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        for item in menu.items {
            item.target = self
        }
        
        statusItem.menu = menu
    }
    
    private func updateMenu() {
        
    }
    
    @objc private func refreshNow() {
        bluetoothMonitor.updateBluetoothStatus()
    }
    
    @objc private func showPreferences() {
        if preferencesWindow == nil {
            let contentView = PreferencesView(bluetoothMonitor: bluetoothMonitor)
            preferencesWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            preferencesWindow?.contentView = NSHostingView(rootView: contentView)
            preferencesWindow?.title = "AirPods Monitor Preferences"
            preferencesWindow?.center()
        }
        
        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func quit() {
        bluetoothMonitor.stopMonitoring()
        NSApplication.shared.terminate(nil)
    }
}