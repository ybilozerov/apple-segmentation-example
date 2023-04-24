//
//  CameraFramesProvider.swift
//  AppleSegmentationExample
//
//  Created by Yurii Bilozerov on 24.01.2023.
//  Copyright © 2023 Yurii Bilozerov. All rights reserved.
//

import Foundation
import AVFoundation

protocol CameraFramesProviderDelegate: AnyObject {
    func framesProvider(_ provider: CameraFramesProvider, didOutput imageBuffer: CVImageBuffer)
}

class CameraFramesProvider: NSObject {
    
    weak var delegate: CameraFramesProviderDelegate? {
        didSet {
            if delegate != nil {
                captureSession?.startRunning()
            } else {
                captureSession?.stopRunning()
            }
        }
    }
    
    private var captureSession: AVCaptureSession?
    private lazy var sampleBuffersProcessingQueue: DispatchQueue = {
        .init(
            label: "CameraFramesProvider.sampleBuffersProcessingQueue",
            qos: .userInteractive
        )
    }()
}

// MARK: - Setup

extension CameraFramesProvider {
    
    func prepare(with completionHandler: @escaping (Error?) -> Void) {
        validateCameraPermission { error in
            if error != nil {
                assert(Thread.current.isMainThread, "WARNING: Executing completion handler from the background thread")
                completionHandler(error)
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                var setupError: Error?
                do {
                    try self.setupCaptureSession()
                }
                catch {
                    setupError = error
                }
                
                DispatchQueue.main.async {
                    completionHandler(setupError)
                }
            }
        }
    }
    
    private func validateCameraPermission(with completionHandler: @escaping (Error?) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized: // Permission is already granted
            completionHandler(nil)
            
        case .notDetermined: // Permission will be requested
            requestCameraPermission(with: completionHandler)
            
        case .denied: // Permission was not granted
            completionHandler(AccessError.permissionDenied)
            
        case .restricted: // Permission can't be granted
            completionHandler(AccessError.permissionRestricted)
            
        @unknown default:
            assertionFailure("Unhandled status '\(status)'")
        }
    }
    
    private func requestCameraPermission(with completionHandler: @escaping (Error?) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                completionHandler(nil)
            }
            else {
                DispatchQueue.main.async {
                    completionHandler(AccessError.permissionNotGranted)
                }
            }
        }
    }
    
    private func setupCaptureSession() throws {
        // Try to get default front camera
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            throw SetupError.missingBuiltInCamera
        }
        
        // Try to instantiate capture device input
        let input = try AVCaptureDeviceInput(device: device)
        
        // Instantiate and setup capture session
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        // Validate and add input
        guard captureSession.canAddInput(input) else {
            throw SetupError.cannotAddInput
        }
        captureSession.addInput(input)
        
        // Instantiate and setup output
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: sampleBuffersProcessingQueue)
        
        // Validate and add output
        guard captureSession.canAddOutput(output) else {
            throw SetupError.cannotAddOutput
        }
        captureSession.addOutput(output)
        
        self.captureSession = captureSession
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraFramesProvider: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let delegate, let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        autoreleasepool {
            delegate.framesProvider(self, didOutput: imageBuffer)
        }
    }
}
