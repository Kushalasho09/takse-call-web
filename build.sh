#!/bin/bash
set -e

echo "🚀 Setting up Flutter SDK on Vercel..."
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter
fi

export PATH="$PATH:$(pwd)/flutter/bin"
flutter config --no-analytics

echo "📦 Installing Flutter dependencies..."
flutter pub get

echo "🔨 Compiling Flutter Web release bundle..."
flutter build web --release

echo "✅ Flutter Web build finished! Serving from build/web"
