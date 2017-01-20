//
//  HexesCollectionViewController.swift
//  Hex
//
//  Created by Christian Otkjær on 21/05/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

open class HexesCollectionViewController: UICollectionViewController
{
    open var hexes : [Hex] = [] { didSet { collectionView?.reloadData() } }
    
    open var orientation: HexOrientation = .horizontal
    open var offsetType: OffsetType = .odd
    
    // MARK: Layout
    
    open var hexesLayout : HexesCollectionViewLayout?
    {
        return collectionViewLayout as? HexesCollectionViewLayout
    }
    
    // MARK: Indexing
    
    open func hexForIndexPath(_ indexPath: IndexPath?) -> Hex?
    {
        guard let indexPath = indexPath else { return nil }
        
        guard (indexPath as NSIndexPath).item < hexes.count && (indexPath as NSIndexPath).item >= 0 else { return nil }
        
        return hexes[(indexPath as NSIndexPath).item]
    }
    
    open func indexPathForHex(_ hex : Hex?) -> IndexPath?
    {
        guard let hex = hex, let item = hexes.index(of: hex) else { return nil }

        return IndexPath(item: item, section: 0)
    }
    
    // MARK: UICollectionViewDataSource

    override open func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }

    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return hexes.count
    }

    open func cellReuseIdentifierForHex(_ hex: Hex) -> String
    {
        //NOOP - override

        return "Cell"
    }
    
    public final func reloadCellForHex(_ hex: Hex)
    {
        guard let indexPath = indexPathForHex(hex), let cell = collectionView?.cellForItem(at: indexPath) else { return }
        
        configureCell(cell, forHex: hex)
    }
    
    open func configureCell(_ cell: UICollectionViewCell, forHex hex: Hex)
    {
        //NOOP - override
    }
    
    override public final func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let hex = hexForIndexPath(indexPath)! // TODO: crash-prone
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifierForHex(hex), for: indexPath)
    
        configureCell(cell, forHex: hex)
        
        return cell
    }
}
