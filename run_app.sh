#!/bin/bash
export PATH="$HOME/flutter/bin:$PATH"
cd /home/team/shared/pure_dart_app
flutter pub get
# Since this is a headless environment, we can't actually 'run' it, 
# but we can build it for web or linux.
echo "Building for Web..."
flutter build web --release
echo "Build complete. Output in build/web/"
