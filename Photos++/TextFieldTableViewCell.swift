//
//  TextFieldTableViewCell.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/16/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

protocol TextFieldTableViewCellDelegate {
    func submitWithTextInput(text: String)
}

public class TextFieldTableViewCell: UITableViewCell {

    var textField: UITextField!
    var submitButton: FAButton!
    
    var delegate: TextFieldTableViewCellDelegate? {
        didSet {
            self.submitButton.addTarget(self,
                                        action: #selector(self.submitButtonAction(sender:)),
                                        for: .primaryActionTriggered)
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        
        self.textField = UITextField()
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        
        submitButton = FAButton()
        self.submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.fontAwesomeSize = UIFont.buttonFontSize
        submitButton.backgroundColor = UIColor.primary()
        
        self.contentView.addSubview(textField)
        self.contentView.addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            self.textField.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            self.textField.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5),
            self.textField.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.textField.heightAnchor.constraint(equalToConstant: 44),
            
            self.submitButton.leadingAnchor.constraint(equalTo: self.textField.trailingAnchor),
            self.submitButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -3),
            self.submitButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
        
        self.selectionStyle = .none
    }

    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override public func prepareForReuse() {
        self.textField.text = ""
    }
    
    public func setSearchHint(hint: String) {
        self.textField.placeholder = hint
    }
    
    public func setSubmitTitle(_ title: String, for forState: UIControlState) {
       submitButton.setTitle(title, for: forState)
    }
    
    public func setSubmitFATitle(_ faTitle: FontAwesomeIcon, for forState: UIControlState) {
        submitButton.setTitle(faTitle.rawValue, for: forState)
    }
    
    // MARK: - Privates
    
    @objc private func submitButtonAction(sender: AnyObject) {
        if let delegate = self.delegate,
            let text = self.textField.text {
            self.textField.text = ""
            delegate.submitWithTextInput(text: text)
            self.textField.resignFirstResponder()
        }
    }
}
