# Mirror App

A simple multiplatform mirror app for iOS and macOS. Uses your device's camera to display a real-time mirror view on screen.

> **Note:** This is my first Swift app for iOS/macOS, so be kind! 😅

## Features

- 📱 **iOS & macOS support** - Single codebase for both platforms
- 🎥 **Real-time mirror display** - Smooth camera feed with customizable mirroring
- 📸 **Snapshot capture** - Save photos directly to your photo library (iOS) or file system (macOS)
- 🎛️ **Camera selection** - Choose from built-in cameras, external USB webcams, or Continuity Camera
- 🔄 **Mirror toggle** - Flip the camera view horizontally on/off
- 💾 **Persistent settings** - Your camera and mirror preferences are saved
- 🎨 **Clean interface** - Fullscreen view with minimal UI
- 🔐 **Proper permissions** - Handles camera and photo library access correctly

## Requirements

**For iOS:**
- iOS 15.0 or later
- Xcode 15.0 or later
- An iOS device with a front-facing camera (simulator won't work)

**For macOS:**
- macOS 13.0 or later
- Xcode 15.0 or later
- A Mac with a built-in or external webcam

## Installation

### Building for iOS

1. Open `MirrorApp.xcodeproj` in Xcode
2. Select the **MirrorApp** target (for iOS)
3. Connect your iOS device via USB
4. Select your device from the device menu (not simulator)
5. Update signing if needed:
   - Select the project in the navigator
   - Go to "Signing & Capabilities"
   - Add your development team
   - Update the bundle identifier if there are conflicts
6. Build and run (⌘R)

### Building for macOS

1. Open `MirrorApp.xcodeproj` in Xcode
2. Select the **MirrorApp (macOS)** target
3. Select "My Mac" as the destination
4. Update signing if needed (same process as iOS)
5. Build and run (⌘R)
6. Grant camera permission when prompted

## First Launch

When you first launch the app, it will request camera permission. You must grant this permission for the app to function as a mirror.

### iOS
If you accidentally deny permission:
1. The app will show a permission screen
2. Tap "Open Settings"
3. Go to Privacy & Security → Camera
4. Enable camera access for MirrorApp
5. Return to the app

### macOS
If you accidentally deny permission:
1. The app will show a permission screen
2. Click "Open Settings"
3. Go to Privacy & Security → Camera
4. Toggle the switch to enable camera access for MirrorApp
5. Return to the app (may need to restart)

## Usage

### Taking Snapshots

- Tap the camera button at the bottom of the screen to capture a photo
- **iOS:** Photos are saved to your Photos library (requires permission)
- **macOS:** A save dialog lets you choose where to save the image

### Camera Settings

1. Tap the gear icon in the top-right corner
2. Toggle **Mirror Camera** to flip the view horizontally
3. Select your preferred camera from the list:
   - Built-in FaceTime camera
   - External USB webcams
   - Continuity Camera (iPhone on macOS)
4. Tap **Done** to close settings

Your camera selection and mirror preference are automatically saved.

## How It Works

The app uses AVFoundation to capture video from your camera and displays it using AVCaptureVideoPreviewLayer. Photos are captured using AVCapturePhotoOutput.

### Key Components

- **MirrorApp.swift**: App entry point
- **ContentView.swift**: Main UI with camera view and controls
- **CameraManager.swift**: Handles camera session, photo capture, and settings
- **CameraView.swift**: Platform-specific camera preview (iOS/macOS)
- **CameraSettingsView.swift**: Settings dialog for camera selection and preferences
- **Info.plist**: iOS permissions and configuration
- **MirrorApp.entitlements**: macOS permissions (camera, USB devices, photo library)

## Project Structure

```
iOS Mirror/
├── MirrorApp/
│   ├── MirrorApp.swift           # App entry point
│   ├── ContentView.swift         # Main view with controls
│   ├── CameraManager.swift       # Camera session and photo capture
│   ├── CameraView.swift          # Camera preview (iOS/macOS)
│   ├── CameraSettingsView.swift  # Settings dialog
│   ├── Info.plist                # iOS configuration
│   ├── MirrorApp.entitlements    # macOS permissions
│   └── Assets.xcassets/          # App assets
├── MirrorApp.xcodeproj/          # Xcode project
└── README.md
```

## Platform Support

### macOS External Cameras

The app supports external USB webcams on macOS, including:
- Logitech webcams (tested with C922 Pro Stream)
- Other UVC-compatible USB cameras
- Built-in FaceTime cameras
- iPhone via Continuity Camera

External cameras require USB device permissions, which are included in the entitlements file.

### iOS Cameras

Supports all built-in iOS cameras:
- Front-facing (selfie) camera
- Rear wide camera
- Ultra-wide and telephoto (if available)

## Troubleshooting

### iOS Issues

**Black screen on launch:**
- Ensure camera permission is granted
- Check that you're running on a physical device (not simulator)
- Verify the device has a working front camera

**App crashes on launch:**
- Make sure Info.plist includes NSCameraUsageDescription
- Check that the bundle identifier is valid
- Verify your provisioning profile is correct

**Permission denied:**
- Go to Settings → Privacy & Security → Camera
- Enable access for MirrorApp

### macOS Issues

**Black screen on launch:**
- Ensure camera permission is granted in System Settings
- Check if another app is using the camera
- Verify the Mac has a working camera (test with Photo Booth)

**External USB camera not appearing:**
- Make sure the camera is plugged in and recognized by macOS
- Check System Information → USB to verify the camera is detected
- Try unplugging and reconnecting the camera
- Tap "Refresh Camera List" in settings

**Permission denied:**
- Go to System Settings → Privacy & Security → Camera
- Toggle the switch for MirrorApp
- Restart the app

**Camera already in use:**
- Close other apps using the camera (Zoom, FaceTime, Photo Booth, etc.)
- The green camera LED indicates it's in use elsewhere

## License

This project is open source and available for personal and commercial use.
