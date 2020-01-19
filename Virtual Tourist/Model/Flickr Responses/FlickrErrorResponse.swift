//
//  FlickrErrorResponse.swift
//  Virtual Tourist
//
//  Created by Nils Riebeling on 19.12.19.
//  Copyright © 2019 Nils Riebeling. All rights reserved.
//

import Foundation

struct FlickrErrorResponse: Codable {
    
    let status: String
    let statusCode: Int
    let statusMessage: String
    
    enum CodingKeys: String, CodingKey {
           
           case status = "stat"
           case statusCode = "code"
           case statusMessage = "message"
    
    }
    
}

//Special ErrorType
extension FlickrErrorResponse: LocalizedError {

var errorDescription: String? {
    
    return statusMessage
}

}
