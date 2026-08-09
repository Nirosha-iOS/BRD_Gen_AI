#!/bin/bash

# Start Flutter Frontend
cd "$(dirname "$0")/frontend"

echo "🚀 Starting Flutter Web App"
flutter run -d chrome

