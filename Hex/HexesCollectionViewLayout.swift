//
//  HexesCollectionViewLayout.swift
//  Hex
//
//  Created by Christian Otkjær on 21/05/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

/// The default orientation for hexes
let DefaultHexOrientation: HexOrientation = .horizontal

/// The default side-length for each hex
let DefaultHexEdgeLength: CGFloat = 60

/// The default spacing between hexes
let DefaultHexSpacing: CGFloat = 1


public enum HexesCollectionViewLayoutScrollDirection
{
    case none // No scrolling - all hexes must be fitted onto the screen
    case both // Scrolling is allowed in both directions
    case horizontal // Hexes are fitted in the Vertical direction only
    case vertical // Hexes are fitted in the Horizontal direction only
}

open class HexesCollectionViewLayout: UICollectionViewLayout
{
    open var scrollDirection : HexesCollectionViewLayoutScrollDirection = .none
    
    open var hexOrientation : HexOrientation = DefaultHexOrientation
        { didSet { invalidateLayout() } }
    
    /// The minimal side-length for each hex
    open var hexEdgeLength : CGFloat = DefaultHexEdgeLength
        { didSet { invalidateLayout() } }
    
    /// The minimal spacing between hexes
    open var hexSpacing : CGFloat = DefaultHexSpacing
        { didSet { invalidateLayout() } }
    
    fileprivate var hexes: [Hex] = []
    
    fileprivate var cachedAttributes = Array<UICollectionViewLayoutAttributes>()
    
    fileprivate var hexLayout : HexLayout = HexLayout(orientation: DefaultHexOrientation, edgeLength: DefaultHexEdgeLength, spacing: DefaultHexSpacing, scale: 1, offset: CGPoint.zero)
    
    fileprivate var hexesBounds : CGRect = CGRect.zero
    
    override open func prepare()
    {
        super.prepare()

        guard let collectionView = collectionView else {
            return
        }
        
        let viewBounds = collectionView.bounds
        
        hexes = (collectionView.dataSource as? HexesCollectionViewController)?.hexes ?? []
        
        let nominalLayout = HexLayout(orientation: hexOrientation, edgeLength: hexEdgeLength, spacing: hexSpacing, scale: 1, offset: CGPoint.zero)
        
        hexesBounds = bounds(hexes.map({ nominalLayout.boundsForHex($0)}))
        
        guard hexesBounds.height > 0 && hexesBounds.width > 0 else { return }
        
        let scale : CGFloat
        
        var horizontalOffsetModification : CGFloat = 0
        var verticalOffsetModification : CGFloat = 0

        switch scrollDirection
        {
        case .none:
            
            let horizontalScale = viewBounds.width / hexesBounds.width
            let verticalScale = viewBounds.height / hexesBounds.height
            
            switch collectionView.contentMode
            {
            case .scaleAspectFill, .scaleToFill, .scaleAspectFit:
                scale = min(horizontalScale, verticalScale)
                
                horizontalOffsetModification = (viewBounds.width - hexesBounds.width * scale) / 2
                verticalOffsetModification = (viewBounds.height - hexesBounds.height * scale) / 2

            case .bottom:
                
                scale = min(1, min(horizontalScale, verticalScale))
                
                horizontalOffsetModification = (viewBounds.width - hexesBounds.width * scale) / 2
                verticalOffsetModification =  viewBounds.height - hexesBounds.height * scale

            case .bottomLeft:
                scale = min(1, min(horizontalScale, verticalScale))
                
                horizontalOffsetModification = 0
                verticalOffsetModification =  viewBounds.height - hexesBounds.height * scale
                
            case .bottomRight:
                scale = min(1, min(horizontalScale, verticalScale))
                
                horizontalOffsetModification = viewBounds.width - hexesBounds.width * scale
                verticalOffsetModification =  viewBounds.height - hexesBounds.height * scale

            case .top:
                scale = min(1, min(horizontalScale, verticalScale))
                
                horizontalOffsetModification = (viewBounds.width - hexesBounds.width * scale) / 2
                verticalOffsetModification = 0
                
            case .topLeft:
                scale = min(1, min(horizontalScale, verticalScale))
                
                horizontalOffsetModification = 0
                verticalOffsetModification = 0
                
            case .topRight:
                scale = min(1, min(horizontalScale, verticalScale))
                
                horizontalOffsetModification = viewBounds.width - hexesBounds.width * scale
                verticalOffsetModification = 0

            case .center, .redraw:
                scale = min(1, min(horizontalScale, verticalScale))
                
                horizontalOffsetModification = (viewBounds.width - hexesBounds.width * scale) / 2
                verticalOffsetModification = (viewBounds.height - hexesBounds.height * scale) / 2
                
            case .left:
                
                scale = min(1, min(horizontalScale, verticalScale))
                
                horizontalOffsetModification = 0
                verticalOffsetModification = (viewBounds.height - hexesBounds.height * scale) / 2
                
            case .right:
                scale = min(1, min(horizontalScale, verticalScale))
                
                horizontalOffsetModification = viewBounds.width - hexesBounds.width * scale
                verticalOffsetModification = (viewBounds.height - hexesBounds.height * scale) / 2
            }
            
        case .both:
            
            scale = 1
            
        case .horizontal:
            
            scale = min(1, viewBounds.height / hexesBounds.height)
            
            horizontalOffsetModification = 0
            verticalOffsetModification = (viewBounds.height - hexesBounds.height * scale) / 2
            
        case .vertical:
            
            scale = min(1, viewBounds.width / hexesBounds.width)
            
            horizontalOffsetModification = (viewBounds.width - hexesBounds.width * scale) / 2
            verticalOffsetModification = 0
        }
        
        let horizontalOffset = -hexesBounds.minX * scale + horizontalOffsetModification
        let verticalOffset = -hexesBounds.minY * scale + verticalOffsetModification

        hexLayout = HexLayout(orientation: hexOrientation, edgeLength: hexEdgeLength, spacing: hexSpacing, scale: scale, offset: CGPoint(x:horizontalOffset, y: verticalOffset))
        
        cachedAttributes = hexes.enumerated().flatMap { layoutAttributesForHex($0.element, atIndex: $0.offset) }
        
        hexesBounds = bounds(cachedAttributes.map({ $0.frame }))
    }
    
    func layoutAttributesForHex(_ hex: Hex, atIndex i: Int) -> UICollectionViewLayoutAttributes
    {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: 0))
        
        attributes.frame = hexLayout.boundsForHex(hex)
        
        return attributes
    }
    
    open func centerForHex(_ hex: Hex) -> CGPoint
    {
        return hexLayout.centerForHex(hex: hex)
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        let attrs = cachedAttributes.filter { $0.frame.intersects(rect) }
        
        return attrs
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let i = (indexPath as NSIndexPath).item
        
        guard i < cachedAttributes.count && i >= 0 else { return nil }
        
        return cachedAttributes[i]
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
    {
        return scrollDirection != .both
    }
    
    open override var collectionViewContentSize : CGSize
    {
        return CGSize(width: hexesBounds.maxX, height: hexesBounds.maxY)
    }
}
