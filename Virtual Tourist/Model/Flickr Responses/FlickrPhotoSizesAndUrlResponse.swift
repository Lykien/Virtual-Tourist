//
//  FlickrPhotoSizesAndUrlResponse.swift
//  Virtual Tourist
//
//  Created by Nils Riebeling on 19.12.19.
//  Copyright © 2019 Nils Riebeling. All rights reserved.
//

import Foundation

struct FlickrPhotoSizesAndUrlResponse: Codable {
 
    let sizes: Sizes
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case sizes
        case status = "stat"
    }
}

struct Sizes: Codable {
    
    let canBlog: Int
    let canPrint: Int
    let canDownload: Int
    let pictureSizes: [Size]
    
    
    
     enum CodingKeys: String, CodingKey {
    
        case canBlog = "canblog"
        case canPrint = "canprint"
        case canDownload = "candownload"
        case pictureSizes = "size"
        
}
}

struct Size: Codable {
    
    let label: String
    let width: Int
    let height: Int
    let source: String
    let url: String
    let media: String
    
}
