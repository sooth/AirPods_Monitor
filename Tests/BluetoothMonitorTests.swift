import XCTest
@testable import AirPodsMonitor

final class BluetoothMonitorTests: XCTestCase {
    
    func testAudioProfileFromAAC() {
        let monitor = BluetoothMonitor()
        let profile = monitor.determineAudioProfile(from: "AAC")
        XCTAssertEqual(profile, .music)
    }
    
    func testAudioProfileFromSCO() {
        let monitor = BluetoothMonitor()
        let profile = monitor.determineAudioProfile(from: "SCO")
        XCTAssertEqual(profile, .call)
    }
    
    func testAudioProfileFromMSBC() {
        let monitor = BluetoothMonitor()
        let profile = monitor.determineAudioProfile(from: "mSBC")
        XCTAssertEqual(profile, .call)
    }
    
    func testAudioProfileFromUnknown() {
        let monitor = BluetoothMonitor()
        let profile = monitor.determineAudioProfile(from: "Unknown")
        XCTAssertEqual(profile, .unknown)
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