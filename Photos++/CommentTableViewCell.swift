//
//  CommentTableViewCell.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/29/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    var commentLabel: LabelWithMargin?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        commentLabel = LabelWithMargin()
        commentLabel?.textInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        commentLabel?.translatesAutoresizingMaskIntoConstraints = false
        commentLabel?.layer.cornerRadius = 5
        commentLabel?.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        commentLabel?.layer.borderWidth = 2
        
        self.contentView.addSubview(commentLabel!)
        
        NSLayoutConstraint.activate([commentLabel!.leftAnchor.constraint(equalTo: self.contentView.leftAnchor)])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
