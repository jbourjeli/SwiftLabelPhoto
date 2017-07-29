//
//  ThumbnailCollectionViewCell.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 10/19/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

public class ThumbnailCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView
    
    override public init(frame: CGRect) {
        self.imageView = UIImageView()
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(frame: frame)
        
        self.addSubview(imageView)
        
        // MARK: - Constraints
        self.imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
