//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Nils Riebeling on 19.12.19.
//  Copyright © 2019 Nils Riebeling. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class TravelLocationsMapViewController: UIViewController{
    
    //MARK: Variables
    var fetchedResultsController: NSFetchedResultsController<MapPin>!
    var dataController: NSPersistentContainer!
    
    //MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: IBActions
    @IBAction func longTapGestureAction(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .ended {
            saveLocationToPin(location: sender.location(in: mapView))
        }
        
        
    }
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setUpFetchedResultsController()
        mapView.delegate = self
        loadMapPins()
        
        
        
    }
    
    
    //MARK: Helper function
    
    func saveLocationToPin(location: CGPoint) {
        
        let tappedCoords = mapView.convert(location, toCoordinateFrom: mapView)
        let tappedPin = MapPin(context: dataController.viewContext)
        tappedPin.pinLocationLat = tappedCoords.latitude
        tappedPin.pinLocationLong = tappedCoords.longitude
        try? dataController.viewContext.save()
        mapView.addAnnotation(tappedPin)
    }
    
    func loadMapPins() {
        
        let mapPins = fetchedResultsController.fetchedObjects
        
        if let mapPins = mapPins {
            self.mapView.addAnnotations(mapPins)
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PhotoAlbumViewController {
            vc.selectedMapPin = (sender as! MapPin)
            vc.dataController = dataController
        }
    }
    

    
    

}

//MARK: Extention MKView
extension TravelLocationsMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        return nil
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let pin = view.annotation {
            performSegue(withIdentifier: "showAlbum", sender: pin)
        }
    }
    
    
    
}


//MARK: Extention FetchedResultControllerDelegate
extension TravelLocationsMapViewController:NSFetchedResultsControllerDelegate {
    
    fileprivate func setUpFetchedResultsController() {
        let fetchRequest:NSFetchRequest<MapPin> = MapPin.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "mapPins")
        
        fetchedResultsController.delegate = self
        
        do {
            
            try fetchedResultsController.performFetch()
        } catch {
            
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
}
