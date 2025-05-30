import XCTest
@testable import AirPodsMonitor

final class BluetoothMonitorTests: XCTestCase {
    
    // Test pure codec detection (without system fallback)
    func testCodecDetectionAAC() {
        let monitor = BluetoothMonitor()
        let profile = monitor.determineAudioProfileFromCodec("AAC")
        XCTAssertEqual(profile, .music)
    }
    
    func testCodecDetectionSCO() {
        let monitor = BluetoothMonitor()
        let profile = monitor.determineAudioProfileFromCodec("SCO")
        XCTAssertEqual(profile, .call)
    }
    
    func testCodecDetectionMSBC() {
        let monitor = BluetoothMonitor()
        let profile = monitor.determineAudioProfileFromCodec("mSBC")
        XCTAssertEqual(profile, .call)
    }
    
    func testCodecDetectionA2DP() {
        let monitor = BluetoothMonitor()
        let profile = monitor.determineAudioProfileFromCodec("A2DP")
        XCTAssertEqual(profile, .music)
    }
    
    func testCodecDetectionHFP() {
        let monitor = BluetoothMonitor()
        let profile = monitor.determineAudioProfileFromCodec("HFP")
        XCTAssertEqual(profile, .call)
    }
    
    func testCodecDetectionUnknown() {
        let monitor = BluetoothMonitor()
        let profile = monitor.determineAudioProfileFromCodec("Unknown")
        XCTAssertNil(profile) // Unknown codecs return nil
    }
    
    func testCodecDetectionCaseInsensitive() {
        let monitor = BluetoothMonitor()
        
        // Test case insensitive matching
        XCTAssertEqual(monitor.determineAudioProfileFromCodec("aac"), .music)
        XCTAssertEqual(monitor.determineAudioProfileFromCodec("AAC"), .music)
        XCTAssertEqual(monitor.determineAudioProfileFromCodec("sco"), .call)
        XCTAssertEqual(monitor.determineAudioProfileFromCodec("SCO"), .call)
    }
    
    // Test full profile detection (with system fallback) - these may vary based on system state
    func testFullProfileDetectionAAC() {
        let monitor = BluetoothMonitor()
        let profile = monitor.determineAudioProfile(from: "AAC")
        XCTAssertEqual(profile, .music) // AAC should always be music
    }
    
    func testFullProfileDetectionSCO() {
        let monitor = BluetoothMonitor()
        let profile = monitor.determineAudioProfile(from: "SCO")
        XCTAssertEqual(profile, .call) // SCO should always be call
    }
    
    func testBluetoothDeviceCreation() {
        let device = BluetoothDevice(name: "AirPods Pro", audioCodec: "AAC", profile: .music)
        XCTAssertEqual(device.name, "AirPods Pro")
        XCTAssertEqual(device.audioCodec, "AAC")
        XCTAssertEqual(device.profile, .music)
    }
    
    func testAudioProfileDisplayNames() {
        XCTAssertEqual(AudioProfile.music.displayName, "Music")
        XCTAssertEqual(AudioProfile.call.displayName, "Call")
        XCTAssertEqual(AudioProfile.unknown.displayName, "Unknown")
    }
    
    func testAudioProfileIcons() {
        XCTAssertEqual(AudioProfile.music.icon, "🎧")
        XCTAssertEqual(AudioProfile.call.icon, "📞")
        XCTAssertEqual(AudioProfile.unknown.icon, "❓")
    }
}