//
//  EffectGradient.swift
//  swift_skyway
//
//  Created by onda on 2018/07/17.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import Foundation
import UIKit

class EffectGradient: CALayer {
    
    //var startColor = UIColor.orange
    //var endColor = UIColor.yellow
    var startColor = Util.EFFECT_GRAD_START_005//中央を紫色
    var endColor = Util.EFFECT_GRAD_END_004
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    override init() {
        super.init()
        self.setNeedsDisplay()
    }
    
    override func draw(in ctx: CGContext) {
        
        ctx.saveGState()
        
        let myColors = [startColor.cgColor, endColor.cgColor]
        let myColorSpace = CGColorSpaceCreateDeviceRGB()
        let myColorLocations:[CGFloat] = [0.0, 1.0]
        
        let myGradient = CGGradient(colorsSpace: myColorSpace, colors: myColors as CFArray, locations: myColorLocations)
        
        //let startCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
        let startCenter = CGPoint(x:self.bounds.size.width/2, y:self.bounds.size.height/2)
        let endCenter = startCenter
        let startRadius:CGFloat = 0.0
        let endRadius = min(self.bounds.size.width, self.bounds.size.height)
        
        ctx.drawRadialGradient(myGradient!, startCenter: startCenter, startRadius: startRadius, endCenter: endCenter, endRadius: endRadius, options: [CGGradientDrawingOptions.drawsBeforeStartLocation, CGGradientDrawingOptions.drawsAfterEndLocation])
        
        ctx.restoreGState()
    }

}
