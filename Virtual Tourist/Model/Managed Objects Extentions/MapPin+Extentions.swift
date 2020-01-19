//
//  MapPin+Extentions.swift
//  Virtual Tourist
//
//  Created by Nils Riebeling on 20.12.19.
//  Copyright © 2019 Nils Riebeling. All rights reserved.
//

import Foundation
import CoreData
import MapKit


extension MapPin: MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.pinLocationLat, longitude: self.pinLocationLong)
    }
    
    
    public override func awakeFromFetch() {
        
        super.awakeFromFetch()
        creationDate = Date()
        
    }
    
    
    
}
