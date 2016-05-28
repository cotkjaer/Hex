//
//  HexGridCollectionViewLayout.swift
//  Hex
//
//  Created by Christian Otkjær on 21/05/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

/// The default orientation for hexes
let DefaultHexOrientation : HexOrientation = .Horizontal

/// The default side-length for each hex
let DefaultHexEdgeLength : CGFloat = 60

/// The default spacing between hexes
let DefaultHexSpacing : CGFloat = 1


public enum HexGridCollectionViewLayoutScrollDirection
{
    case None // No scrolling - all hexes must be fitted onto the screen
    case Both // Scrolling is allowed in both directions
    case Horizontal // Hexes are fitted in the Vertical direction only
    case Vertical // Hexes are fitted in the Vertical direction only
}

public class HexGridCollectionViewLayout: UICollectionViewLayout
{
    public var scrollDirection : HexGridCollectionViewLayoutScrollDirection = .None
    
    public var hexOrientation : HexOrientation = DefaultHexOrientation
        { didSet { invalidateLayout() } }
    
    /// The minimal side-length for each hex
    public var hexEdgeLength : CGFloat = DefaultHexEdgeLength
        { didSet { invalidateLayout() } }
    
    /// The minimal spacing between hexes
    public var hexSpacing : CGFloat = DefaultHexSpacing
        { didSet { invalidateLayout() } }
    
    private var hexes: [Hex] = []
    
    private var cachedAttributes = Array<UICollectionViewLayoutAttributes>()
    
    private var hexLayout : HexLayout = HexLayout(orientation: DefaultHexOrientation, edgeLength: DefaultHexEdgeLength, spacing: DefaultHexSpacing, scale: 1, offset: CGPointZero)
    
    private var hexesBounds : CGRect = CGRectZero
    
    override public func prepareLayout()
    {
        super.prepareLayout()
        
        hexes = (collectionView?.dataSource as? HexGridCollectionViewController)?.hexes ?? []
        
        let nominalLayout = HexLayout(orientation: hexOrientation, edgeLength: hexEdgeLength, spacing: hexSpacing, scale: 1, offset: CGPointZero)
        
        hexesBounds = bounds(hexes.map({ nominalLayout.boundsForHex($0)}))
        
        guard hexesBounds.height > 0 && hexesBounds.width > 0 else { return }
        
        let scale : CGFloat
        
        switch scrollDirection
        {
        case .None:
            
            let viewBounds = collectionView?.bounds ?? CGRectZero
            
            let horizontalScale = viewBounds.width / hexesBounds.width
            let verticalScale = viewBounds.height / hexesBounds.height
            
            scale = min(horizontalScale, verticalScale)
            
        case .Both:
            
            scale = 1
            
        case .Horizontal:
            
            let viewBounds = collectionView?.bounds ?? CGRectZero
            
            scale = min(1, viewBounds.height / hexesBounds.height)
            
        case .Vertical:
            
            let viewBounds = collectionView?.bounds ?? CGRectZero
            
            scale = min(1, viewBounds.width / hexesBounds.width)
        }
        
        let horizontalOffset = -hexesBounds.minX * scale
        let verticalOffset = -hexesBounds.minY * scale
        
        hexLayout = HexLayout(orientation: hexOrientation, edgeLength: hexEdgeLength, spacing: hexSpacing, scale: scale, offset: CGPoint(x:horizontalOffset, y: verticalOffset))
        
        hexesBounds = bounds(hexes.map({ hexLayout.boundsForHex($0)}))
        
        cachedAttributes = hexes.enumerate().flatMap { layoutAttributesForHex($0.element, atIndex: $0.index) }
    }
    
    func layoutAttributesForHex(hex: Hex, atIndex i: Int) -> UICollectionViewLayoutAttributes
    {
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: i, inSection: 0))
        
        attributes.frame = hexLayout.boundsForHex(hex)
        
        return attributes
    }
    
    public func centerForHex(hex: Hex) -> CGPoint
    {
        return hexLayout.centerForHex(hex: hex)
    }
    
    public override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        return cachedAttributes.filter { $0.frame.intersects(rect) }
    }
    
    public override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
    {
        let i = indexPath.item
        
        guard i < cachedAttributes.count && i >= 0 else { return nil }
        
        return cachedAttributes[i]
    }
    
    override public func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool
    {
        return scrollDirection != .Both
    }
    
    public override func collectionViewContentSize() -> CGSize
    {
        return hexesBounds.size
    }
}
