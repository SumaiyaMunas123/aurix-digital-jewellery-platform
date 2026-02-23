#!/bin/bash

echo "🔍 FLUTTER SETUP DIAGNOSTIC"
echo "══════════════════════════════════════════════════════════════"

echo ""
echo "1. Checking Flutter Installation..."
if command -v flutter &> /dev/null; then
    echo "   ✅ Flutter is installed"
    flutter --version
else
    echo "   ❌ Flutter is NOT installed"
    echo "   📝 Run: brew install flutter"
fi

echo ""
echo "2. Checking Dart Installation..."
if command -v dart &> /dev/null; then
    echo "   ✅ Dart is installed"
    dart --version
else
    echo "   ❌ Dart is NOT installed"
fi

echo ""
echo "3. Checking Current Directory..."
if [ -f "pubspec.yaml" ]; then
    echo "   ✅ Found pubspec.yaml in current directory"
    echo "   📂 This is a Flutter project!"
else
    echo "   ❌ No pubspec.yaml found"
    echo "   📝 You might not be in a Flutter project directory"
    echo "   📝 Run: ls -la to see what's here"
fi

echo ""
echo "4. Checking http dependency in pubspec.yaml..."
if [ -f "pubspec.yaml" ]; then
    if grep -q "http:" pubspec.yaml; then
        echo "   ✅ http dependency found"
    else
        echo "   ❌ http dependency NOT found"
        echo "   📝 You need to add: http: ^1.2.0"
    fi
fi

echo ""
echo "5. Checking Flutter SDK Status..."
if [ -f "pubspec.yaml" ]; then
    flutter doctor
else
    echo "   📝 Run this in a Flutter project directory"
fi

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "✅ Diagnostic Complete!"

