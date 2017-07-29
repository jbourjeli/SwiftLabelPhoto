//
//  MessagesViewController.swift
//  MessageAPhoto
//
//  Created by Joseph Bourjeli on 10/16/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    fileprivate var searchBar: UISearchBar = UISearchBar()
    fileprivate var photosCollectionView: UICollectionView!
    
    var photoModelService: PhotoModelService?
    
    var collectionViewTopConstraint: NSLayoutConstraint!
    var searchBarTop, searchBarTrailing, searchBarLeading: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.searchBar.delegate = self
        self.searchBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.searchBar)
        
        let layout = MosaicCollectionViewLayout()
        layout.delegate = self
        
        self.photosCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.photosCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.photosCollectionView.dataSource = self
        self.photosCollectionView.delegate = self
        self.photosCollectionView.register(ThumbnailCollectionViewCell.self, forCellWithReuseIdentifier: "CellIdentifier")
        self.view.addSubview(self.photosCollectionView)
        
        // MARK: - Setup anchor constraints
            // For CollectionView
        self.photosCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.photosCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.photosCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.collectionViewTopConstraint = NSLayoutConstraint(item: self.photosCollectionView, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .top, multiplier: 1, constant: 0)
        self.collectionViewTopConstraint.isActive = true
        
        //self.view.addConstraint(self.collectionViewTopConstraint)
            // For searchBar
        self.searchBarTop = NSLayoutConstraint(item: self.searchBar, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .top, multiplier: 1, constant: 85)
        self.searchBarLeading = NSLayoutConstraint(item: self.searchBar, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
        self.searchBarTrailing = NSLayoutConstraint(item: self.searchBar, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        
        self.photoModelService = Service.photoModelService()
        
        self.configure(forPresentationStyle: self.presentationStyle)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
        self.configure(forPresentationStyle: self.presentationStyle)
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
        self.configure(forPresentationStyle: presentationStyle)
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
//        self.configure(forPresentationStyle: presentationStyle)
        
    }
    
    // MARK: - Privates
    
    fileprivate func composeMessageFor(photo: Photo) -> MSMessage {
        let layout = MSMessageTemplateLayout()
        layout.image = photo.thumbnail
        if photo.numberOfLabels() > 0 {
            layout.imageSubtitle = photo.labelAtIndex(index: 0).longName ?? ""
        }
        
        let message = MSMessage(session: MSSession())
        message.layout = layout
        
        return message
    }
    
    fileprivate func send(message: MSMessage) {
        guard let conversation = self.activeConversation else {
            fatalError("No active conversation found!")
        }
        
        conversation.insert(message, completionHandler: { error in
            if let error = error {
                print("Error inserting message in conversation: [\(error)]")
            }
        })
    }
    
    fileprivate func configure(forPresentationStyle presentationStyle: MSMessagesAppPresentationStyle) {
        switch presentationStyle {
        case .compact:
            UIView.transition(with: self.view, duration: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.collectionViewTopConstraint.constant = 0
                self?.searchBar.removeFromSuperview()
                }, completion: nil)
        default:
            UIView.transition(with: self.view, duration: 1.0, options: .transitionFlipFromBottom, animations: { [weak self] in
                if let searchBar = self?.searchBar {
                    self?.view.addSubview(searchBar)
                }
                
                self?.searchBarTop.isActive = true
                self?.searchBarLeading.isActive = true
                self?.searchBarTrailing.isActive = true

                self?.collectionViewTopConstraint.constant = 44
                }, completion: nil)
            //self.searchBar.alpha = 0//backgroundColor = UIColor.white
        }

        //self.view.layoutSubviews()
        //self.view.setNeedsLayout()
    }
}

// MARK: - UICollectionViewDataSource
extension MessagesViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoModelService?.numberOfPhotos() ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellIdentifier", for: indexPath) as! ThumbnailCollectionViewCell
        
        viewCell.imageView.image = self.photoModelService?.photoAtIndexPath(indexPath)?.thumbnail
        
        return viewCell
    }
}

// MARK: - UICollectionViewDelegate
extension MessagesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = self.photoModelService?.photoAtIndexPath(indexPath)
        
        self.requestPresentationStyle(.compact)
        self.send(message: self.composeMessageFor(photo: photo!))
    }
}

extension MessagesViewController: MosaicCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeOfCellAtIndexPath indexPath: IndexPath) -> CGSize {
        let photo = self.photoModelService?.photoAtIndexPath(indexPath)
        
        return photo?.size ?? CGSize.zero
    }
}

// MARK: - UISearchBarDelegate
extension MessagesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.photoModelService?.setFilter(pattern: searchText)
        self.photosCollectionView.reloadData()
    }
}