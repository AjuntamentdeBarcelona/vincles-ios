//
//  CalendarColletionViewFlowLayout.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.

import UIKit

open class CalendarColletionViewFlowLayout: UICollectionViewFlowLayout {
    
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        return super.layoutAttributesForElements(in: rect)?.map { attrs in
            let attrscp = attrs.copy() as! UICollectionViewLayoutAttributes
            self.applyLayoutAttributes(attrscp)
            return attrscp
        }
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        if let attrs = super.layoutAttributesForItem(at: indexPath) {
            let attrscp = attrs.copy() as! UICollectionViewLayoutAttributes
            self.applyLayoutAttributes(attrscp)
            return attrscp
        }
        return nil
    }
    
    func applyLayoutAttributes(_ attributes : UICollectionViewLayoutAttributes) {
        guard attributes.representedElementKind == nil else { return }
        
        guard let collectionView = self.collectionView else { return }
        
        var xCellOffset = CGFloat(attributes.indexPath.item % 7) * self.itemSize.width
        let yCellOffset = CGFloat(attributes.indexPath.item / 7) * self.itemSize.height
        
        let offset = CGFloat(attributes.indexPath.section)
        xCellOffset += offset * collectionView.frame.size.width
        
        attributes.frame = CGRect(
            x: xCellOffset,
            y: yCellOffset,
            width: self.itemSize.width,
            height: self.itemSize.height
        )
    }
}
