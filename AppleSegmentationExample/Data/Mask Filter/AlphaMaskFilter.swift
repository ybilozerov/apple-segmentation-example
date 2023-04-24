//
//  AlphaMaskFilter.swift
//  AppleSegmentationExample
//
//  Created by Yurii Bilozerov on 23.04.2023.
//  Copyright © 2023 Yurii Bilozerov. All rights reserved.
//

import CoreImage
import os

// MARK: - Errors

extension AlphaMaskFilter {
    enum KernelError: Error {
        case cannotLoadDefaultMetalLibrary
    }
}

class AlphaMaskFilter: CIFilter {
    
    // MARK: - Properties
    
    static var kernel: CIColorKernel? = {
        do {
            guard let url = Bundle.main.url(forResource: "default", withExtension: "metallib") else {
                throw KernelError.cannotLoadDefaultMetalLibrary
            }
            
            let data = try Data(contentsOf: url)
            return try CIColorKernel(functionName: "alpha_mask", fromMetalLibraryData: data)
        }
        catch {
            assertionFailure(String(describing: error))
            return nil
        }
    }()
    
    var inputImage: CIImage?
    var maskImage: CIImage?
    
    // MARK: - Overrides
    
    override var outputImage: CIImage? {
        // Unwrap mandatory parameters
        guard let kernel = Self.kernel, let inputImage, let maskImage else { return nil }
        
        // Apply arguments to the kernel
        let arguments = [inputImage, maskImage]
        return kernel.apply(extent: inputImage.extent, arguments: arguments)
    }
}
