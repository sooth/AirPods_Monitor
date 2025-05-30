import Foundation

enum AudioProfile {
    case music
    case call
    case unknown
    
    var displayName: String {
        switch self {
        case .music: return "Music"
        case .call: return "Call"
        case .unknown: return "Unknown"
        }
    }
    
    var icon: String {
        switch self {
        case .music: return "🎧"
        case .call: return "📞"
        case .unknown: return "❓"
        }
    }
}

struct BluetoothDevice {
    let name: String
    let audioCodec: String
    let profile: AudioProfile
}

class BluetoothMonitor: ObservableObject, @unchecked Sendable {
    @Published var currentDevice: BluetoothDevice?
    @Published var isConnected: Bool = false
    
    private var timer: Timer?
    private let refreshInterval: TimeInterval
    
    init(refreshInterval: TimeInterval = 15.0) {
        self.refreshInterval = refreshInterval
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { _ in
            self.updateBluetoothStatus()
        }
        updateBluetoothStatus()
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    func updateBluetoothStatus() {
        Task {
            let device = await getBluetoothAudioDevice()
            DispatchQueue.main.async {
                self.currentDevice = device
                self.isConnected = device != nil
            }
        }
    }
    
    private func getBluetoothAudioDevice() async -> BluetoothDevice? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/system_profiler")
        process.arguments = ["SPBluetoothDataType", "-json"]
        
        let pipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = pipe
        process.standardError = errorPipe
        
        do {
            try process.run()
            
            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds
                if process.isRunning {
                    process.terminate()
                    throw TimeoutError()
                }
            }
            
            process.waitUntilExit()
            timeoutTask.cancel()
            
            if process.terminationStatus != 0 {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                print("system_profiler failed with status \(process.terminationStatus): \(errorString)")
                return try await fallbackBluetoothCheck()
            }
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if data.isEmpty {
                print("system_profiler returned empty data, trying fallback")
                return try await fallbackBluetoothCheck()
            }
            
            return parseBluetoothData(data)
        } catch {
            print("Error running system_profiler: \(error)")
            return try? await fallbackBluetoothCheck()
        }
    }
    
    private func fallbackBluetoothCheck() async throws -> BluetoothDevice? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["blueutil"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            if process.terminationStatus == 0 {
                return try await getDeviceWithBlueutil()
            } else {
                print("blueutil not found, falling back to basic detection")
                return nil
            }
        } catch {
            print("Fallback check failed: \(error)")
            return nil
        }
    }
    
    private func getDeviceWithBlueutil() async throws -> BluetoothDevice? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/local/bin/blueutil")
        process.arguments = ["--connected"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        if output.lowercased().contains("airpods") {
            return BluetoothDevice(name: "AirPods", audioCodec: "Unknown", profile: .unknown)
        }
        
        return nil
    }

struct TimeoutError: Error {}
    
    private func parseBluetoothData(_ data: Data) -> BluetoothDevice? {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let bluetooth = json["SPBluetoothDataType"] as? [[String: Any]] else {
                return nil
            }
            
            for deviceGroup in bluetooth {
                if let connectedDevices = deviceGroup["device_connected"] as? [[String: Any]] {
                    for deviceEntry in connectedDevices {
                        for (deviceName, deviceInfo) in deviceEntry {
                            if let deviceDict = deviceInfo as? [String: Any],
                               let minorType = deviceDict["device_minorType"] as? String,
                               minorType == "Headphones" {
                                
                                // Try to get audio codec, but provide fallback
                                let audioCodec = deviceDict["device_audio_codec"] as? String ?? "Unknown"
                                let profile = determineAudioProfile(from: audioCodec)
                                
                                return BluetoothDevice(name: deviceName, audioCodec: audioCodec, profile: profile)
                            }
                        }
                    }
                }
            }
            
            return nil
        } catch {
            print("Error parsing Bluetooth data: \(error)")
            return nil
        }
    }
    
    func determineAudioProfile(from codec: String) -> AudioProfile {
        let codecLower = codec.lowercased()
        
        if codecLower.contains("aac") || codecLower.contains("a2dp") {
            return .music
        } else if codecLower.contains("sco") || codecLower.contains("msbc") || codecLower.contains("hfp") {
            return .call
        } else {
            // Fallback: try to determine based on system audio state
            return determineProfileByAudioState()
        }
    }
    
    private func determineProfileByAudioState() -> AudioProfile {
        // Check the audio output sample rate to determine quality mode
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/system_profiler")
        process.arguments = ["SPAudioDataType", "-json"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let audioData = json["SPAudioDataType"] as? [[String: Any]] {
                
                for audioDevice in audioData {
                    if let audioItems = audioDevice["_items"] as? [[String: Any]] {
                        for item in audioItems {
                            if let name = item["_name"] as? String,
                               (name.lowercased().contains("airpods") || 
                                name.lowercased().contains("beats") ||
                                name.lowercased().contains("headphones")),
                               let isDefaultOutput = item["coreaudio_default_audio_output_device"] as? String,
                               isDefaultOutput == "spaudio_yes",
                               let sampleRate = item["coreaudio_device_srate"] as? Int {
                                
                                // Higher sample rates (44.1kHz, 48kHz) indicate music mode
                                // Lower sample rates (8kHz, 16kHz, 24kHz) indicate call mode
                                if sampleRate >= 44100 {
                                    return .music
                                } else {
                                    return .call
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            print("Error checking audio state: \(error)")
        }
        
        // Default to music mode for connected headphones
        return .music
    }
}