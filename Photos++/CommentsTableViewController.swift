//
//  CommentsTableViewController.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/27/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

class CommentsTableViewController: UITableViewController {
    open var cancelButtonItem: UIBarButtonItem {
        get {
            return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction(_:)))
        }
    }
    
    var photo: Photo!
    var photoModelService: PhotoModelService!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.leftBarButtonItem = self.cancelButtonItem
        
        self.tableView.rowHeight=UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight=40
        //self.tableView.isEditing = true
        
        //self.view.backgroundColor = UIColor.clear
        self.view.backgroundColor = UIColor(white: 0.5, alpha: 0.7)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = self.photo.numberOfComments()
        //if self.isEditing {
            numberOfRows += 1
        //}
        
        return numberOfRows
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        if /*self.isEditing && */indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddItemCellIdentifier", for: indexPath) as! TextFieldTableViewCell
            //cell.contentView.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
            cell.delegate = self
            cell.detailTextLabel?.text = ""
            cell.detailTextLabel?.backgroundColor = UIColor.lightGray
            cell.setSearchHint(hint: "Have something to say? Type here")
            cell.setSubmitFATitle(FontAwesomeIcon.faCommentO, for: .normal)
            cell.submitButton.backgroundColor = UIColor.primary()
        
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCellIdentifier", for: indexPath) as! CommentTableViewCell
        
        let trueIndexPath = self.trueIndexPathFromIndexPath(indexPath: indexPath)
        let comment = self.photo.commentAtIndex(index: trueIndexPath.row)
        
        //let style: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        //style.alignment = .justified
        //style.firstLineHeadIndent = 5.0
        //style.headIndent = 5.0
        //style.tailIndent = -5.0
        //let attrText: NSAttributedString = NSAttributedString(string: comment.text,
        //                                                      attributes: [NSParagraphStyleAttributeName:style])
        
        //cell.textLabel?.text = comment.text
        //cell.textLabel?.attributedText = attrText
        //cell.textLabel?.numberOfLines = 10
        //cell.detailTextLabel?.text = DateFormatter().string(from: comment.createdDate)
        cell.commentLabel?.layer.borderColor = UIColor.orange.cgColor
        cell.commentLabel?.layer.backgroundColor = UIColor.lemonChiffon().cgColor
        cell.commentLabel?.text = comment.text
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.backgroundColor = UIColor.clear.cgColor//UIColor.lemonChiffon()
        cell.textLabel?.backgroundColor = UIColor.lemonChiffon()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        /*if self.isEditing {
            self.tableView.beginUpdates()
            for section in 0 ..< self.tableView.numberOfSections {
                self.tableView.insertRows(at: [IndexPath(row: 0, section: section)], with: .automatic)
            }
            self.tableView.endUpdates()
        } else {
            self.tableView.beginUpdates()
            for section in 0 ..< self.tableView.numberOfSections {
                self.tableView.deleteRows(at: [IndexPath(row: 0, section: section)], with: .automatic)
            }
            self.tableView.endUpdates()
        }*/
    }
    
    // Override to support editing the table view. (UITableViewDataSource)
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let comment = self.photo.commentAtIndex(index: indexPath.row-1)
            self.photoModelService.photo(self.photo, removeComment: comment)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            let textFieldCell = self.tableView.cellForRow(at: indexPath) as! TextFieldTableViewCell
            if let text = textFieldCell.textField.text, text.isNotBlank() {
                textFieldCell.textField.text = ""
                self.addCommentText(commentText: text, inSection: indexPath.section)
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension CommentsTableViewController {
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row == 0 {
            return .insert
        }
        
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return indexPath.row != 0
    }
}

// MARK: - Privates

extension CommentsTableViewController {
    fileprivate func addCommentText(commentText: String, inSection section: Int) {
        self.photoModelService.photo(self.photo, addCommentWithText: commentText)
        
        let insertIndexPath = IndexPath(row: self.photo.numberOfComments(),
                                        section: section)
        self.tableView.insertRows(at: [insertIndexPath], with: .automatic)
    }
    
    fileprivate func trueIndexPathFromIndexPath(indexPath: IndexPath) -> IndexPath {
        //if self.isEditing {
            return IndexPath(row: (indexPath as NSIndexPath).row-1, section: (indexPath as NSIndexPath).section)
        //}
        
        //return indexPath
    }
    
    @objc fileprivate func cancelAction(_ sender: AnyObject) {
        self.resignFirstResponder()
        if let presentingViewController = self.presentingViewController {
            presentingViewController.viewWillAppear(true)
            presentingViewController.dismiss(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
}

extension CommentsTableViewController: TextFieldTableViewCellDelegate {
    func submitWithTextInput(text: String) {
        if text.isNotBlank() {
            self.addCommentText(commentText: text, inSection: 0)
        }
    }
}
