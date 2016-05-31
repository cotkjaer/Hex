//
//  HexesCollectionViewLayout.swift
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


public enum HexesCollectionViewLayoutScrollDirection
{
    case None // No scrolling - all hexes must be fitted onto the screen
    case Both // Scrolling is allowed in both directions
    case Horizontal // Hexes are fitted in the Vertical direction only
    case Vertical // Hexes are fitted in the Vertical direction only
}

public class HexesCollectionViewLayout: UICollectionViewLayout
{
    public var scrollDirection : HexesCollectionViewLayoutScrollDirection = .None
    
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

        guard let collectionView = collectionView else {
            return
        }
        
        let viewBounds = collectionView.bounds
        
        hexes = (collectionView.dataSource as? HexesCollectionViewController)?.hexes ?? []
        
        let nominalLayout = HexLayout(orientation: hexOrientation, edgeLength: hexEdgeLength, spacing: hexSpacing, scale: 1, offset: CGPointZero)
        
        hexesBounds = bounds(hexes.map({ nominalLayout.boundsForHex($0)}))
        
        guard hexesBounds.height > 0 && hexesBounds.width > 0 else { return }
        
        let scale : CGFloat
        
        var horizontalOffsetModification : CGFloat = 0
        var verticalOffsetModification : CGFloat = 0

        switch scrollDirection
        {
        case .None:
            
            let horizontalScale = viewBounds.width / hexesBounds.width
            let verticalScale = viewBounds.height / hexesBounds.height
            
            switch collectionView.contentMode
            {
            case .ScaleAspectFill, .ScaleToFill, .ScaleAspectFit:
                scale = min(horizontalScale, verticalScale)
                
                horizontalOffsetModification = (viewBounds.width - hexesBounds.width * scale) / 2
                verticalOffsetModification = (viewBounds.height - hexesBounds.height * scale) / 2

            case .Bottom:
                
                scale = min(1, min(horizontalScale, verticalScale))
                
                horizontalOffsetModification = (viewBounds.width - hexesBounds.width * scale) / 2
                verticalOffsetModification =  viewBounds.height - hexesBounds.height * scale

            case .BottomLeft:
                scale = min(1, min(horizontalScale, verticalScale))
                
                horizontalOffsetModification = 0
                verticalOffsetModification =  viewBounds.height - hexesBounds.height * scale
                
            case .BottomRight:
                scale = min(1, min(horizontalScale, verticalScale))
                
                horizontalOffsetModification = viewBounds.width - hexesBounds.width * scale
                verticalOffsetModification =  viewBounds.height - hexesBounds.height * scale


            case .Top:
                scale = min(1, min(horizontalScale, verticalScale))
                
                horizontalOffsetModification = (viewBounds.width - hexesBounds.width * scale) / 2
                verticalOffsetModification = 0
                
            case .TopLeft:
                scale = min(1, min(horizontalScale, verticalScale))
                
                horizontalOffsetModification = 0
                verticalOffsetModification = 0
                
            case .TopRight:
                scale = min(1, min(horizontalScale, verticalScale))
                
                horizontalOffsetModification = viewBounds.width - hexesBounds.width * scale
                verticalOffsetModification = 0

            case .Center, .Redraw:
                scale = min(1, min(horizontalScale, verticalScale))
                
                horizontalOffsetModification = (viewBounds.width - hexesBounds.width * scale) / 2
                verticalOffsetModification = (viewBounds.height - hexesBounds.height * scale) / 2
                
            case .Left:
                
                scale = min(1, min(horizontalScale, verticalScale))
                
                horizontalOffsetModification = 0
                verticalOffsetModification = (viewBounds.height - hexesBounds.height * scale) / 2
                
            case .Right:
                scale = min(1, min(horizontalScale, verticalScale))
                
                horizontalOffsetModification = viewBounds.width - hexesBounds.width * scale
                verticalOffsetModification = (viewBounds.height - hexesBounds.height * scale) / 2
                
//            default:
//                
//                scale = min(1, min(horizontalScale, verticalScale))
//                
//                horizontalOffsetModification = (viewBounds.width - hexesBounds.width * scale) / 2
//                verticalOffsetModification = (viewBounds.height - hexesBounds.height * scale) / 2
            }
            
        case .Both:
            
            scale = 1
            
//            horizontalOffsetModification = 0
//            verticalOffsetModification = 0

            
        case .Horizontal:
            
            scale = min(1, viewBounds.height / hexesBounds.height)
            
            horizontalOffsetModification = 0
            verticalOffsetModification = (viewBounds.height - hexesBounds.height * scale) / 2

            
        case .Vertical:
            
            scale = min(1, viewBounds.width / hexesBounds.width)
            
            horizontalOffsetModification = (viewBounds.width - hexesBounds.width * scale) / 2
            verticalOffsetModification = 0
        }
        
        let horizontalOffset = -hexesBounds.minX * scale + horizontalOffsetModification
        let verticalOffset = -hexesBounds.minY * scale + verticalOffsetModification

        hexLayout = HexLayout(orientation: hexOrientation, edgeLength: hexEdgeLength, spacing: hexSpacing, scale: scale, offset: CGPoint(x:horizontalOffset, y: verticalOffset))
        
        cachedAttributes = hexes.enumerate().flatMap { layoutAttributesForHex($0.element, atIndex: $0.index) }
        
        hexesBounds = bounds(cachedAttributes.map({ $0.frame }))
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
        let attrs = cachedAttributes.filter { $0.frame.intersects(rect) }
        
        return attrs
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
        return CGSize(width: hexesBounds.maxX, height: hexesBounds.maxY) // hexesBounds.size
    }
}
