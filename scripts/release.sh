#!/bin/bash

# AirPods Monitor Release Script
# Usage: ./scripts/release.sh [version]

set -e

VERSION=${1:-"1.0.0"}
REPO_NAME="airpods-monitor"

echo "🎧 AirPods Monitor Release Script"
echo "================================="
echo ""

# Validate version format
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Invalid version format. Use semantic versioning (e.g., 1.0.1)"
    exit 1
fi

echo "📋 Release Checklist for v$VERSION"
echo ""

# Check if we're in the right directory
if [[ ! -f "Package.swift" ]]; then
    echo "❌ Please run this script from the project root directory"
    exit 1
fi

# Check for uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
    echo "⚠️  You have uncommitted changes. Please commit or stash them first."
    git status --short
    exit 1
fi

# Check if tag already exists
if git rev-parse "v$VERSION" >/dev/null 2>&1; then
    echo "❌ Tag v$VERSION already exists!"
    exit 1
fi

echo "✅ Pre-flight checks passed"
echo ""

# Run tests
echo "🧪 Running tests..."
swift test || {
    echo "❌ Tests failed! Please fix before releasing."
    exit 1
}

echo "✅ All tests passed"
echo ""

# Build release
echo "🔨 Building release..."
swift build -c release || {
    echo "❌ Release build failed!"
    exit 1
}

echo "✅ Release build successful"
echo ""

# Package app
echo "📦 Packaging app..."
make clean
make package || {
    echo "❌ Packaging failed!"
    exit 1
}

echo "✅ App packaged successfully"
echo ""

# Create ZIP
echo "📦 Creating ZIP archive..."
zip -r "AirPodsMonitor-v$VERSION.app.zip" AirPodsMonitor.app || {
    echo "❌ ZIP creation failed!"
    exit 1
}

echo "✅ ZIP created: AirPodsMonitor-v$VERSION.app.zip"
echo ""

# Generate checksums
echo "🔐 Generating checksums..."
shasum -a 256 "AirPodsMonitor-v$VERSION.app.zip" > "AirPodsMonitor-v$VERSION.app.zip.sha256"
SHA256=$(cat "AirPodsMonitor-v$VERSION.app.zip.sha256" | cut -d' ' -f1)

echo "✅ SHA256: $SHA256"
echo ""

# Generate Homebrew Cask
echo "🍺 Generating Homebrew Cask..."
cat > "airpods-monitor-v$VERSION.rb" << EOF
cask "airpods-monitor" do
  version "$VERSION"
  sha256 "$SHA256"

  url "https://github.com/yourusername/$REPO_NAME/releases/download/v$VERSION/AirPodsMonitor-v$VERSION.app.zip"
  name "AirPods Monitor"
  desc "Real-time AirPods audio profile monitor for macOS menu bar"
  homepage "https://github.com/yourusername/$REPO_NAME"

  depends_on macos: ">= :catalina"

  app "AirPodsMonitor.app"

  zap trash: [
    "~/Library/Preferences/com.airpods.monitor.plist",
  ]
end
EOF

echo "✅ Homebrew Cask generated: airpods-monitor-v$VERSION.rb"
echo ""

echo "🎉 Release v$VERSION prepared successfully!"
echo ""
echo "📋 Next Steps:"
echo "1. Review the generated files:"
echo "   - AirPodsMonitor-v$VERSION.app.zip"
echo "   - AirPodsMonitor-v$VERSION.app.zip.sha256"
echo "   - airpods-monitor-v$VERSION.rb"
echo ""
echo "2. Test the ZIP manually:"
echo "   unzip AirPodsMonitor-v$VERSION.app.zip && open AirPodsMonitor.app"
echo ""
echo "3. Create GitHub release:"
echo "   - Go to GitHub Actions"
echo "   - Run 'Manual Release' workflow"
echo "   - Enter version: $VERSION"
echo ""
echo "4. Or create release manually:"
echo "   git tag -a v$VERSION -m 'Release v$VERSION'"
echo "   git push origin v$VERSION"
echo ""
echo "🌟 Happy releasing!"