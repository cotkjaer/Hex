//
//  UIView.swift
//  Hex
//
//  Created by Christian Otkjær on 26/07/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

extension UIView
{
    public func resizeToFitSubviews()
    {
        guard let rect = subviews.first?.frame else { frame.size = CGSizeZero; return }
        
        let subviewsRect = subviews.reduce(rect) { $0.union($1.frame) }
        
        let fix = subviewsRect.origin
        
        subviews.forEach {
            $0.frame.offsetInPlace(dx: -fix.x, dy: -fix.y)
        }
        
//        frame.offsetInPlace(dx: fix.x, dy: fix.y)
        frame.size = subviewsRect.size
        
        superview?.setNeedsLayout()
    }
}
