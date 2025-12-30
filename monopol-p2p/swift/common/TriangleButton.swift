//
//  TriangleButton.swift
//  swift_skyway
//
//  Created by dev monopol on 2020/10/22.
//  Copyright © 2020 worldtrip. All rights reserved.
//

import Foundation
import UIKit

class TriangleButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        drawTriangle()
    }

    private func drawTriangle() {
        let path = createTrianglePath()

        let mask = CAShapeLayer()
        mask.path = path.cgPath

        self.layer.masksToBounds = true
        self.layer.mask = mask

        let borderShape = CAShapeLayer()
        borderShape.path = path.cgPath
        borderShape.lineWidth = 0.0
        //borderShape.strokeColor = UIColor.red.cgColor
        borderShape.fillColor = UIColor.clear.cgColor
        self.layer.insertSublayer(borderShape, at: 0)
    }

    private func createTrianglePath() -> UIBezierPath {
        let rect = self.frame
        let path = UIBezierPath()
        path.move(to: CGPoint(x:rect.width / 2, y:0))
        path.addLine(to: CGPoint(x:rect.width, y:rect.height))
        path.addLine(to: CGPoint(x:0, y:rect.height))
        path.close()
        return path
    }
}
