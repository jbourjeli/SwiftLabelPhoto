//
//  LocalPhotoRepository.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/29/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

fileprivate let fileImagePrefix = "image-"
fileprivate let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
fileprivate let imagesDirectoryURL = PropertyManager.default.sharedDocumentURL.appendingPathComponent("images")

public class LocalPhotoRepository: PhotoRepository {

    public enum RepositoryError: Error {
        case NoWhereToSave
        case InvalidAssetsPath
        case InvalidImageData
    }
    
    public func saveImage(_ image: UIImage) throws -> String {
        if let assetsPath = self.assetsPath() {
            let fileURL = URL(fileURLWithPath: assetsPath).appendingPathComponent("\(fileImagePrefix)\(UUID.init().uuidString)")

            self.doAsync {
                do {
                    print("saveImage: save to \(fileURL)")
                    try UIImagePNGRepresentation(image)?.write(to: fileURL)
                } catch let error {
                    print("Error: saveImage [\(error)]")
                }
            }
            
            return fileURL.lastPathComponent
        }
        
        throw RepositoryError.NoWhereToSave
    }
    
    public func deleteImage(withFilename filename: String) throws {
        if let assetsPath = self.assetsPath() {
            let fileURL = URL(fileURLWithPath: assetsPath).appendingPathComponent(filename)
            try FileManager.default.removeItem(at: fileURL)
        }
    }
    
    public func loadImage(withFilename filename: String) throws -> UIImage {
        guard let assetsPath = self.assetsPath() else {
            throw RepositoryError.InvalidAssetsPath
        }
        
        let fileURL = URL(fileURLWithPath: assetsPath).appendingPathComponent(filename)
        let data = try Data(contentsOf: fileURL)
            
        if let image = UIImage(data: data) {
            return image
        }
            
        throw RepositoryError.InvalidImageData
    }
    
    public static func migrateImagesToAppGroup() {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: imagesDirectoryURL.path) {
            do {
                try fileManager.createDirectory(atPath: imagesDirectoryURL.path, withIntermediateDirectories: false, attributes: nil)
            } catch let error {
                print("LocalPhotoRepositor: Error creating images directory [\(error)]")
            }
        }
        
        if let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let documentURL = URL(fileURLWithPath: documentPath, isDirectory: true)
            do {
                try fileManager.contentsOfDirectory(atPath: documentPath).forEach { element in
                    if element.hasPrefix(fileImagePrefix) {
                        try fileManager.moveItem(at: documentURL.appendingPathComponent(element),
                                                 to: imagesDirectoryURL.appendingPathComponent(element))
                    }
                }
            } catch let error {
                print("LocalPhotoRepositor: Error reading document directory [\(error)]")
            }
            
        }
    }
    
    // MARK: - Privates
    
    fileprivate func assetsPath() -> String? {
        return imagesDirectoryURL.path
    }
    
    fileprivate func doAsync(_ doBlock: @escaping () -> Void ) {
        let backgroundQueue = DispatchQueue.global(qos: .background)
        backgroundQueue.async() {
            doBlock()
        }
    }
}
