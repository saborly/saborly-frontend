#!/bin/sh
set -e

echo "🚀 Installing dependencies..."
apk add --no-cache curl tar xz bash

echo "📦 Installing Flutter..."
curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.25.1-stable.tar.xz -o flutter.tar.xz
tar xf flutter.tar.xz
export PATH="$PWD/flutter/bin:$PATH"

echo "🔧 Setting up Flutter..."
flutter config --enable-web

echo "📚 Getting dependencies..."
flutter pub get

echo "🏗️ Building web..."
flutter build web --release --no-web-resources-cdn --no-tree-shake-icons

echo "✅ Build completed!"