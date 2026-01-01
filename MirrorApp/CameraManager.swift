import AVFoundation
import SwiftUI
#if os(iOS)
import Photos
import UIKit
typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
typealias PlatformImage = NSImage
#endif

class CameraManager: NSObject, ObservableObject {
    @Published var permissionGranted = false
    @Published var session = AVCaptureSession()
    @Published var capturedImage: PlatformImage?
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var availableCameras: [CameraDevice] = []
    @Published var selectedCameraID: String? {
        didSet {
            if let id = selectedCameraID {
                UserDefaults.standard.set(id, forKey: "selectedCameraID")
                if permissionGranted {
                    restartSession()
                }
            }
        }
    }
    @Published var isMirrored: Bool = true {
        didSet {
            UserDefaults.standard.set(isMirrored, forKey: "isMirrored")
        }
    }
    
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var videoOutput = AVCaptureVideoDataOutput()
    private var photoOutput = AVCapturePhotoOutput()
    
    override init() {
        super.init()
        selectedCameraID = UserDefaults.standard.string(forKey: "selectedCameraID")
        if UserDefaults.standard.object(forKey: "isMirrored") != nil {
            isMirrored = UserDefaults.standard.bool(forKey: "isMirrored")
        }
    }
    
    struct CameraDevice: Identifiable, Hashable {
        let id: String
        let name: String
        let position: AVCaptureDevice.Position
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
            discoverCameras()
            setupCaptureSession()
        case .notDetermined:
            requestPermission()
        default:
            permissionGranted = false
        }
    }
    
    func discoverCameras() {
        print("DISCOVER CAMERAS CALLED")
        
        #if os(iOS)
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInTelephotoCamera, .builtInUltraWideCamera],
            mediaType: .video,
            position: .unspecified
        )
        let devices = discoverySession.devices
        print("iOS: Found \(devices.count) devices")
        #elseif os(macOS)
        print("macOS: Starting device discovery")
        var devices = AVCaptureDevice.devices(for: .video)
        
        print("=== Camera Discovery Debug ===")
        print("Found \(devices.count) video devices via devices(for:)")
        for device in devices {
            print("- Name: \(device.localizedName)")
            print("  UniqueID: \(device.uniqueID)")
            print("  Manufacturer: \(device.manufacturer)")
            print("  ModelID: \(device.modelID)")
            print("  Connected: \(device.isConnected)")
            print("  HasVideo: \(device.hasMediaType(.video))")
            print("---")
        }
        
        let allDevices = AVCaptureDevice.devices()
        print("\nFound \(allDevices.count) TOTAL devices (all types):")
        for device in allDevices {
            if device.hasMediaType(.video) {
                print("- VIDEO: \(device.localizedName) | Model: \(device.modelID) | ID: \(device.uniqueID)")
            }
        }
        print("==============================")
        #endif
        
        DispatchQueue.main.async {
            self.availableCameras = devices.map { device in
                CameraDevice(
                    id: device.uniqueID,
                    name: device.localizedName,
                    position: device.position
                )
            }
            
            #if os(macOS)
            let foundNames = self.availableCameras.map { $0.name }.joined(separator: ", ")
            print("DEBUG: Found \(self.availableCameras.count) cameras: \(foundNames)")
            #endif
        }
    }
    
    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.permissionGranted = granted
                if granted {
                    self?.discoverCameras()
                    self?.setupCaptureSession()
                }
            }
        }
    }
    
    func restartSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.session.stopRunning()
            
            for input in self.session.inputs {
                self.session.removeInput(input)
            }
            for output in self.session.outputs {
                self.session.removeOutput(output)
            }
            
            DispatchQueue.main.async {
                self.setupCaptureSession()
            }
        }
    }
    
    private func setupCaptureSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            self.session.sessionPreset = .high
            
            let videoDevice = self.selectCamera()
            
            guard let device = videoDevice,
                  let videoDeviceInput = try? AVCaptureDeviceInput(device: device),
                  self.session.canAddInput(videoDeviceInput) else {
                DispatchQueue.main.async {
                    self.permissionGranted = false
                }
                return
            }
            
            self.session.addInput(videoDeviceInput)
            
            if self.session.canAddOutput(self.videoOutput) {
                self.session.addOutput(self.videoOutput)
                self.videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            }
            
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
                self.photoOutput.isHighResolutionCaptureEnabled = true
            }
            
            self.session.commitConfiguration()
            
            DispatchQueue.main.async {
                self.session.startRunning()
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            self?.session.stopRunning()
        }
    }
    
    private func selectCamera() -> AVCaptureDevice? {
        #if os(iOS)
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInTelephotoCamera, .builtInUltraWideCamera],
            mediaType: .video,
            position: .unspecified
        )
        let devices = discoverySession.devices
        #elseif os(macOS)
        let devices = AVCaptureDevice.devices(for: .video)
        #endif
        
        if let selectedID = selectedCameraID,
           let device = devices.first(where: { $0.uniqueID == selectedID }) {
            return device
        }
        
        #if os(iOS)
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        #elseif os(macOS)
        for device in devices {
            if device.localizedName.lowercased().contains("continuity") ||
               device.localizedName.lowercased().contains("iphone") {
                continue
            }
            
            if device.localizedName.lowercased().contains("facetime") ||
               device.localizedName.lowercased().contains("built-in") {
                return device
            }
        }
        
        return devices.first
        #endif
    }
    
    func capturePhoto() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            let settings = AVCapturePhotoSettings()
            settings.flashMode = .off
            
            if let connection = self.photoOutput.connection(with: .video) {
                connection.isVideoMirrored = true
            }
            
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            DispatchQueue.main.async {
                self.alertMessage = "Failed to capture photo: \(error.localizedDescription)"
                self.showAlert = true
            }
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            DispatchQueue.main.async {
                self.alertMessage = "Failed to process photo data"
                self.showAlert = true
            }
            return
        }
        
        #if os(iOS)
        guard let image = UIImage(data: imageData) else {
            DispatchQueue.main.async {
                self.alertMessage = "Failed to process photo data"
                self.showAlert = true
            }
            return
        }
        #elseif os(macOS)
        guard let image = NSImage(data: imageData) else {
            DispatchQueue.main.async {
                self.alertMessage = "Failed to process photo data"
                self.showAlert = true
            }
            return
        }
        #endif
        
        DispatchQueue.main.async {
            self.capturedImage = image
            self.savePhoto(image)
        }
    }
    
    private func savePhoto(_ image: PlatformImage) {
        #if os(iOS)
        savePhotoToLibrary(image)
        #elseif os(macOS)
        savePhotoToFile(image)
        #endif
    }
    
    #if os(iOS)
    private func savePhotoToLibrary(_ image: PlatformImage) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                DispatchQueue.main.async {
                    self.alertMessage = "Photo library access denied. Enable in Settings to save photos."
                    self.showAlert = true
                }
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.creationRequestForAsset(from: image)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.alertMessage = "Photo saved to library!"
                        self.showAlert = true
                    } else if let error = error {
                        self.alertMessage = "Failed to save: \(error.localizedDescription)"
                        self.showAlert = true
                    }
                }
            }
        }
    }
    #endif
    
    #if os(macOS)
    private func savePhotoToFile(_ image: PlatformImage) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.jpeg, .png]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Save Mirror Snapshot"
        savePanel.message = "Choose a location to save your mirror snapshot"
        savePanel.nameFieldStringValue = "Mirror-\(Date().timeIntervalSince1970).jpg"
        
        savePanel.begin { response in
            guard response == .OK, let url = savePanel.url else {
                return
            }
            
            guard let tiffData = image.tiffRepresentation,
                  let bitmapImage = NSBitmapImageRep(data: tiffData),
                  let jpegData = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.9]) else {
                DispatchQueue.main.async {
                    self.alertMessage = "Failed to process image"
                    self.showAlert = true
                }
                return
            }
            
            do {
                try jpegData.write(to: url)
                DispatchQueue.main.async {
                    self.alertMessage = "Photo saved successfully!"
                    self.showAlert = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertMessage = "Failed to save: \(error.localizedDescription)"
                    self.showAlert = true
                }
            }
        }
    }
    #endif
}
