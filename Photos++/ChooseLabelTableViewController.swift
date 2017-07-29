//
//  ListOfLabelsTableViewController.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/13/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

protocol ChooseLabelTableViewControllerDelegate {
    func didSelectLabel(_ label: Label)
}

class ChooseLabelTableViewController: UITableViewController {

    fileprivate let optionCellIdentifier = "CellIdentifier"
    fileprivate let addCellIdentifier = "AddCellIdentifier"
    
    var labelModelService: LabelModelService?
    
    var delegate: ChooseLabelTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.leftBarButtonItem = self.cancelButtonItem()
        
        //self.view.backgroundColor = UIColor.clear
        self.view.backgroundColor = UIColor(white: 0.5, alpha: 0.7)
        
        self.tableView.rowHeight=UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight=40
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
        var numberOfRows = self.labelModelService?.numberOfLabels() ?? 0
        
        if self.isEditing {
            numberOfRows += 1
        }
        
        return numberOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isEditing && (indexPath as NSIndexPath).row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: addCellIdentifier, for: indexPath) as! TextFieldTableViewCell
            cell.delegate = self
            cell.detailTextLabel?.text = ""
            cell.setSearchHint(hint: "Add a new label")
            cell.setSubmitFATitle(FontAwesomeIcon.faTag, for: .normal)
            
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: optionCellIdentifier, for: indexPath)
        guard let labelModelService = self.labelModelService
            else { return cell }
        
        if let label = labelModelService.labelAtIndexPath(self.indexPathForLabelFromIndexPath(indexPath)) {
            cell.textLabel?.text = label.longName
            cell.detailTextLabel?.text = String(labelModelService.numberOfPhotosUsingLabel(label))
        }
        
        return cell
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if self.isEditing {
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
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let label = self.labelModelService?.labelAtIndexPath(indexPath) {
            self.delegate?.didSelectLabel(label)
            self.dismissAction(self)
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let labelModelService = self.labelModelService,
                let label = labelModelService.labelAtIndexPath(self.indexPathForLabelFromIndexPath(indexPath)) {
                
                if labelModelService.isLabelInUse(label) {
                    let alert = UIAlertController.yesNoAlert(
                        title: "Remove Label",
                        message: "Since this label is in use by \(labelModelService.numberOfPhotosUsingLabel(label)) photo(s), by deleting it, it will be removed from all photos. With that said, are you sure you want to delete it?",
                        destructiveYes: true) { [unowned self, label] alertAction in
                                                                
                            self.deleteLabel(label, atIndexPath: indexPath)
                    }                    
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.deleteLabel(label, atIndexPath: indexPath)
                }
            }
        } else if editingStyle == .insert {
            let textFieldcell = self.tableView.cellForRow(at: indexPath) as! TextFieldTableViewCell
            
            if let newLabel = textFieldcell.textField.text, newLabel.isNotBlank() {
                textFieldcell.textField.text = ""
                
                self.labelModelService?.insertLabel(Label(longName: newLabel))
                let insertIndexPath = IndexPath(row: self.labelModelService!.numberOfLabels(),
                                                  section: (indexPath as NSIndexPath).section)
                self.tableView.insertRows(at: [insertIndexPath], with: .automatic)
            }
        }    
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if (indexPath as NSIndexPath).row == 0 {
            return .none
        }
        
        return .delete
    }
    
    // MARK: - Privates
    
    fileprivate func indexPathForLabelFromIndexPath(_ indexPath: IndexPath) -> IndexPath {
        if self.isEditing {
            return IndexPath(row: (indexPath as NSIndexPath).row-1, section: (indexPath as NSIndexPath).section)
        }
        
        return indexPath
    }
    
    fileprivate func deleteLabel(_ label: Label, atIndexPath indexPath: IndexPath) {
        self.labelModelService?.deleteLabel(label)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    fileprivate func cancelButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissAction(_:)))
    }
    
    @objc fileprivate func dismissAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ChooseLabelTableViewController: TextFieldTableViewCellDelegate {
    func submitWithTextInput(text: String) {
        if text.isNotBlank() {
            self.labelModelService?.insertLabel(Label(longName: text))
            let insertIndexPath = IndexPath(row: self.labelModelService!.numberOfLabels(),
                                            section: 0)
            self.tableView.insertRows(at: [insertIndexPath], with: .automatic)
        }
    }
}
