import SwiftUI
import AVFoundation

struct CameraSettingsView: View {
    @ObservedObject var cameraManager: CameraManager
    @Environment(\.dismiss) var dismiss
    @State private var isRefreshing = false
    
    var body: some View {
        #if os(macOS)
        macOSView
        #else
        iOSView
        #endif
    }
    
    private var cameraListContent: some View {
        Group {
            Section {
                Toggle("Mirror Camera", isOn: $cameraManager.isMirrored)
            } header: {
                Text("Display Options")
            } footer: {
                Text("When enabled, the camera view will be horizontally flipped.")
                    .font(.caption)
            }
                
            
            Section {
                ForEach(cameraManager.availableCameras) { camera in
                    Button(action: {
                        cameraManager.selectedCameraID = camera.id
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: cameraIcon(for: camera.position))
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(camera.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Text(positionText(for: camera.position))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if cameraManager.selectedCameraID == camera.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("Available Cameras (\(cameraManager.availableCameras.count))")
            }
            
            Section {
                Button(action: {
                    isRefreshing = true
                    cameraManager.discoverCameras()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isRefreshing = false
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh Camera List")
                        Spacer()
                        if isRefreshing {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                .disabled(isRefreshing)
            }
            
            Section {
                Text("The selected camera will be used when you open the app.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("If your camera is not listed, try unplugging and reconnecting it, then tap 'Refresh Camera List'.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Text("Note")
            }
        }
    }
    
    #if os(macOS)
    private var macOSView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Camera Settings")
                    .font(.headline)
                    .padding()
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .padding()
            }
            .background(Color(NSColor.windowBackgroundColor))
            
            List {
                cameraListContent
            }
        }
        .frame(minWidth: 450, minHeight: 400)
    }
    #else
    private var iOSView: some View {
        NavigationView {
            List {
                cameraListContent
            }
            .navigationTitle("Camera Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    #endif
    
    private func positionText(for position: AVCaptureDevice.Position) -> String {
        switch position {
        case .front:
            return "Front Camera"
        case .back:
            return "Back Camera"
        case .unspecified:
            return "External Camera"
        @unknown default:
            return "Unknown"
        }
    }
    
    private func cameraIcon(for position: AVCaptureDevice.Position) -> String {
        switch position {
        case .front:
            return "person.crop.circle"
        case .back:
            return "camera.circle"
        case .unspecified:
            return "video.circle"
        @unknown default:
            return "camera"
        }
    }
}
