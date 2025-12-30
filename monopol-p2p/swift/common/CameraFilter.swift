//
//  CameraFilter.swift
//  swift_skyway
//
//  Created by onda on 2018/07/17.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import Foundation
import CoreImage

//(未使用・・・というか使い方がわからない)
class CameraFilter: CIFilter {
    
    private let kernelStr =
    "kernel vec4 swapRedAndGreenAmount ( __sample s, float amount ) { return mix(s.rgba, s.grba, amount); }"
    
    private let kernel: CIColorKernel

    var inputImage: CIImage?
    var inputAmount: Float = 1.0
    
    override init() {
        kernel = CIColorKernel(source: kernelStr)!
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func outputImage() -> CIImage? {
        guard let inputImage = inputImage else {return nil}
        return kernel.apply(extent: inputImage.extent, arguments: [inputImage, inputAmount])
    }
}
