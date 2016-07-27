//
//  HexesView.swift
//  Hex
//
//  Created by Christian Otkjær on 26/07/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

@IBDesignable
public class HexesView: UIView
{
    /// Orientation ; Horizontal or Vertical
    public var orientation : HexOrientation
    {
        set { layout = HexLayout(orientation: newValue, edgeLength: edgeLength, spacing: spacing, scale: 1, offset: CGPointZero) }
        get { return layout.orientation }
    }
    
    /// The side-length for each hex
    @IBInspectable
    public var edgeLength : CGFloat
    {
        set { layout = HexLayout(orientation: orientation, edgeLength: newValue, spacing: spacing, scale: 1, offset: CGPointZero) }
        get { return layout.edgeLength }
    }
    
    /// The spacing between hexes
    @IBInspectable
    public var spacing : CGFloat
    {
        set { layout = HexLayout(orientation: orientation, edgeLength: edgeLength, spacing: newValue, scale: 1, offset: CGPointZero) }
        get { return layout.spacing }
    }
    
    private var layout: HexLayout = HexLayout(orientation: .Horizontal, edgeLength: 30, spacing: 3, scale: 1, offset: CGPointZero)
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
    
    public override func awakeFromNib()
    {
        super.awakeFromNib()
        setup()
    }
    
    func setup()
    {
        updateLayout()
    }
    
    public override var bounds: CGRect
        {
        didSet {  updateLayout(oldValue != bounds) }
    }
    
    public override var frame: CGRect
        {
        didSet { updateLayout(oldValue != frame) }
    }
    
    // MARK: - Hexes
    
    public var hexes : [Hex] { return Array(hexViewsByHex.keys) }
    
    public func addHex(hex: Hex?) -> HexView?
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
    
    public func removeHex(hex: Hex?) -> Bool
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
    
    private var hexViewsByHex = Dictionary<Hex, HexView>()
    
    public func hexViewForHex(hex: Hex?) -> HexView?
    {
        guard let hex = hex else { return nil }
        
        return hexViewsByHex[hex]
    }
   
    // MARK: - Layout
    
    func updateLayout(needed: Bool = true)
    {
        guard needed else { return }
        
        guard var frame = layout.boundsForHex(hexes.first) else { return }
        
        for hex in hexes
        {
            frame = frame.union(layout.boundsForHex(hex))
        }
        
        if frame.origin != CGPointZero
        {
            let offset = CGPoint(x: layout.offset.x - frame.origin.x, y: layout.offset.y - frame.origin.y)

            layout = HexLayout(orientation: orientation, edgeLength: edgeLength, spacing: spacing, scale: 1, offset: offset)
        }
        sizeToFit()
        
        setNeedsLayout()
    }
    
    public override func layoutSubviews()
    {
        super.layoutSubviews()
        
        for hex in hexes
        {
            hexViewForHex(hex)?.frame = layout.boundsForHex(hex)
        }
    }
    
    // MARK: - Size
    
    public override func sizeThatFits(size: CGSize) -> CGSize
    {
        let hexesSize = layout.boundsForHexes(hexes).size
        
        return hexesSize
    }
    
    // MARK: - IB
    
    public override func prepareForInterfaceBuilder()
    {
        updateLayout()
    }
    
    
}

