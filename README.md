# Mirror App

A simple multiplatform mirror app for iOS and macOS. Uses your device's camera to display a real-time mirror view on screen.

> **Note:** This is my first Swift app for iOS/macOS, so be kind! 😅

## Features

- **iOS & macOS support** - Single codebase for both platforms (iOS relatively untested, sorry, iPhone was being a bitch)
- **Real-time mirror display** - Smooth camera feed with customizable mirroring
- **Snapshot capture** - Save photos directly to your photo library (iOS) or file system (macOS)
- **Camera selection** - Choose from built-in cameras, external USB webcams, or Continuity Camera
- **Mirror toggle** - Flip the camera view horizontally on/off
- **Persistent settings** - Your camera and mirror preferences are saved

## First Launch

When you first launch the app, it will request camera permission. You must grant this permission for the app to function as a mirror.

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

## Platform Support

### macOS External Cameras

The app supports external USB webcams on macOS, including:
- Logitech webcams (tested with C922 Pro Stream)
- Other UVC-compatible USB cameras (fingers crossed haha)
- Built-in FaceTime cameras
- iPhone via Continuity Camera

External cameras require USB device permissions, which are included in the entitlements file.

### iOS Cameras

Supports all built-in iOS cameras

## License

This project is open source and available for personal and commercial use. (if you'd even really want to 😂)
