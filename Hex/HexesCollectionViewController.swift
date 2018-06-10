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
        return collectionView?.collectionViewLayout as? HexesCollectionViewLayout
    }
    
    // MARK: Indexing
    
    open func hexForIndexPath(_ indexPath: IndexPath?) -> Hex?
    {
        return hexes.get(indexPath?.item)
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

    open func cellReuseIdentifierFor(hex: Hex?) -> String
    {
        //NOOP - override

        return "Cell"
    }
    
    public final func reloadCellFor(hex: Hex?)
    {
        guard let indexPath = indexPathForHex(hex), let cell = collectionView?.cellForItem(at: indexPath) else { return }
        
        configure(cell: cell, for: hex)
    }
    
    open func configure(cell: UICollectionViewCell, for hex: Hex?)
    {
        //NOOP - override
    }
    
    override public final func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let hex = hexForIndexPath(indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifierFor(hex: hex), for: indexPath)
    
        configure(cell: cell, for: hex)
        
        return cell
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.collectionView?.frame = CGRect(origin: .zero, size: size)
        }) { (context) in
            self.hexesLayout?.invalidateLayout()
        }
    }
}
