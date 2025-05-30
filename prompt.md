Summary
Create a lightweight macOS menu-bar app (or SwiftBar/BitBar plugin) that continuously monitors the connected AirPods Pro audio profile and indicates “🎧 Music (A2DP/AAC)” versus “📞 Call (HFP/SCO/mSBC)” in real time. The tool should work on macOS Catalina (10.15) and later, allow configurable refresh intervals, support AirPods Pro and similar headsets, and be easily installable (e.g. via Homebrew).

1. Functional Requirements
Detect Active Bluetooth Audio Profile

Query system_profiler SPBluetoothDataType and parse the “Audio Codec” field to distinguish AAC/A2DP from SCO/mSBC (Hands-Free) 
Stack Overflow
.

Optionally, fall back to a lightweight CLI approach using blueutil for faster repeated queries 
GitHub
.

Real-Time Updates

Poll at a configurable interval (default every 15 s; user-configurable from 5 s–60 s).

Update menu-bar indicator immediately upon a mode switch (e.g., when initiating/ending a call).

Menu-Bar Indicator

Display an icon and label: e.g. 🎧 “Music” when in A2DP/AAC, 📞 “Call” when in HFP/SCO.

Support dark/light menu-bar modes.

Provide a click menu with:

Current device name (e.g., “AirPods Pro”).

Active codec/profile detail.

Manual “Refresh Now” action.

“Preferences…” to adjust refresh interval.

Configuration & Persistence

Store settings (refresh interval, fallback CLI vs. system_profiler) in a preferences file or UserDefaults.

Provide a simple Preferences window in native SwiftUI/AppKit.

2. Data Sources & APIs
system_profiler SPBluetoothDataType

Parses detailed Bluetooth info, including “Audio Codec” for connected devices 
Stack Overflow
.

blueutil (optional)

A Homebrew-installable CLI that leverages private IOBluetooth APIs for faster device queries (paired/connect status, etc.) 
GitHub
.

CoreBluetooth (if deeper integration desired)

Use for device discovery; not strictly required for codec detection but could power future BLE features 
Medium
.

Bluetooth Explorer (debugging only)

Apple’s Xcode Additional Tools app that shows active codec in Tools → Audio Graphs; use during development to validate parsing logic 
Ask Different
.

3. Architecture & Technology Stack
Language & Framework

Swift 5+, using SwiftUI for Preferences and AppKit for the menu-bar item.

Alternatively, a shell script plugin for SwiftBar/BitBar: bash + system_profiler + JSON parsing (e.g., jq) 
Podfeet Podcasts
.

Polling Service

Implement as a background thread or Dispatch source timer; ensure UI updates occur on the main thread.

Parsing Logic

Regex or JSON (with system_profiler -json) to extract Audio Codec value.

Map:

AAC → A2DP/Music

SCO or mSBC → Hands-Free/Call

Error Handling

Detect no device connected; show “No Device” state.

Fallback to CLI only if system_profiler fails.

Log parse errors for debugging.

Packaging & Distribution

Build signed, notarized .app bundle.

Publish a Homebrew “cask” or “formula” for easy installation.

Optionally distribute as a SwiftBar plugin directory.

4. UI/UX & Accessibility
Menu-Bar Icon:

Two states: “music” icon (e.g., 🎧) and “call” icon (e.g., 📞).

Menu:

Show device name, current profile, last refresh time, and Preferences link.

Preferences Window:

Slider or dropdown for refresh interval.

Toggle: Use system_profiler vs. blueutil fallback.

“Launch at Login” toggle.

Accessibility:

Provide VoiceOver labels (“AirPods Pro in Music mode”).

5. Testing & Validation
Unit Tests

Mock system_profiler JSON outputs for various codecs.

Test parsing functions for AAC vs. SCO detection.

Integration Tests

With actual AirPods Pro on macOS 11–14, verify real transitions:

Play music → “Music” state.

Initiate Zoom/FaceTime call → “Call” state.

Performance

Ensure polling logic doesn’t spike CPU or memory.

Compare system_profiler vs. blueutil latency.

6. Edge Cases & Future Enhancements
Multiple Devices:

If multiple headsets connected, allow selecting primary in Preferences.

Other Codecs:

Detect and display aptX/LDAC if Apple restores support 
Gist
.

Noise Control Toggle:

Integrate NoiseBuddy style ANC/Transparency toggles in menu bar as future feature 
GitHub
.

Notifications:

Optional macOS notification when mode switches.

7. Documentation & Support
README:

Installation steps (Homebrew, direct download).

Usage examples (menu-bar screenshots).

Troubleshooting section (debugging via Bluetooth Explorer).

LICENSE:

MIT or Apache 2.0 for open-source distribution.

Issue Tracker:

Template for “mode not detected” bugs; ask users to attach system_profiler JSON.