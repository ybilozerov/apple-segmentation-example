//
//  CameraFramesProvider+Errors.swift
//  AppleSegmentationExample
//
//  Created by Yurii Bilozerov on 27.01.2023.
//  Copyright © 2023 Yurii Bilozerov. All rights reserved.
//

import Foundation

extension CameraFramesProvider {
    
    enum AccessError: LocalizedError {
        case permissionNotGranted
        case permissionDenied
        case permissionRestricted
        
        var errorDescription: String? {
            switch self {
            case .permissionNotGranted: fallthrough
            case .permissionDenied:     return "You haven't allowed the application to use the camera"
            case .permissionRestricted: return "You can't allow the application to use the camera"
            }
        }
    }
    
    enum SetupError: LocalizedError {
        case missingBuiltInCamera
        case cannotAddInput
        case cannotAddOutput
        
        var errorDescription: String? {
            switch self {
            case .missingBuiltInCamera: return "Can't find built-in camera"
            case .cannotAddInput:       fallthrough
            case .cannotAddOutput:      return "Can't setup capture session"
            }
        }
    }
}
