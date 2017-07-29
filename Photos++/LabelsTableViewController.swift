//
//  LabelsViewController.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/22/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

class LabelsTableViewController: UITableViewController {
    var dataSource: LabelModelService?
    
    fileprivate let addCellIdentifier = "AddItemCellIdentifier"
    fileprivate let cellIdentifier = "LabelDetailCell"
    
    fileprivate var searchController: UISearchController!
    fileprivate var searchBarButton: UIBarButtonItem!
    fileprivate var cancelBarButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUIViews()
        
        definesPresentationContext = true
        
        self.tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Actions
    
    @objc fileprivate func showSearchAction(_ sender: UIBarButtonItem) {
        self.toggleSearchBar()
    }
    
    @objc fileprivate func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension LabelsTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = self.dataSource?.numberOfLabels() ?? 0
        
        if self.isEditing {
            numberOfRows += 1
        }
        
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isEditing && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: addCellIdentifier, for: indexPath) as! TextFieldTableViewCell
            cell.delegate = self
            cell.detailTextLabel?.text = ""
            cell.detailTextLabel?.backgroundColor = UIColor.lightGray
            cell.setSubmitFATitle(FontAwesomeIcon.faTag, for: .normal)
            cell.setSearchHint(hint: "Add a new label")
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let labelIndexPath = self.trueIndexPathForLabelFromIndexPath(indexPath: indexPath)
        if let label = self.dataSource?.labelAtIndexPath(labelIndexPath) {
            cell.textLabel?.text = label.longName
            cell.detailTextLabel?.text = String(label.numberOfLabeledPhotos())
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
}

// MARK: - UITableViewDelegate
extension LabelsTableViewController {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let labelModelService = self.dataSource,
                let label = self.dataSource?.labelAtIndexPath(trueIndexPathForLabelFromIndexPath(indexPath: indexPath)) {
                
                if labelModelService.isLabelInUse(label) {
                    let alert = UIAlertController.yesNoAlert(
                        title: "Remove Label",
                        message: "Since this label is in use by \(labelModelService.numberOfPhotosUsingLabel(label)) photo(s), by deleting it, it will be removed from all photos. With that said, are you sure you want to delete it?",
                        destructiveYes:  true ) { [unowned self, label] alertAction in

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
                
                self.dataSource?.insertLabel(Label(longName: newLabel))
                let insertIndexPath = IndexPath(row: self.dataSource!.numberOfLabels(),
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
}

extension LabelsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.dataSource?.setLabelFilter(pattern: searchController.searchBar.text)
        self.tableView.reloadData()
    }
}

extension LabelsTableViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarSetVisibility(visible: false)
    }
}

// MARK: - Privates
extension LabelsTableViewController {
    fileprivate func trueIndexPathForLabelFromIndexPath(indexPath: IndexPath) -> IndexPath {
        if self.isEditing {
            return IndexPath(row: (indexPath as NSIndexPath).row-1, section: (indexPath as NSIndexPath).section)
        }
        
        return indexPath
    }
    
    fileprivate func deleteLabel(_ label: Label, atIndexPath indexPath: IndexPath) {
        self.dataSource?.deleteLabel(label)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    fileprivate func toggleSearchBar() {
        if self.navigationItem.titleView == searchController.searchBar {
            self.searchBarSetVisibility(visible: false)
        } else {
            self.searchBarSetVisibility(visible: true)
        }
    }
    
    fileprivate func searchBarSetVisibility(visible: Bool) {
        if visible {
            let searchBar = self.searchController.searchBar
            searchBar.alpha = 0
            navigationItem.titleView = searchBar
            navigationItem.setLeftBarButtonItems(nil, animated: true)
            navigationItem.setRightBarButtonItems(nil, animated: true)
            UIView.animate(withDuration: 0.8, animations: {
                searchBar.alpha = 1
                }, completion: { finished in
                    searchBar.becomeFirstResponder()
            })
        } else {
            navigationItem.setLeftBarButtonItems(self.leftBarButtons(), animated: true)
            navigationItem.setRightBarButtonItems(self.rightBarButtons(), animated: true)
            UIView.animate(withDuration: 0.8, animations: {
                self.navigationItem.titleView = nil
                }, completion: { finished in
            })
        }
    }
    
    fileprivate func rightBarButtons() -> [UIBarButtonItem] {
        return [self.editButtonItem, self.searchBarButton]
    }
    
    fileprivate func leftBarButtons() -> [UIBarButtonItem] {
        return [self.cancelBarButton]
    }
    
    fileprivate func initUIViews() {
        if self.searchBarButton == nil {
            self.searchBarButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchAction(_:)))
        }
        
        if self.cancelBarButton == nil {
            self.cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction(_:)))
        }
        
        if self.searchController == nil {
            searchController = UISearchController(searchResultsController: nil)
            searchController.searchResultsUpdater = self
            searchController.dimsBackgroundDuringPresentation = false
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.searchBar.showsCancelButton = true
            searchController.searchBar.searchBarStyle = .minimal
            searchController.searchBar.delegate = self
        }
        
        self.navigationItem.leftBarButtonItems = self.leftBarButtons()
        self.navigationItem.rightBarButtonItems = self.rightBarButtons()
    }
}

extension LabelsTableViewController: TextFieldTableViewCellDelegate {
    func submitWithTextInput(text: String) {
        if text.isNotBlank() {
            self.dataSource?.insertLabel(Label(longName: text))
            
            let insertIndexPath = IndexPath(row: self.dataSource!.numberOfLabels(),
                                            section: 0)
            self.tableView.insertRows(at: [insertIndexPath], with: .automatic)
        }
    }
}
