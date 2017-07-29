//
//  PhotoCollectionViewCell.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/5/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

protocol PhotoCollectionViewCellDelegate {
    func delete(photo: Photo)
}

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet fileprivate weak var imageView: UIImageView!

    var delegate: PhotoCollectionViewCellDelegate?
    
    var photo: Photo? {
        didSet {
            if let photo = photo {
                self.imageView.image = photo.thumbnail
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        if self.imageView == nil {
            self.imageView = UIImageView(frame: self.frame)
            self.addSubview(imageView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return #selector(UIResponderStandardEditActions.delete(_:)) == action
    }
    
    // MARK: - Context Menu Actions
    
    override func delete(_ sender: Any?) {
        self.delegate?.delete(photo: photo!)
    }
}
