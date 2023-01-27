//
//  ViewController.swift
//  AppleSegmentationExample
//
//  Created by Yurii Bilozerov on 24.01.2023.
//

import Cocoa
import OSLog

class ViewController: NSViewController {
    
    private var framesProvider = CameraFramesProvider()
    private var isFramesProviderPrepared: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        prepareFramesProviderIfNeeded()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        framesProvider.delegate = nil
    }
    
    private func prepareFramesProviderIfNeeded() {
        if isFramesProviderPrepared {
            framesProvider.delegate = self
            return
        }
        
        framesProvider.prepare { error in
            if let error {
                let alert = NSAlert(error: error)
                alert.runModal()
                return
            }
            
            self.framesProvider.delegate = self
        }
        
        isFramesProviderPrepared = true
    }
}

extension ViewController: CameraFramesProviderDelegate {
    
    func framesProvider(_ provider: CameraFramesProvider, didOutput imageBuffer: CVImageBuffer) {
        os_log("Frames provider did output sample buffer")
    }
}
