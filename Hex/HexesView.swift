//
//  HexesView.swift
//  Hex
//
//  Created by Christian Otkjær on 26/07/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

@IBDesignable
open class HexesView: UIView
{
    /// Orientation ; Horizontal or Vertical
    open var orientation : HexOrientation
    {
        set { layout = HexLayout(orientation: newValue, edgeLength: edgeLength, spacing: spacing, scale: 1, offset: CGPoint.zero) }
        get { return layout.orientation }
    }
    
    /// The side-length for each hex
    @IBInspectable
    open var edgeLength : CGFloat
    {
        set { layout = HexLayout(orientation: orientation, edgeLength: newValue, spacing: spacing, scale: 1, offset: CGPoint.zero) }
        get { return layout.edgeLength }
    }
    
    /// The spacing between hexes
    @IBInspectable
    open var spacing : CGFloat
    {
        set { layout = HexLayout(orientation: orientation, edgeLength: edgeLength, spacing: newValue, scale: 1, offset: CGPoint.zero) }
        get { return layout.spacing }
    }
    
    fileprivate var layout: HexLayout = HexLayout(orientation: .horizontal, edgeLength: 30, spacing: 3, scale: 1, offset: CGPoint.zero)
    {
        didSet { updateLayout(oldValue != layout) }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    open override func awakeFromNib()
    {
        super.awakeFromNib()
        setup()
    }
    
    func setup()
    {
        updateLayout()
    }
    
    open override var bounds: CGRect
        {
        didSet {  updateLayout(oldValue != bounds) }
    }
    
    open override var frame: CGRect
        {
        didSet { updateLayout(oldValue != frame) }
    }
    
    // MARK: - Hexes
    
    open var hexes : [Hex] { return Array(hexViewsByHex.keys) }
    
    open func addHex(_ hex: Hex?) -> HexView?
    {
        guard let hex = hex else { return nil }
        
        guard hexViewsByHex[hex] == nil else { return nil }
        
        let hexView = HexView(frame: layout.boundsForHex(hex))
        
        hexView.orientation = layout.orientation
        hexViewsByHex[hex] = hexView
        updateLayout()
        
        addSubview(hexView)
        
        resizeToFitSubviews()
        
        return hexView
    }
    
    @discardableResult
    open func removeHex(_ hex: Hex?) -> Bool
    {
        guard let hex = hex else { return false }
        
        guard let hexView = hexViewsByHex[hex] else { return false }
        
        hexView.removeFromSuperview()
        updateLayout()
        
        hexViewsByHex[hex] = nil
        
        resizeToFitSubviews()
        
        return true
    }
    
    // MARK: - HexViews
    
    fileprivate var hexViewsByHex = Dictionary<Hex, HexView>()
    
    open func hexViewForHex(_ hex: Hex?) -> HexView?
    {
        guard let hex = hex else { return nil }
        
        return hexViewsByHex[hex]
    }
   
    // MARK: - Layout
    
    func updateLayout(_ needed: Bool = true)
    {
        guard needed else { return }
        
        guard var frame = layout.boundsForHex(hexes.first) else { return }
        
        for hex in hexes
        {
            frame = frame.union(layout.boundsForHex(hex))
        }
        
        if frame.origin != CGPoint.zero
        {
            let offset = CGPoint(x: layout.offset.x - frame.origin.x, y: layout.offset.y - frame.origin.y)

            layout = HexLayout(orientation: orientation, edgeLength: edgeLength, spacing: spacing, scale: 1, offset: offset)
        }
        sizeToFit()
        
        setNeedsLayout()
    }
    
    open override func layoutSubviews()
    {
        super.layoutSubviews()
        
        for hex in hexes
        {
            hexViewForHex(hex)?.frame = layout.boundsForHex(hex)
        }
    }
    
    // MARK: - Size
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize
    {
        let hexesSize = layout.boundsForHexes(hexes).size
        
        return hexesSize
    }
    
    // MARK: - IB
    
    open override func prepareForInterfaceBuilder()
    {
        updateLayout()
    }
}

