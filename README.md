# 🎧 AirPods Monitor

**The most elegant solution for AirPods audio profile monitoring on macOS**

A beautiful, lightweight menu bar app that intelligently detects and displays your AirPods audio mode in real-time. Know instantly whether you're in high-quality music mode (🎧) or hands-free call mode (📞) without guessing.

## ✨ **Why AirPods Monitor?**

- **🎯 Instant Visual Feedback**: See your audio profile at a glance - no more wondering why your music sounds muffled
- **🔬 Intelligent Detection**: Uses advanced system profiling to accurately detect AAC vs SCO/mSBC codecs
- **🎨 Beautifully Designed**: Native SwiftUI interface that feels right at home on macOS
- **⚡ Lightweight & Fast**: Minimal CPU usage with smart fallback mechanisms
- **🔧 Highly Configurable**: Customizable refresh rates, display options, and detection methods
- **🌟 Universal Compatibility**: Works with AirPods, Beats, and any Bluetooth headphones

## 🚀 **Key Features**

- **Real-time monitoring**: Continuously tracks active Bluetooth audio profile with configurable intervals
- **Smart profile detection**: Accurately distinguishes between music (A2DP/AAC) and call (HFP/SCO/mSBC) modes
- **Flexible display options**: Choose between "🎧 Music" or minimalist "🎧" emoji-only mode
- **Robust fallback system**: Primary `system_profiler` detection with `blueutil` backup
- **Professional preferences UI**: Organized, color-coded settings with live preview
- **Menu bar integration**: Clean, unobtrusive indicator that respects your workspace
- **Native macOS experience**: Built with Swift 5+, SwiftUI, and AppKit for optimal performance

## Requirements

- macOS 10.15 (Catalina) or later
- AirPods Pro or compatible Bluetooth headphones
- Optional: `blueutil` for faster fallback detection

## 📥 **Installation**

### 🍺 **Using Homebrew (Recommended)**

```bash
# Install blueutil for enhanced functionality (optional)
brew install blueutil

# Install AirPods Monitor (coming soon)
brew install --cask airpods-monitor
```

### 📦 **Manual Installation**

1. **Download** `AirPodsMonitor.app.zip` from [GitHub Releases](https://github.com/sooth/AirPods_Monitor/releases)
2. **Unzip** the downloaded file
3. **Drag** `AirPods Monitor.app` to your Applications folder
4. **Launch** from Applications or Spotlight
5. **Grant Permissions** if prompted (for Bluetooth access)
6. **Enjoy** instant audio profile monitoring!

## Usage

1. **Launch**: Start the app from Applications or set it to launch at login
2. **Menu Bar**: Look for the 🎧/📞 icon in your menu bar
3. **Status**: The icon shows current audio profile:
   - 🎧 Music: High-quality audio (AAC/A2DP)
   - 📞 Call: Hands-free audio (SCO/mSBC)
   - ❓ No Device: No AirPods connected

4. **Menu**: Click the menu bar icon to see:
   - Device name and current codec
   - Manual refresh option
   - Preferences window
   - Quit option

## ⚙️ **Configuration**

Access the beautifully designed preferences by clicking the menu bar icon and selecting "Preferences...":

### ⏱ **Refresh Interval**
- **Smart Polling**: Adjustable frequency from 5-60 seconds
- **Performance Optimized**: Balance between responsiveness and battery life
- **Live Updates**: See changes instantly without restart

### 👁 **Display Options**
- **Text + Emoji Mode**: Full display like "🎧 Music" or "📞 Call"
- **Emoji Only Mode**: Minimalist "🎧" or "📞" for clean menu bars
- **Live Preview**: See exactly how your menu bar will look
- **Instant Switching**: Changes apply immediately

### ⚙️ **System Options**
- **Launch at Login**: Seamlessly start with macOS
- **Detection Method**: Choose between detailed `system_profiler` or faster `blueutil`
- **Smart Fallbacks**: Automatic failover ensures reliable detection

### 📊 **Real-time Status**
- **Connection Indicator**: Visual status of your current device
- **Device Information**: See connected device name and current profile
- **Manual Refresh**: Force update with one click

## How It Works

The app uses two methods to detect audio profiles:

1. **Primary**: `system_profiler SPBluetoothDataType` - Parses detailed Bluetooth information including audio codecs
2. **Fallback**: `blueutil` - Faster CLI tool for basic connection status

### Audio Profile Detection

- **AAC/A2DP**: High-quality stereo audio for music
- **SCO/mSBC**: Compressed audio with microphone for calls
- **Unknown**: Fallback when codec cannot be determined

## 🛠 **Development**

**Built with modern macOS development best practices**

### **Building from Source**

```bash
# Clone the repository
git clone https://github.com/sooth/AirPods_Monitor.git
cd AirPods_Monitor

# Build with Swift Package Manager
swift build -c release

# Run comprehensive test suite
swift test

# Package for distribution
make package
```

### **Architecture Highlights**
- **🏗 Swift Package Manager**: Modern dependency management
- **🧪 Comprehensive Testing**: Unit tests for all core functionality  
- **📦 Automated Packaging**: One-command app bundle creation
- **🔍 Debug Tools**: Built-in detection testing scripts

### **Testing & Validation**

```bash
# Run all unit tests
swift test

# Test device detection manually
./test_detection.swift

# Package and install locally
make package && make install
```

### **Creating Releases**

```bash
# Option 1: Automatic via git tag (Recommended)
./scripts/create-github-release.sh 1.0.1

# Option 2: Manual GitHub Actions
# Go to GitHub Actions → Manual Release → Enter version

# Option 3: Local preparation only
./scripts/release.sh 1.0.1
```

### **Icon Management**

```bash
# Check if icon exists
make icon

# Generate icon from airpodsmonitor.png (1024x1024 PNG)
make generate-icon

# Package includes the app icon automatically
make package
```

### **Development Tools**
- **Bluetooth Explorer**: Use Xcode Additional Tools for codec validation
- **System Profiler**: Test detection with `system_profiler SPBluetoothDataType -json`
- **Audio Testing**: Switch between music and calls to verify profile detection

## Troubleshooting

### App Not Detecting AirPods

1. Ensure AirPods are connected via Bluetooth Settings
2. Try manual refresh from the menu
3. Check that `system_profiler` returns Bluetooth data:
   ```bash
   system_profiler SPBluetoothDataType -json
   ```

### Performance Issues

1. Increase refresh interval in Preferences
2. Install `blueutil` for faster fallback detection:
   ```bash
   brew install blueutil
   ```

### Menu Bar Icon Missing

1. Check System Preferences > Dock & Menu Bar > Menu Bar
2. Restart the app
3. Grant necessary permissions in System Preferences > Security & Privacy

## 🤝 **Contributing**

We welcome contributions! This project showcases modern Swift development practices.

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Add tests** for new functionality
4. **Ensure** all tests pass (`swift test`)
5. **Submit** a pull request with a clear description

### **What We'd Love**
- 🎨 UI/UX improvements
- 🔧 Additional audio codec support
- 📱 iOS companion app
- 🌍 Localization support
- ⚡ Performance optimizations

## 📄 **License**

MIT License - see [LICENSE](LICENSE) for details.

**Free to use, modify, and distribute. Built with ❤️ for the macOS community.**

## 🙏 **Acknowledgments**

This project leverages the best of macOS development:

- **[blueutil](https://github.com/toy/blueutil)**: Excellent Bluetooth CLI utilities
- **macOS system_profiler**: Apple's comprehensive system information tool
- **SwiftUI & AppKit**: Native macOS UI frameworks for optimal user experience
- **Swift Package Manager**: Modern dependency management and build system

---

**⭐ If AirPods Monitor helps improve your workflow, please consider starring the repo!**