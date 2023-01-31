//
//  VisionImageProcessor.swift
//  AppleSegmentationExample
//
//  Created by Yurii Bilozerov on 31.01.2023.
//  Copyright © 2023 Yurii Bilozerov. All rights reserved.
//

import Foundation
import Vision
import CoreImage.CIFilterBuiltins

class VisionImageProcessor {
    
    private let requestHandler = VNSequenceRequestHandler()
    private let segmentationRequest = VNGeneratePersonSegmentationRequest()
    
    init() {
        segmentationRequest.qualityLevel = .balanced
    }
}

// MARK: - Processing

extension VisionImageProcessor {
    
    func processPixelBuffer(_ pixelBuffer: CVPixelBuffer) throws -> CIImage {
        try requestHandler.perform([segmentationRequest], on: pixelBuffer)
        
        guard let maskPixelBuffer = segmentationRequest.results?.first?.pixelBuffer else {
            throw ProcessingError.cannotObtainMask
        }
        
        return try apply(mask: maskPixelBuffer, to: pixelBuffer)
    }
    
    private func apply(mask maskPixelBuffer: CVPixelBuffer, to pixelBuffer: CVPixelBuffer) throws -> CIImage {
        // Create required CIImage objects
        let image = CIImage(cvPixelBuffer: pixelBuffer)
        var maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)
        let backgroundImage = CIImage.black.cropped(to: image.extent)
        
        // Scale the mask image
        let scaleX = image.extent.width / maskImage.extent.width
        let scaleY = image.extent.height / maskImage.extent.height
        maskImage = maskImage.transformed(by: .init(scaleX: scaleX, y: scaleY))
        
        // Blend background/input images according to the mask
        let blendFilter = CIFilter.blendWithRedMask()
        blendFilter.backgroundImage = backgroundImage
        blendFilter.inputImage = image
        blendFilter.maskImage = maskImage
        
        guard let outputImage = blendFilter.outputImage else { throw ProcessingError.cannotBlendImages }
        return outputImage
    }
}

// MARK: - Errors

extension VisionImageProcessor {
    
    enum ProcessingError: Error {
        case cannotObtainMask
        case cannotBlendImages
    }
}
