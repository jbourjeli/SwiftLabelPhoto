//
//  PhotoRepository.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/29/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

protocol PhotoRepository {
    func saveImage(_ image: UIImage) throws -> String
    
    func deleteImage(withFilename filename: String) throws
    
    func loadImage(withFilename filename: String) throws -> UIImage
}
