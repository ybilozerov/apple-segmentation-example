//
//  Kernel.metal
//  AppleSegmentationExample
//
//  Created by Yurii Bilozerov on 23.04.2023.
//  Copyright © 2023 Yurii Bilozerov. All rights reserved.
//

#include <metal_stdlib>
#include <CoreImage/CoreImage.h>
using namespace metal;

extern "C" {
    namespace coreimage {
        float4 alpha_mask(sample_t input, sample_t mask) {
            return input * mask.r;
        }
    }
}
