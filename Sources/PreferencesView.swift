import SwiftUI

@available(macOS 10.15, *)
struct PreferencesView: View {
    @ObservedObject var bluetoothMonitor: BluetoothMonitor
    @State private var refreshInterval: Double = 15.0
    @State private var launchAtLogin: Bool = false
    @State private var useSystemProfiler: Bool = true
    @State private var showText: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("AirPods Monitor")
                    .font(.title)
                    .fontWeight(.semibold)
                Text("Preferences")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Content with tabs/sections
            VStack(alignment: .leading, spacing: 20) {
                // Refresh Interval Section
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("⏱")
                                .foregroundColor(.blue)
                            Text("Refresh Interval")
                                .font(.headline)
                        }
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Fast")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Slider(value: Binding(
                                    get: { refreshInterval },
                                    set: { newValue in
                                        refreshInterval = newValue
                                        updateRefreshInterval()
                                    }
                                ), in: 5...60, step: 5)
                                
                                Text("Slow")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("Update every \(Int(refreshInterval)) seconds")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Display Options Section
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("👁")
                                .foregroundColor(.green)
                            Text("Display Options")
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle("Show text with emoji", isOn: Binding(
                                get: { showText },
                                set: { newValue in
                                    showText = newValue
                                    updateShowText()
                                }
                            ))
                            
                            HStack {
                                Text("Preview:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if let device = bluetoothMonitor.currentDevice {
                                    Text(showText ? "\(device.profile.icon) \(device.profile.displayName)" : device.profile.icon)
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(4)
                                } else {
                                    Text(showText ? "❓ No Device" : "❓")
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(4)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                }
                
                // System Options Section
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("⚙️")
                                .foregroundColor(.orange)
                            Text("System Options")
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle("Launch at Login", isOn: Binding(
                                get: { launchAtLogin },
                                set: { newValue in
                                    launchAtLogin = newValue
                                    updateLaunchAtLogin()
                                }
                            ))
                            
                            Toggle("Use system_profiler", isOn: $useSystemProfiler)
                            
                            Text("Recommended for detailed device information")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Bottom Status Bar
            HStack {
                if let device = bluetoothMonitor.currentDevice {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("\(device.name) - \(device.profile.displayName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 8, height: 8)
                        Text("No device connected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button("Refresh") {
                    bluetoothMonitor.updateBluetoothStatus()
                }
                .buttonStyle(.borderless)
                .font(.caption)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .frame(width: 450, height: 400)
        .onAppear {
            loadPreferences()
        }
    }
    
    private func updateRefreshInterval() {
        UserDefaults.standard.set(refreshInterval, forKey: "RefreshInterval")
    }
    
    private func updateLaunchAtLogin() {
        UserDefaults.standard.set(launchAtLogin, forKey: "LaunchAtLogin")
        
        if launchAtLogin {
            addToLoginItems()
        } else {
            removeFromLoginItems()
        }
    }
    
    private func loadPreferences() {
        refreshInterval = UserDefaults.standard.object(forKey: "RefreshInterval") as? Double ?? 15.0
        launchAtLogin = UserDefaults.standard.bool(forKey: "LaunchAtLogin")
        useSystemProfiler = UserDefaults.standard.object(forKey: "UseSystemProfiler") as? Bool ?? true
        showText = UserDefaults.standard.object(forKey: "ShowText") as? Bool ?? true
    }
    
    private func updateShowText() {
        UserDefaults.standard.set(showText, forKey: "ShowText")
        NotificationCenter.default.post(name: NSNotification.Name("ShowTextPreferenceChanged"), object: nil)
    }
    
    private func addToLoginItems() {
        
    }
    
    private func removeFromLoginItems() {
        
    }
}