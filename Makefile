.PHONY: build clean test install package

APP_NAME = AirPodsMonitor
BUILD_DIR = .build
RELEASE_DIR = $(BUILD_DIR)/release

build:
	swift build -c release

test:
	swift test

clean:
	swift package clean
	rm -rf $(BUILD_DIR)
	rm -rf *.app
	rm -rf *.dmg

package: build
	mkdir -p $(APP_NAME).app/Contents/MacOS
	mkdir -p $(APP_NAME).app/Contents/Resources
	cp $(RELEASE_DIR)/$(APP_NAME) $(APP_NAME).app/Contents/MacOS/
	echo '<?xml version="1.0" encoding="UTF-8"?>' > $(APP_NAME).app/Contents/Info.plist
	echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> $(APP_NAME).app/Contents/Info.plist
	echo '<plist version="1.0">' >> $(APP_NAME).app/Contents/Info.plist
	echo '<dict>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<key>CFBundleExecutable</key>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<string>$(APP_NAME)</string>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<key>CFBundleIdentifier</key>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<string>com.airpods.monitor</string>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<key>CFBundleName</key>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<string>$(APP_NAME)</string>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<key>CFBundleVersion</key>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<string>1.0.0</string>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<key>CFBundleShortVersionString</key>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<string>1.0.0</string>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<key>CFBundlePackageType</key>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<string>APPL</string>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<key>LSUIElement</key>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<true/>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<key>NSPrincipalClass</key>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<string>NSApplication</string>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<key>NSHighResolutionCapable</key>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<true/>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<key>LSMinimumSystemVersion</key>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<string>10.15</string>' >> $(APP_NAME).app/Contents/Info.plist
	echo '</dict>' >> $(APP_NAME).app/Contents/Info.plist
	echo '</plist>' >> $(APP_NAME).app/Contents/Info.plist

install: package
	cp -r $(APP_NAME).app /Applications/

dmg: package
	hdiutil create -volname "$(APP_NAME)" -srcfolder $(APP_NAME).app -ov -format UDZO $(APP_NAME).dmg

homebrew-cask:
	@echo "# Homebrew Cask Formula"
	@echo "cask 'airpods-monitor' do"
	@echo "  version '1.0.0'"
	@echo "  sha256 :no_check"
	@echo ""
	@echo "  url 'https://github.com/yourusername/airpods-monitor/releases/download/v1.0.0/AirPodsMonitor.dmg'"
	@echo "  name 'AirPods Monitor'"
	@echo "  desc 'Real-time AirPods audio profile monitor for macOS menu bar'"
	@echo "  homepage 'https://github.com/yourusername/airpods-monitor'"
	@echo ""
	@echo "  depends_on macos: '>= :catalina'"
	@echo ""
	@echo "  app 'AirPodsMonitor.app'"
	@echo ""
	@echo "  zap trash: ["
	@echo "    '~/Library/Preferences/com.airpods.monitor.plist',"
	@echo "  ]"
	@echo "end"