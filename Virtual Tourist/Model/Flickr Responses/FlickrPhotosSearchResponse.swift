//
//  FlickrPhotosSearchResponse.swift
//  Virtual Tourist
//
//  Created by Nils Riebeling on 19.12.19.
//  Copyright © 2019 Nils Riebeling. All rights reserved.
//

import Foundation


struct FlickrPhotosSearchResponse: Codable {
    
    let photos: Photos
    
}

struct Photos: Codable {
    
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [PhotoRequest]
}

