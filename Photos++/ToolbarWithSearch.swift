//
//  ToolbarWithSearch.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/21/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

public class ToolbarWithSearch: UIToolbar {

    private var editMode = false
    private var originalItems = [UIBarButtonItem]()
    private var searchItems = [UIBarButtonItem]()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initItems()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initItems()
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    lazy var searchBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search,
                               target: self,
                               action: #selector(searchAction(sender:)))
    }()
    
    lazy var searchTextBarButtonItem: UIBarButtonItem = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 0))
        textField.placeholder = "Searching for something?"
        textField.isEnabled = true
        textField.backgroundColor = UIColor.white
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.layer.borderWidth = 1.0
        
        return UIBarButtonItem(customView: textField)
    }()
    
    lazy var searchDoneBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done,
                               target: self,
                               action: #selector(searchAction(sender:)))
    }()
    
    lazy var flexibleSpace: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    }()
    
    // MARK: - Privates
    
    private func initItems() {
        if self.items == nil {
            self.items = [UIBarButtonItem]()
        }
        self.items!.append(self.searchBarButtonItem)
        
        self.originalItems.append(contentsOf: self.items!)
        
        self.searchItems = [self.searchTextBarButtonItem, self.flexibleSpace, self.searchDoneBarButtonItem]
    }
    
    private func setEditEnabled(enabled: Bool) {
        editMode = enabled
        
        if editMode {
            self.setItems(self.searchItems, animated: true)
        } else {
            self.setItems(self.originalItems, animated: true)
        }
    }
    
    @objc private func searchAction(sender: Any) {
        setEditEnabled(enabled: !editMode)
    }
}
