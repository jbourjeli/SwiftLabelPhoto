//
//  PhotoDetailViewController.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/9/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit
import SwiftOverlays

class PhotoDetailViewController: UIViewController {
    
    var photo: Photo!
    var photoModelService: PhotoModelService!
    
    @IBOutlet fileprivate weak var originalPhotoImageView: UIImageView!
    @IBOutlet fileprivate weak var labelCollectionView: UICollectionView!
    
    @IBOutlet fileprivate weak var addLabelButton: FAButton!
    
    @IBOutlet fileprivate weak var commentButton: FAButton!
    @IBOutlet fileprivate weak var deleteButton: FAButton!
    @IBOutlet fileprivate weak var exportButton: FAButton!
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.labelCollectionView.dataSource = self
        self.labelCollectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        self.labelCollectionView.collectionViewLayout = layout
        
        self.originalPhotoImageView.contentMode = .scaleAspectFit
        
        self.scrollView.minimumZoomScale=1.0;
        self.scrollView.maximumZoomScale=3.0;
        self.scrollView.contentSize=self.originalPhotoImageView.frame.size
        self.scrollView.delegate = self
        
        self.updateActionBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.originalPhotoImageView.image == nil {
            //let _ = EZLoadingActivity.show("Loading ...", disableUI: true)
            self.showWaitOverlayWithText("Fetching Image ...")
        }
        
        self.labelCollectionView.reloadData()
        self.updateActionBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.originalPhotoImageView.image == nil {
            photo.fetchOriginalImage { [unowned self] (image, error) in
                if let error = error {
                    self.present(UIAlertController.alert(title: "Error fetching image",
                                                         message: "There was an error fetching the original image. Will display a lower resolution version \n [Error: \(error)]"),
                                 animated: true, completion: nil)
                }
                
                //let _ = EZLoadingActivity.hide()
                self.removeAllOverlays()
                self.originalPhotoImageView.image = image
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    @IBAction fileprivate func dismissAction(_ sender: AnyObject) {
        if let photosViewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotosViewController") as? PhotosViewController {
            
            photosViewController.photosModelService = self.photoModelService
            self.dismiss(animated: true, completion: nil)
            /*UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveLinear, animations: {
                self.view.alpha = 0
                //self.view.frame = CGRectZero
                photosViewController.view.alpha = 1
                }, completion: { completed in
                    self.presentViewController(photosViewController, animated: false, completion: nil)
            })*/
        }
    }
        
    @IBAction func showLabelsAction(_ sender: AnyObject) {
        if let navigationVC = self.storyboard?.instantiateViewController(withIdentifier: "ChooseLabelViewController") as? UINavigationController {
            if let chooseLabelVC = navigationVC.viewControllers[0] as? ChooseLabelTableViewController {
                chooseLabelVC.labelModelService = Service.labelModelService()
                chooseLabelVC.delegate = self
                
                navigationVC.modalPresentationStyle = .custom
                navigationVC.transitioningDelegate = self
                self.present(navigationVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func showCommentAction(_ sender: AnyObject) {
        /*let alertController = UIAlertController(title: "Comments", message: "Have something to say about this photo?", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { textField in
            textField.clearButtonMode = .whileEditing
            textField.placeholder = "Enter it here"
        })
        
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { [unowned alertController, unowned self] alertAction in
            if let textField = alertController.textFields?.first {
                if let text = textField.text {
                    self.photoModelService.photo(self.photo, addCommentWithText: text)
                    self.updateActionBar()
                }
            }
        }))
        //alertController.addAction(UIAlertAction(title: "Show Comments", style: .default, handler: {alertAction in }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in }))
        
        self.present(alertController, animated: true, completion: nil)*/
        if let commentsViewControllerNav = self.storyboard?.instantiateViewController(withIdentifier: "CommentsViewControllerNav") as? UINavigationController {
            if let commentsViewController = commentsViewControllerNav.viewControllers.first as? CommentsTableViewController {
                commentsViewController.photo = self.photo
                commentsViewController.photoModelService = self.photoModelService
                
                commentsViewControllerNav.modalPresentationStyle = .custom
                commentsViewControllerNav.transitioningDelegate = self
                self.present(commentsViewControllerNav, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func deletePhotoAction(_ sender: AnyObject) {
        if self.photo.isLink() {
            self.photoModelService.unlink(photo: photo)
        } else {
            do {
                try self.photoModelService.deletePhoto(photo)
            } catch let error {
                 print("ERROR: Unable to delete photo because \(error)")
            }
        }
        
        if let presentingVC = self.presentingViewController {
            presentingVC.viewWillAppear(true)
            presentingVC.dismiss(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }

    @IBAction func exportPhotoAction(_ sender: AnyObject) {
        self.blockUI(withMessage: "Fetching image ...")
        self.photo.fetchOriginalImage { [unowned self] (image, error) in
            self.unblockUI()
            self.presentExportOptionsFor(image: image)
        }
        
        // TODO: - This custom function to save allows the option to create a new
        // album and assign the image to the album. More flexible!!
        /*self.photo.exportToPHAsset { [weak self] error in
            DispatchQueue.main.sync {
                self?.unblockUI()
            }            
        }*/
    }
    
    
    // MARK: - Privates
    
    fileprivate func updateActionBar() {
        self.addLabelButton.backgroundColor = UIColor.primary()
        self.addLabelButton.setTitle(FontAwesomeIcon.faTag.rawValue, for: .normal)
        
        let commentTitle: FontAwesomeIcon!
        if self.photo.numberOfComments() > 0 {
            commentTitle = FontAwesomeIcon.faCommentsO
        } else {
            commentTitle = FontAwesomeIcon.faCommentO
        }
        self.commentButton.setFATitle(commentTitle, for: .normal)
        self.commentButton.backgroundColor = UIColor.secondary()
        self.commentButton.titleLabel?.textColor = UIColor.darkText
        
        self.deleteButton.setTitleColor(UIColor.danger(), for: .normal)
        self.deleteButton.setTitleShadowColor(UIColor.clear, for: .normal)
        self.deleteButton.backgroundColor = UIColor.secondary()
        if self.photo.isLink() {
            self.deleteButton.setFATitle(FontAwesomeIcon.faMinusCircle, for: .normal)
        } else {
            self.deleteButton.setFATitle(FontAwesomeIcon.faTrashO, for: .normal)
        }
        
        self.exportButton.setTitleColor(UIColor.primary(), for: .normal)
        self.exportButton.backgroundColor = UIColor.secondary()
        self.exportButton.setTitleShadowColor(UIColor.clear, for: .normal)
        self.exportButton.setFATitle(.faShare, for: .normal)
    }
    
    fileprivate func presentExportOptionsFor(image: UIImage) {
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension PhotoDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photo.numberOfLabels()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelCell", for: indexPath) as! LabelCollectionViewCell
        
        cell.label = self.photoLabelAtIndexPath(indexPath)
        cell.delegate = self
        
        cell.backgroundColor = UIColor.lemonChiffon()
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 0
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let label = self.photoLabelAtIndexPath(indexPath)
        let labelString =  (label.longName ?? label.description) as NSString
        let labelBounds = labelString.boundingRect(with: collectionView.bounds.size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [:], context: nil)
        let sizeForItem = CGSize(width: labelBounds.width+10, height: labelBounds.height+10)
        
        return sizeForItem
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        print("Perform action in \(sender)")
    }
    
    fileprivate func photoLabelAtIndexPath(_ indexPath: IndexPath) -> Label {
        return self.photo.labelAtIndex(index: (indexPath as NSIndexPath).row)
    }
}

extension PhotoDetailViewController: ChooseLabelTableViewControllerDelegate {
    func didSelectLabel(_ label: Label) {
        self.photoModelService.photo(self.photo, addLabel: label)
        self.labelCollectionView.reloadData()
    }
}

extension PhotoDetailViewController: LabelCollectionViewCellDelegate {
    func removeLabel(_ label: Label) {
        self.photoModelService.photo(self.photo, removeLabel: label)
        self.labelCollectionView.reloadData()
    }
}

extension PhotoDetailViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return TransparentPresentationController(presentedViewController: presented, presenting: source)
            //HalfScreenPresentationController(presentedViewController: presented, presenting: source, anchor: .Top)
    }
}

extension PhotoDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.originalPhotoImageView
    }
}
