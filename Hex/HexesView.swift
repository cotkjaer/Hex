//
//  HexesView.swift
//  Hex
//
//  Created by Christian Otkjær on 26/07/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import Graphics

@IBDesignable
open class HexesView: UIView
{
    /// Orientation ; Horizontal or Vertical
    open var hexOrientation: HexOrientation = DefaultHexOrientation { didSet { updateLayout(oldValue != hexOrientation) } }
    
    /// The side-length for each hex
    @IBInspectable
    open var hexEdgeLength: CGFloat = DefaultHexEdgeLength { didSet { updateLayout(oldValue != hexEdgeLength ) } }
    
    /// The spacing between hexes
    @IBInspectable
    open var hexSpacing: CGFloat = DefaultHexSpacing { didSet { updateLayout(oldValue != hexSpacing) } }
    
    private(set) var layout: HexLayout = HexLayout(orientation: DefaultHexOrientation, edgeLength: DefaultHexEdgeLength, spacing: DefaultHexSpacing, scale: 1, offset: .zero)
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
    
    open override var bounds: CGRect { didSet {  updateLayout(oldValue != bounds) } }
    
    open override var frame: CGRect { didSet { updateLayout(oldValue != frame) } }
    
    // MARK: - Hexes
    
    open var hexes : [Hex] { return hexViewsByHex.hexes }
    
    open func addHex(_ hex: Hex?) -> HexView?
    {
        guard let hex = hex else { return nil }
        
        guard hexViewsByHex[hex] == nil else { return nil }
        
        let hexView = HexView(frame: layout.boundsForHex(hex))
        
        hexView.orientation = layout.orientation
        hexViewsByHex[hex] = hexView
        updateLayout()
        
        addSubview(hexView)
        
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
        
        return true
    }
    
    // MARK: - HexViews
    
    fileprivate var hexViewsByHex = HexMap<HexView>()
    
    open func hexViewForHex(_ hex: Hex?) -> HexView?
    {
        guard let hex = hex else { return nil }
        
        return hexViewsByHex[hex]
    }
    
    // MARK: - coordinates
    
    open func center(for hex: Hex?) -> CGPoint?
    {
        guard let hex = hex else { return nil }
        
        return layout.centerForHex(hex: hex)
    }
    
    open func corners(for hex: Hex?) -> [CGPoint]?
    {
        guard let hex = hex else { return nil }
        
        return layout.corners(hex: hex)
    }
    
    // MARK: - Layout
    
    func updateLayout(_ needed: Bool = true)
    {
        guard needed else { return }
        
//        guard var frame = layout.boundsForHex(hexes.first) else { return }

        let viewBounds = bounds
        
        let nominalLayout = HexLayout(orientation: hexOrientation, edgeLength: hexEdgeLength, spacing: hexSpacing, scale: 1, offset: CGPoint.zero)
        
        let hexesBounds = hexes.map({ nominalLayout.boundsForHex($0)}).bounds()
        
        guard hexesBounds.height > 0 && hexesBounds.width > 0 else { return }
        
        let scale : CGFloat
        
        var horizontalOffsetModification : CGFloat = 0
        var verticalOffsetModification : CGFloat = 0
        
        let horizontalScale = viewBounds.width / hexesBounds.width
        let verticalScale = viewBounds.height / hexesBounds.height
        
        switch contentMode
        {
        case .scaleAspectFill, .scaleToFill:
            scale = max(horizontalScale, verticalScale)
            
            horizontalOffsetModification = (viewBounds.width - hexesBounds.width * scale) / 2
            verticalOffsetModification = (viewBounds.height - hexesBounds.height * scale) / 2
        
        case .scaleAspectFit:
            scale = min(horizontalScale, verticalScale)
            
            horizontalOffsetModification = (viewBounds.width - hexesBounds.width * scale) / 2
            verticalOffsetModification = (viewBounds.height - hexesBounds.height * scale) / 2
            
        case .bottom:
            scale = 1//min(1, min(horizontalScale, verticalScale))
            
            horizontalOffsetModification = (viewBounds.width - hexesBounds.width * scale) / 2
            verticalOffsetModification =  viewBounds.height - hexesBounds.height * scale
            
        case .bottomLeft:
            scale = 1//min(1, min(horizontalScale, verticalScale))
            
            horizontalOffsetModification = 0
            verticalOffsetModification =  viewBounds.height - hexesBounds.height * scale
            
        case .bottomRight:
            scale = 1//min(1, min(horizontalScale, verticalScale))
            
            horizontalOffsetModification = viewBounds.width - hexesBounds.width * scale
            verticalOffsetModification =  viewBounds.height - hexesBounds.height * scale
            
        case .top:
            scale = 1//min(1, min(horizontalScale, verticalScale))
            
            horizontalOffsetModification = (viewBounds.width - hexesBounds.width * scale) / 2
            verticalOffsetModification = 0
            
        case .topLeft:
            scale = 1//min(1, min(horizontalScale, verticalScale))
            
            horizontalOffsetModification = 0
            verticalOffsetModification = 0
            
        case .topRight:
            scale = 1//min(1, min(horizontalScale, verticalScale))
            
            horizontalOffsetModification = viewBounds.width - hexesBounds.width * scale
            verticalOffsetModification = 0
            
        case .center, .redraw:
            scale = 1//min(1, min(horizontalScale, verticalScale))
            
            horizontalOffsetModification = (viewBounds.width - hexesBounds.width * scale) / 2
            verticalOffsetModification = (viewBounds.height - hexesBounds.height * scale) / 2
            
        case .left:
            scale = 1//min(1, min(horizontalScale, verticalScale))
            
            horizontalOffsetModification = 0
            verticalOffsetModification = (viewBounds.height - hexesBounds.height * scale) / 2
            
        case .right:
            scale = 1//min(1, min(horizontalScale, verticalScale))
            
            horizontalOffsetModification = viewBounds.width - hexesBounds.width * scale
            verticalOffsetModification = (viewBounds.height - hexesBounds.height * scale) / 2
        }
        
        let horizontalOffset = -hexesBounds.minX * scale + horizontalOffsetModification
        let verticalOffset = -hexesBounds.minY * scale + verticalOffsetModification
        
        layout = HexLayout(orientation: hexOrientation,
                           edgeLength: hexEdgeLength,
                           spacing: hexSpacing,
                           scale: scale,
                           offset: CGPoint(x:horizontalOffset, y: verticalOffset))

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

