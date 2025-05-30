.PHONY: build clean test install package zip release icon

APP_NAME = AirPodsMonitor
BUILD_DIR = .build
RELEASE_DIR = $(BUILD_DIR)/release
VERSION ?= 1.0.0

build:
	swift build -c release

test:
	swift test

icon:
	@if [ ! -f "$(APP_NAME).icns" ]; then \
		echo "⚠️  $(APP_NAME).icns not found. Please create it from airpodsmonitor.png"; \
		echo "   1. Place your 1024x1024 PNG icon as 'airpodsmonitor.png'"; \
		echo "   2. Run: make generate-icon"; \
	else \
		echo "✅ Icon file $(APP_NAME).icns already exists"; \
	fi

generate-icon:
	@echo "🎨 Generating app icon from airpodsmonitor.png..."
	mkdir -p $(APP_NAME).iconset
	sips -z 16 16 airpodsmonitor.png --out $(APP_NAME).iconset/icon_16x16.png
	sips -z 32 32 airpodsmonitor.png --out $(APP_NAME).iconset/icon_16x16@2x.png
	sips -z 32 32 airpodsmonitor.png --out $(APP_NAME).iconset/icon_32x32.png
	sips -z 64 64 airpodsmonitor.png --out $(APP_NAME).iconset/icon_32x32@2x.png
	sips -z 128 128 airpodsmonitor.png --out $(APP_NAME).iconset/icon_128x128.png
	sips -z 256 256 airpodsmonitor.png --out $(APP_NAME).iconset/icon_128x128@2x.png
	sips -z 256 256 airpodsmonitor.png --out $(APP_NAME).iconset/icon_256x256.png
	sips -z 512 512 airpodsmonitor.png --out $(APP_NAME).iconset/icon_256x256@2x.png
	sips -z 512 512 airpodsmonitor.png --out $(APP_NAME).iconset/icon_512x512.png
	sips -z 1024 1024 airpodsmonitor.png --out $(APP_NAME).iconset/icon_512x512@2x.png
	iconutil -c icns $(APP_NAME).iconset --output $(APP_NAME).icns
	rm -rf $(APP_NAME).iconset
	@echo "✅ Created $(APP_NAME).icns"

clean:
	swift package clean
	rm -rf $(BUILD_DIR)
	rm -rf *.app
	rm -rf *.dmg
	rm -rf *.iconset

package: build
	mkdir -p $(APP_NAME).app/Contents/MacOS
	mkdir -p $(APP_NAME).app/Contents/Resources
	cp $(RELEASE_DIR)/$(APP_NAME) $(APP_NAME).app/Contents/MacOS/
	cp $(APP_NAME).icns $(APP_NAME).app/Contents/Resources/
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
	echo '	<string>$(VERSION)</string>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<key>CFBundleShortVersionString</key>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<string>$(VERSION)</string>' >> $(APP_NAME).app/Contents/Info.plist
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
	echo '	<key>CFBundleIconFile</key>' >> $(APP_NAME).app/Contents/Info.plist
	echo '	<string>$(APP_NAME).icns</string>' >> $(APP_NAME).app/Contents/Info.plist
	echo '</dict>' >> $(APP_NAME).app/Contents/Info.plist
	echo '</plist>' >> $(APP_NAME).app/Contents/Info.plist

install: package
	cp -r $(APP_NAME).app /Applications/

zip: package
	zip -r $(APP_NAME)-v$(VERSION).app.zip $(APP_NAME).app
	@echo "✅ Created $(APP_NAME)-v$(VERSION).app.zip"

release: clean test package zip
	@echo "🎉 Release v$(VERSION) ready!"
	@echo "📦 Files created:"
	@echo "  - $(APP_NAME).app"
	@echo "  - $(APP_NAME)-v$(VERSION).app.zip"
	@echo ""
	@echo "📋 Next steps:"
	@echo "  1. Test the ZIP: unzip $(APP_NAME)-v$(VERSION).app.zip"
	@echo "  2. Run GitHub Action 'Manual Release' with version $(VERSION)"
	@echo "  3. Or use: ./scripts/release.sh $(VERSION)"

homebrew-cask:
	@SHA256=$$(shasum -a 256 $(APP_NAME)-v$(VERSION).app.zip 2>/dev/null | cut -d' ' -f1 || echo ":no_check"); \
	echo "# Homebrew Cask Formula"; \
	echo "cask 'airpods-monitor' do"; \
	echo "  version '$(VERSION)'"; \
	echo "  sha256 '$$SHA256'"; \
	echo ""; \
	echo "  url 'https://github.com/sooth/AirPods_Monitor/releases/download/v$(VERSION)/AirPodsMonitor-v$(VERSION).app.zip'"; \
	echo "  name 'AirPods Monitor'"; \
	echo "  desc 'Real-time AirPods audio profile monitor for macOS menu bar'"; \
	echo "  homepage 'https://github.com/sooth/AirPods_Monitor'"; \
	echo ""; \
	echo "  depends_on macos: '>= :catalina'"; \
	echo ""; \
	echo "  app 'AirPodsMonitor.app'"; \
	echo ""; \
	echo "  zap trash: ["; \
	echo "    '~/Library/Preferences/com.airpods.monitor.plist',"; \
	echo "  ]"; \
	echo "end"