//
//  LabelCollectionViewCell.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/12/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

protocol LabelCollectionViewCellDelegate {
    func removeLabel(_ label: Label)
}

class LabelCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var label: Label! {
        didSet {
            self.titleLabel.text = label.longName
        }
    }
    
    var delegate: LabelCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.masksToBounds = true
        
        // MARK: - Custom UIMenuItems
        let removeLabelSelector = #selector(removeLabelFromPhoto(_:))
        if UIMenuController.shared.menuItems != nil {
            let filteredMenuItems = UIMenuController.shared.menuItems!.filter({ mi in
                    return mi.action == removeLabelSelector
                })
            
            if filteredMenuItems.count == 0 {
                UIMenuController.shared.menuItems!.append(
                    UIMenuItem(title: "Remove", action: removeLabelSelector))
            }
        } else {
            UIMenuController.shared.menuItems = [UIMenuItem(title: "Remove", action: removeLabelSelector)]
        }

    }
    
    func removeLabelFromPhoto(_ sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.removeLabel(self.label)
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(removeLabelFromPhoto(_:))
    }
}
