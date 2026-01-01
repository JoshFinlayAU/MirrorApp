import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if cameraManager.permissionGranted {
                CameraView(cameraManager: cameraManager)
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        cameraManager.capturePhoto()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                            
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "camera.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.bottom, 40)
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("Camera Access Required")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("Please grant camera permission to use the mirror")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Open Settings") {
                        #if os(iOS)
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                        #elseif os(macOS)
                        if let settingsURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera") {
                            NSWorkspace.shared.open(settingsURL)
                        }
                        #endif
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .onAppear {
            cameraManager.checkPermission()
        }
        .alert(cameraManager.alertMessage, isPresented: $cameraManager.showAlert) {
            Button("OK", role: .cancel) { }
        }
        .sheet(isPresented: $showSettings) {
            CameraSettingsView(cameraManager: cameraManager)
        }
    }
}
