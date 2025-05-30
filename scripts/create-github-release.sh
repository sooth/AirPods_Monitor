#!/bin/bash

# GitHub Release Creation Script
# Usage: ./scripts/create-github-release.sh [version]

set -e

VERSION=${1:-"1.0.0"}

echo "🎧 Creating GitHub Release for AirPods Monitor v$VERSION"
echo "==========================================================="
echo ""

# Validate version format
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Invalid version format. Use semantic versioning (e.g., 1.0.1)"
    exit 1
fi

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

# Create and push tag
echo "🏷️  Creating git tag..."
git tag -a "v$VERSION" -m "Release v$VERSION"

echo "📤 Pushing tag to GitHub..."
git push origin "v$VERSION"

echo "✅ Tag v$VERSION created and pushed successfully!"
echo ""

echo "🚀 Release Creation Options:"
echo ""
echo "1. 🤖 Automatic Release (Recommended):"
echo "   The tag push will trigger automatic release creation via GitHub Actions."
echo "   Check: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^/]*\)\.git/\1/')/actions"
echo ""
echo "2. 📱 Manual Release:"
echo "   Go to: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^/]*\)\.git/\1/')/actions"
echo "   Run the 'Manual Release' workflow with version: $VERSION"
echo ""
echo "3. 🌐 GitHub Web Interface:"
echo "   Go to: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^/]*\)\.git/\1/')/releases/new?tag=v$VERSION"
echo ""

echo "⏳ Waiting for automatic release creation..."
echo "   This may take 2-3 minutes to complete."
echo ""
echo "🔗 Monitor progress:"
echo "   https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^/]*\)\.git/\1/')/actions"
echo ""
echo "🎉 Release v$VERSION initiated successfully!"