//
//  OutputView.swift
//  AppleSegmentationExample
//
//  Created by Yurii Bilozerov on 29.01.2023.
//  Copyright © 2023 Yurii Bilozerov. All rights reserved.
//

import Foundation
import Cocoa
import MetalKit

class OutputView: NSView {
    
    // MARK: - Properties
    
    var image: CIImage? {
        didSet {
            metalView.draw()
        }
    }
    
    private let metalView = MTKView()
    private let metalDevice = MTLCreateSystemDefaultDevice()
    private lazy var metalCommandQueue = metalDevice?.makeCommandQueue()
    
    private lazy var ciContext: CIContext? = {
        guard let metalDevice else { return nil }
        return .init(mtlDevice: metalDevice)
    }()
    
    private let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    // MARK: - Setup
    
    func setup() throws {
        // Check for required properties
        guard let metalDevice else { throw MetalSetupError.missingDevice }
        guard metalCommandQueue != nil else { throw MetalSetupError.missingCommandQueue }
        
        // Setup Metal view
        metalView.device = metalDevice
        metalView.isPaused = true
        metalView.delegate = self
        metalView.framebufferOnly = false
        
        // Add Metal view and tie it to the bounds
        addSubview(metalView)
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        metalView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        metalView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        metalView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }
}

// MARK: - MTKViewDelegate

extension OutputView: MTKViewDelegate {
    
    func draw(in view: MTKView) {
        // Obtain image to draw
        guard let image else { return }
        
        // Unwrap mandatory properties
        guard let metalCommandQueue, let ciContext else { return }
        
        // Make command buffer to encode GPU instructions
        guard let commandBuffer = metalCommandQueue.makeCommandBuffer() else { return }
        
        // Ensure drawable is free and not tied in the preivous drawing cycle
        guard let currentDrawable = view.currentDrawable else { return }
        
        // TODO: Implement different content modes
        // Scale image to fill Metal view
        let drawSize = metalView.drawableSize
        let scaleX = drawSize.width / image.extent.width
        let scaleY = drawSize.height / image.extent.height
        
        let scaledImage = image.transformed(by: .init(scaleX: scaleX, y: scaleY))
        
        // Render image to the drawable
        ciContext.render(
            scaledImage,
            to: currentDrawable.texture,
            commandBuffer: commandBuffer,
            bounds: scaledImage.extent,
            colorSpace: colorSpace
        )
        
        // Present drawable
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // This delegate method is required
    }
}

// MARK: - Errors

extension OutputView {
    
    enum MetalSetupError: LocalizedError {
        case missingDevice
        case missingCommandQueue
        
        var errorDescription: String? {
            return "Unable to setup Metal environment"
        }
        
        var recoverySuggestion: String? {
            return "The app can't work without Metal and will be terminated."
        }
    }
}
