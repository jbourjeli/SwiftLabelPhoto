//
//  PhotosViewController.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/5/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit
import FMMosaicLayout

class PhotosViewController: UIViewController {

    @IBOutlet fileprivate weak var photosCollectionView: UICollectionView!
    @IBOutlet fileprivate weak var searchBar: UISearchBar!
    @IBOutlet fileprivate weak var labelsBarButtonItem: UIBarButtonItem!
    
    var photosModelService: PhotoModelService!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.photosCollectionView.dataSource = self
        self.photosCollectionView.delegate = self
        self.photosCollectionView.contentInset = UIEdgeInsets(top: 23, left: 5, bottom: 10, right: 5)
        //self.photosCollectionView.collectionViewLayout = FMMosaicLayout()
        self.photosCollectionView.collectionViewLayout = MosaicCollectionViewLayout()
        
        if let mosaicLayout = self.photosCollectionView.collectionViewLayout as? FMMosaicLayout {
            mosaicLayout.delegate = self
        }
        
        if let mosaicLayout = self.photosCollectionView.collectionViewLayout as? MosaicCollectionViewLayout {
            mosaicLayout.delegate = self
        }
        
        self.searchBar.delegate = self
        self.searchBar.showsCancelButton = true
        self.searchBar.showsSearchResultsButton = false        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.photosCollectionView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.photosCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate enum CellIdentifier: String {
        case PhotoCell="PhotoCell"
    }
    
    fileprivate func showCameraController() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.showImagePickerControllerFromSource(.camera)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func showCameraAction(_ sender: UIBarButtonItem) {
        self.showCameraController()
    }
    
    @IBAction fileprivate func showPhotoLibraryController(_ sender: UIBarButtonItem) {
        self.showImagePickerControllerFromSource(.photoLibrary)
    }
    
    @IBAction func showLabelsAction(_ sender: UIBarButtonItem) {
        if let labelsNavVC = self.storyboard?.instantiateViewController(withIdentifier: "LabelsViewControllerNav") as? UINavigationController {
            if let labelsVC = labelsNavVC.viewControllers.first as? LabelsTableViewController {
                labelsVC.dataSource = Service.labelModelService()
            }
            self.present(labelsNavVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - Privates
    fileprivate func showImagePickerControllerFromSource(_ source: UIImagePickerControllerSourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = source
        imagePickerController.delegate = self
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    fileprivate func showDetailOfPhoto(_ photo: Photo) {
        if let photoDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoDetailViewController") as? PhotoDetailViewController {
            photoDetailViewController.photo = photo
            photoDetailViewController.photoModelService = self.photosModelService
            
            self.present(photoDetailViewController, animated: true, completion: nil)
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension PhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photosModelService.numberOfPhotos()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.PhotoCell.rawValue, for: indexPath) as! PhotoCollectionViewCell

        if let photo = self.photosModelService.photoAtIndexPath(indexPath) {
            cell.photo = photo
        }
        
        cell.delegate = self
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let photo = self.photosModelService.photoAtIndexPath(indexPath) {
            self.showDetailOfPhoto(photo)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        if let photo = self.photosModelService.photoAtIndexPath(indexPath) {
            return !photo.isLink()
        }
        
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {

        return #selector(UIResponderStandardEditActions.delete(_:)) == action
    }
    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        print("Perform action in \(sender)")
    }
}

extension PhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let capturedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        var photo: Photo!
        
        switch picker.sourceType {
        case .photoLibrary:
            let originalImageURL = info[UIImagePickerControllerReferenceURL] as! URL
            photo = self.photosModelService.newPhotoFromImage(capturedImage, refURL: originalImageURL)
        default:
            print("CapturedImage: \(capturedImage.imageOrientation.rawValue)")
            photo = self.photosModelService.photoFrom(image: capturedImage.normalized())
            break
        }
        
        self.photosModelService.addPhoto(photo)
        self.photosCollectionView.reloadData()
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension PhotosViewController: FMMosaicLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: FMMosaicLayout!, numberOfColumnsInSection section: Int) -> Int {
        let numberOfPhotosInSection = self.photosModelService.numberOfPhotos()
        
        return max(numberOfPhotosInSection % 2, 1)
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: FMMosaicLayout!, mosaicCellSizeForItemAt indexPath: IndexPath!) -> FMMosaicCellSize {
        return indexPath.row % 12 == 0 ? .big : .small
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: FMMosaicLayout!, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: FMMosaicLayout!, interitemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension PhotosViewController: MosaicCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeOfCellAtIndexPath indexPath: IndexPath) -> CGSize {
        guard let photo = self.photosModelService.photoAtIndexPath(indexPath)
            else { return CGSize(width: 0, height: 0) }

        return photo.size
    }
}

extension PhotosViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterBy(labelPattern: searchBar.text, andReload: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.filterBy(labelPattern: searchBar.text, andReload: true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        self.filterBy(labelPattern: nil, andReload: true)
        searchBar.resignFirstResponder()
    }
    
    private func filterBy(labelPattern: String?, andReload reload: Bool) {
        if let searchText = labelPattern {
            self.photosModelService.setFilter(pattern: searchText)
        } else {
            self.photosModelService.setFilter(pattern: nil)
        }
        
        if reload {
            self.photosCollectionView.reloadData()
        }
    }
}

extension PhotosViewController: PhotoCollectionViewCellDelegate {
    func delete(photo: Photo) {
        guard let indexPathForPhoto = self.photosModelService.indexPathForPhoto(photo)
            else { return }
        
        do {
            try self.photosModelService.deletePhoto(photo)
            self.photosCollectionView.deleteItems(at: [indexPathForPhoto])
        } catch let error {
            print("PhotosViewController.delete(_:) => \(error)")
        }
    }
}
