//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Nils Riebeling on 19.12.19.
//  Copyright © 2019 Nils Riebeling. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController{
    
    //MARK: Variables
    var dataController: NSPersistentContainer!
    var selectedMapPin: MapPin!
    
    //Initiate fetchResultsController to get notifications, when the photos will be changed.
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    //MARK: IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    //MARK: IBActions
    @IBAction func pushNewCollectionButton(_ sender: UIButton) {
        
        handleDeleteAllPhotos()
        handleSearchPhotoLocation(mapPin: selectedMapPin)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        mapView.addAnnotation(selectedMapPin)
        mapView.setCenter(selectedMapPin.coordinate, animated: true)
        photoCollectionView.allowsSelection = true
        setupFetchedResultController()
        
        
        //Load new pictures from flickr id if no results within db
        if fetchedResultsController.fetchedObjects?.isEmpty ?? true {
            
            self.handleSearchPhotoLocation(mapPin: selectedMapPin)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    
    func handleSearchPhotoLocation(mapPin: MapPin){
        self.isLoading(loading: true)
        let page = Int.random(in: 0 ..< 100)
        
        FlickrClient.searchPhotosAtLocation(lat: mapPin.pinLocationLat, lon: mapPin.pinLocationLong, page: page) { (flickrPhotos, error) in
            
            if !flickrPhotos.isEmpty && error == nil{
                for flickrPhoto in flickrPhotos {
                    let photo = Photo(entity: Photo.entity(), insertInto: self.dataController.viewContext)
                    photo.flickr_Id = flickrPhoto.id
                    photo.flickr_image = #imageLiteral(resourceName: "placeholder_image").jpegData(compressionQuality: 1.0)
                    photo.mapPin = self.selectedMapPin
                    try? self.dataController.viewContext.save()
                    self.handleGetPhotoSizesAndUrls(photo: photo) { (success) in
                        self.isLoading(loading: false)
                        try? self.dataController.viewContext.save()
                    }
                }
            } else {
                
                if case is VTError = error{
                    
                    
                    self.isLoading(loading: false)
                    self.showLoginFailure(message: error!.localizedDescription)
                    
                } else {
                    self.isLoading(loading: false)
                    self.showLoginFailure(message: "Can not load pictures. Please try again later.")
                    
                    
                }
                
            }
            
        }
    }
    
    func handleGetPhotoSizesAndUrls(photo: Photo, completion: @escaping (_ success: Bool)-> Void){
        
        FlickrClient.getPhotoSizesAndUrls(photoID: photo.flickr_Id!) { (sizes, error) in
            
            if !sizes.isEmpty{
                self.handleGetImageData(photoUrl: URL(string: sizes.first!.source)!, photo: photo) { (success) in
                    if success {
                        completion(true)
                    }
                }
            }
            
        }
        
    }
    
    func handleGetImageData(photoUrl: URL, photo: Photo, completion: @escaping (_ success: Bool)-> Void){
        FlickrClient.getImageData(imageUrl: photoUrl){ (image, error) in
            
            if let image = image {
                
                photo.flickr_image = image.jpegData(compressionQuality: 1.0)
                completion(true)
                
            }else{
                self.showLoginFailure(message: "Can not load pictures. Please try again later.")
                completion(false)
                
            }
            
        }
        
    }
    
    func handleDeleteAllPhotos(){
        
        if let objectsToDelete = fetchedResultsController.fetchedObjects {
            
            for object in objectsToDelete {
                handleDeletePhoto(photo: object)
                
            }
        }
        
    }
    
    func handleDeletePhoto(photo: Photo) {
        self.dataController.viewContext.delete(photo)
        self.photoCollectionView.reloadData()
    }
    
    //MARK: Helper functions
    
    func isLoading(loading: Bool) {
        
        if loading {
            
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
                self.newCollectionButton.isEnabled = !loading
                
            }
            
        }else{
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.newCollectionButton.isEnabled = !loading
            }
            
        }
        
    }
    
    
    func showLoginFailure(message: String) {
        
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: "Problem by downloading the pictures", message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }
        
    }
    
}

//MARK:Extention UICollectionView

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        
        // If no image available, show placeholder
        if let photo = fetchedResultsController.object(at: indexPath).flickr_image {
            cell.photo.image = UIImage(data: photo)
        } else {
            cell.photo.image = #imageLiteral(resourceName: "placeholder_image")
            
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dataController.viewContext.delete(self.fetchedResultsController.object(at: indexPath))
        self.photoCollectionView.deleteItems(at: [indexPath])
    }
    
}

//MARK:Extention FetchedResultControllerDelegate

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate{
    
    func setupFetchedResultController(){
        
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "mapPin == %@", selectedMapPin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "flickr_Id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
        }catch {
            
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
            
        }
        photoCollectionView.reloadData()
        
    }
    
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            
            photoCollectionView.insertSections(indexSet)
            
        case .update:
            
            photoCollectionView.reloadSections(indexSet)
            
        case .delete:
            photoCollectionView.deleteSections(indexSet)
            
            
        case .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert, update or .delete should be possible.")
            
        @unknown default:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert, update or .delete should be possible.")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        
        switch type {
        case .insert:
            photoCollectionView.reloadData()
        case .move:
            photoCollectionView.reloadData()
        case .update:
            photoCollectionView.reloadData()
        case .delete:
            photoCollectionView.reloadData()
            
        @unknown default:
            fatalError("Invalid change type in controller(_:didChangeatIndexPath:for:). Only .insert, update or .delete should be possible.")
        }
    }
    
    // MARK: Utility methods
    
    func numberOfSecions() -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func numberOfRowsIn(section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        
    }

}





