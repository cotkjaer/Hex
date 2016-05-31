//
//  HexesCollectionViewController.swift
//  Hex
//
//  Created by Christian Otkjær on 21/05/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

public class HexesCollectionViewController: UICollectionViewController
{
    public var hexes : [Hex] = [] { didSet { collectionView?.reloadData() } }
    
    public var orientation: HexOrientation = .Horizontal
    public var offsetType: OffsetType = .Odd
    
    // MARK: Layout
    
    public var hexesLayout : HexesCollectionViewLayout?
    {
        return collectionViewLayout as? HexesCollectionViewLayout
    }
    
    // MARK: Indexing
    
    public func hexForIndexPath(indexPath: NSIndexPath?) -> Hex?
    {
        guard let indexPath = indexPath else { return nil }
        
        guard indexPath.item < hexes.count && indexPath.item >= 0 else { return nil }
        
        return hexes[indexPath.item]
    }
    
    public func indexPathForHex(hex : Hex?) -> NSIndexPath?
    {
        guard let hex = hex, let item = hexes.indexOf(hex) else { return nil }

        return NSIndexPath(forItem: item, inSection: 0)
    }
    
    // MARK: UICollectionViewDataSource

    override public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }

    override public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return hexes.count
    }

    public func cellReuseIdentifierForHex(hex: Hex) -> String
    {
        //NOOP - override

        return "Cell"
    }
    
    public func configureCell(cell: UICollectionViewCell, forHex hex: Hex)
    {
        //NOOP - override
    }
    
    override public final func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let hex = hexForIndexPath(indexPath)! // TODO: crash-prone
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifierForHex(hex), forIndexPath: indexPath)
    
        configureCell(cell, forHex: hex)
        
        return cell
    }
}
