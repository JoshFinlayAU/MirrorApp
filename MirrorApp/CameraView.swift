import SwiftUI
import AVFoundation

#if os(iOS)
struct CameraView: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager
    
    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        view.videoPreviewLayer.session = cameraManager.session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        view.videoPreviewLayer.connection?.videoOrientation = .portrait
        
        if let connection = view.videoPreviewLayer.connection {
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = cameraManager.isMirrored
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        if let connection = uiView.videoPreviewLayer.connection {
            let orientation = UIDevice.current.orientation
            switch orientation {
            case .portrait:
                connection.videoOrientation = .portrait
            case .portraitUpsideDown:
                connection.videoOrientation = .portraitUpsideDown
            case .landscapeLeft:
                connection.videoOrientation = .landscapeRight
            case .landscapeRight:
                connection.videoOrientation = .landscapeLeft
            default:
                connection.videoOrientation = .portrait
            }
            
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = cameraManager.isMirrored
            }
        }
    }
}

class CameraPreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
#endif

#if os(macOS)
import AppKit

struct CameraView: NSViewRepresentable {
    @ObservedObject var cameraManager: CameraManager
    
    func makeNSView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        view.videoPreviewLayer.session = cameraManager.session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        
        if let connection = view.videoPreviewLayer.connection {
            if connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = cameraManager.isMirrored
            }
        }
        
        return view
    }
    
    func updateNSView(_ nsView: CameraPreviewView, context: Context) {
        if let connection = nsView.videoPreviewLayer.connection {
            if connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = cameraManager.isMirrored
            }
        }
    }
}

class CameraPreviewView: NSView {
    var videoPreviewLayer: AVCaptureVideoPreviewLayer
    
    override init(frame frameRect: NSRect) {
        videoPreviewLayer = AVCaptureVideoPreviewLayer()
        super.init(frame: frameRect)
        layer = videoPreviewLayer
        wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        videoPreviewLayer = AVCaptureVideoPreviewLayer()
        super.init(coder: coder)
        layer = videoPreviewLayer
        wantsLayer = true
    }
}
#endif
