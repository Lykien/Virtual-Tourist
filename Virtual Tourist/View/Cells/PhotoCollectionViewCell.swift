//
//  photoCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Nils Riebeling on 20.12.19.
//  Copyright © 2019 Nils Riebeling. All rights reserved.
//

import Foundation
import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
 
    // MARK: Outlets
    
    @IBOutlet weak var photo: UIImageView!
    

    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                photo.alpha = 0.5
            }
            else {
                photo.alpha = 1.0
            }
        }
    }
    
}
