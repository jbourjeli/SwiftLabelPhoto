//
//  RoundBarButtonItem.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/10/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

public class FAButton: UIButton {
    
    @IBInspectable var fontAwesomeSize: CGFloat = UIFont.buttonFontSize {
        didSet {
            self.titleLabel?.font = UIFont.fontAwesomeOfSize(fontSize: self.fontAwesomeSize)
        }
    }
    
    @IBInspectable var round: Bool = true {
        didSet {
            self.layoutSubviews()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.defaultSettings()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.defaultSettings()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if self.round {
            self.layer.cornerRadius = (self.frame.width / 2.0)
            self.layer.borderWidth = 1.0
            self.layer.borderColor = UIColor.clear.cgColor
            self.layer.masksToBounds = true
        }
        
        self.layer.shadowOffset = CGSize(width: 0, height: 1.5);
        self.layer.shadowRadius = 0.5;
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowColor = self.titleShadowColor(for: self.state)?.cgColor
    }
    
    public func setFATitle(_ faTitle: FontAwesomeIcon, for controlState: UIControlState) {
        super.setTitle(faTitle.rawValue, for: controlState)
    }
    
    // MARK: - Privates
    
    private func defaultSettings() {
        self.titleLabel?.adjustsFontSizeToFitWidth = true        
    }
}
