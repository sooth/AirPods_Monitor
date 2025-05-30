#!/usr/bin/env swift

import Foundation

func testAudioProfile() {
    print("🔍 Checking audio output sample rate...")
    
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
                           (name.lowercased().contains("beats") || name.lowercased().contains("airpods")) {
                            
                            let isOutput = item["coreaudio_device_output"] != nil
                            let isInput = item["coreaudio_device_input"] != nil
                            let isDefaultOutput = item["coreaudio_default_audio_output_device"] as? String == "spaudio_yes"
                            let sampleRate = item["coreaudio_device_srate"] as? Int ?? 0
                            
                            print("🎧 Found: \(name)")
                            print("   Output: \(isOutput), Input: \(isInput)")
                            print("   Default Output: \(isDefaultOutput)")
                            print("   Sample Rate: \(sampleRate) Hz")
                            
                            if isDefaultOutput && sampleRate >= 44100 {
                                print("   → Profile: 🎧 Music (High quality: \(sampleRate) Hz)")
                            } else if isDefaultOutput && sampleRate < 44100 {
                                print("   → Profile: 📞 Call (Low quality: \(sampleRate) Hz)")
                            }
                            print("")
                        }
                    }
                }
            }
        }
    } catch {
        print("❌ Error: \(error)")
    }
}

testAudioProfile()