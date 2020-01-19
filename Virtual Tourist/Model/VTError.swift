//
//  VTError.swift
//  Virtual Tourist
//
//  Created by Nils Riebeling on 19.01.20.
//  Copyright © 2020 Nils Riebeling. All rights reserved.
//

import Foundation

    
    enum VTError: Error {
        case noPicturesFound
        
    }


extension VTError: LocalizedError {
    
    var errorDescription: String? {
        
        switch self {
        case .noPicturesFound: return NSLocalizedString("No pictures found, please try another location.", comment: "")

      
        }
        
    }
}

