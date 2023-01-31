//
//  OutputViewController.swift
//  AppleSegmentationExample
//
//  Created by Yurii Bilozerov on 24.01.2023.
//  Copyright © 2023 Yurii Bilozerov. All rights reserved.
//

import Cocoa
import OSLog

class OutputViewController: NSViewController {
    
    // MARK: - Properties
    
    @IBOutlet private weak var outputView: OutputView!
    
    private let framesProvider = CameraFramesProvider()
    private var isFramesProviderPrepared: Bool = false
    
    private let imageProcessor = VisionImageProcessor()
    
    private var metalSetupError: OutputView.MetalSetupError?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            // Try setup output view
            try outputView.setup()
        }
        catch {
            // Preserve setup error because app isn't able to show alert right here
            metalSetupError = error as? OutputView.MetalSetupError
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // Terminate the app if Metal isn't available
        if let metalSetupError {
            showAlert(with: metalSetupError)
            NSApp.terminate(nil)
        }
        
        // Prepare or resume obtaining frames from the camera
        prepareFramesProviderIfNeeded()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        // Pause obtaining frames from the camera when window is minimized
        framesProvider.delegate = nil
    }
}

// MARK: - CameraFramesProviderDelegate

extension OutputViewController: CameraFramesProviderDelegate {
    
    func framesProvider(_ provider: CameraFramesProvider, didOutput imageBuffer: CVImageBuffer) {
        let pixelBuffer = imageBuffer as CVPixelBuffer
        do {
            let image = try imageProcessor.processPixelBuffer(pixelBuffer)
            outputView.image = image
        }
        catch {
            os_log("%@", String(describing: error))
        }
    }
}

// MARK: - Private

private extension OutputViewController {
    
    func prepareFramesProviderIfNeeded() {
        // Just resume frames provider
        if isFramesProviderPrepared {
            framesProvider.delegate = self
            return
        }
        
        // Prepare frames provider
        framesProvider.prepare { error in
            if let error {
                self.showAlert(with: error)
                return
            }
            
            self.framesProvider.delegate = self
        }
        
        isFramesProviderPrepared = true
    }
    
    func showAlert(with error: Error) {
        let alert = NSAlert(error: error)
        alert.runModal()
    }
}
