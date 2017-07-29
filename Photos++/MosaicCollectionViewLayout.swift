//
//  MosaicCollectionViewLayout.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/7/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//
// Algorithm from http://blog.vjeux.com/2012/image/image-layout-algorithm-google-plus.html

import UIKit

protocol MosaicCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeOfCellAtIndexPath indexPath: IndexPath) -> CGSize
}

class MosaicCollectionViewLayout: UICollectionViewLayout {
    let minimumRowHeight = CGFloat(100.0)
    
    var delegate: MosaicCollectionViewLayoutDelegate!
    
    var cellPadding: CGFloat = 1.0
    
    fileprivate var refreshCache: Bool {
        get {
           return self.numberOfItemsInCollectionView(collectionView!) != self.cache.count
        }
    }
    
    fileprivate var contentHeight: CGFloat = 0.0
    fileprivate var contentWidth: CGFloat {
        let inset = self.collectionView!.contentInset
        return self.collectionView!.bounds.width - (inset.left + inset.right)
    }
    
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    override func prepare() {
        if refreshCache {
            self.cache.removeAll()
            self.contentHeight = 0.0
            
            var yOffset: CGFloat = 0
            
            // TODO: Height of collectionViewCell is still not correct. It is cropping the image!!!!
            
            var startOfRow = 0
            for section in 0 ..< self.collectionView!.numberOfSections {
                var runningTotalOfRatios = CGFloat(0.0)
                var rowHeight = CGFloat(0.0)
                for item in 0 ..< self.collectionView!.numberOfItems(inSection: section) {
                    let indexPath = IndexPath(item: item, section: section)
                    
                    let cellSize = self.delegate.collectionView(self.collectionView!, sizeOfCellAtIndexPath: indexPath)
                    let ratio = cellSize.width / cellSize.height
                    
                    let newHeight = self.contentWidth / (runningTotalOfRatios + ratio)
                    if newHeight >= self.minimumRowHeight {
                        // Add cell to current row
                        
                        runningTotalOfRatios += ratio
                        rowHeight = newHeight
                    } else {
                        // Resize all cells in the previous row
                        self.finalizeRow(startingAt: startOfRow, endingAt: (self.cache.count-1), inSection: section, withRowHeight: rowHeight, atOriginY: yOffset)
                        
                        // Start a new row with the new cell
                        yOffset += rowHeight//cellSize.height + cellPadding
                        self.contentHeight += rowHeight
                        
                        startOfRow = self.cache.count
                        
                        runningTotalOfRatios = ratio
                        rowHeight = self.contentWidth / ratio
                    }
                    print("RowHeight: \(rowHeight), newHeight:\(newHeight), yOffset:\(yOffset)")
                    
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = CGRect.zero//.insetBy(dx: cellPadding, dy: cellPadding)
                    self.cache.append(attributes)
                }
                
                self.finalizeRow(startingAt: startOfRow, endingAt: (self.cache.count-1), inSection: section, withRowHeight: rowHeight, atOriginY: yOffset)
                self.contentHeight += rowHeight
            }
        }
    }
    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        
        self.cache.removeAll()
    }
    
    override var collectionViewContentSize : CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        
        for attribute in self.cache {
            if attribute.frame.intersects(rect) {
                attributes.append(attribute)
            }
        }
        
        return attributes
    }
    
    // MARK: - Privates
    
    fileprivate func numberOfItemsInCollectionView(_ collectionView: UICollectionView) -> Int {
        var totalItems = 0
        for section in 0 ..< collectionView.numberOfSections {
            totalItems += collectionView.numberOfItems(inSection: section)
        }
        
        return totalItems
    }
    
    fileprivate func heightForRowFrom(images: [UIImage]) -> Double {
        let sumOfRatios = images
            .map({ image in
                return image.size.width / image.size.height
            })
            .reduce(0.0, { result, curVal in
                return result + curVal
            })
        
        return Double(self.contentWidth) / Double(sumOfRatios)
    }
    
    fileprivate func finalizeRow(startingAt startOfRow: Int, endingAt endOfRow: Int, inSection section: Int, withRowHeight rowHeight: CGFloat, atOriginY y: CGFloat) {
        guard startOfRow <= endOfRow else { return }
        
        var xOffset = CGFloat(0.0)
        for item in startOfRow ... endOfRow {
            let indexPath = IndexPath(item: item, section: section)
            let cellSize = self.delegate.collectionView(self.collectionView!, sizeOfCellAtIndexPath: indexPath)
            let cellWidth = (cellSize.width*rowHeight) / cellSize.height
            
            self.cache[item].frame = CGRect(x: xOffset,
                                            y: y,
                                            width: cellWidth,
                                            height: rowHeight)
            print("ViewCell: .size: (\(cellWidth), \(rowHeight)) aspect: \(cellWidth / rowHeight)")
            
            xOffset += cellWidth
        }
    }
}
