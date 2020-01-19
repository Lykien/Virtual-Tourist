//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Nils Riebeling on 19.12.19.
//  Copyright © 2019 Nils Riebeling. All rights reserved.
//

import Foundation
import UIKit

class FlickrClient {
    
    private static let apiKey = "xxxxxx"
    
    
    enum Endpoints {
        
        private static let baseURL = "https://www.flickr.com/services/rest/?method=flickr.photos."
        private static let jsonConfig = "&format=json&nojsoncallback=1"
        private static let apiKey = "&api_key=\(FlickrClient.apiKey)"
        
        case searchPhotosAtLocation(String, String, String)
        case getPhotoSizes(String)
        
        var stringValue: String {
            switch self {
                
            case .searchPhotosAtLocation(let lat, let lon, let page): return Endpoints.baseURL + "search" + Endpoints.apiKey + "&per_page=10" + "&lat=\(lat)&lon=\(lon)&page=\(page)" + Endpoints.jsonConfig
            case .getPhotoSizes(let flickrID): return Endpoints.baseURL + "getSizes" + Endpoints.apiKey +  "&photo_id=\(flickrID)" + Endpoints.jsonConfig
                
            }
            
        }
        
        var url: URL {
            
            return URL(string: stringValue)!
        }
        
    }
    
    class func searchPhotosAtLocation(lat: Double, lon: Double, page: Int, completion : @escaping ([PhotoRequest], Error?) -> Void){
        
        self.taskForGETRequest(url: Endpoints.searchPhotosAtLocation(String(lat), String(lon), String(page)).url, responseType: FlickrPhotosSearchResponse.self) { (response, error) in
            
            if let response = response {
                
                if response.photos.total == "0" {
                    
                    completion([], VTError.noPicturesFound)
                    
                }else {
                    
                    completion(response.photos.photo, nil)
                    
                }
                
                
                
                
                
                
                
            } else {
                
                completion([], error)
            }
        }
        
        
    }
    
    class func getPhotoSizesAndUrls(photoID: String, completion : @escaping ([Size], Error?) -> Void){
        
        self.taskForGETRequest(url: Endpoints.getPhotoSizes(photoID).url, responseType: FlickrPhotoSizesAndUrlResponse.self) { (response, error) in
            
            if let response = response {
                completion(response.sizes.pictureSizes, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    class func getImageData(imageUrl: URL, completion : @escaping(UIImage?, Error?)->Void){
        
        let task = URLSession.shared.dataTask(with: imageUrl, completionHandler: { (data, response, error) in
            if let data = data {
                let downloadedImage = UIImage(data: data)
                completion(downloadedImage, nil)
                
            }else {
                completion(nil, error)
                return
            }
        })
        task.resume()
        
        
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void)  -> URLSessionTask{
        
        let task = URLSession.shared.dataTask(with: url) {
            data, reponse, error in
            
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            let decoder = JSONDecoder()
            
            do{
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                
                DispatchQueue.main.async {
                    
                    completion(responseObject, nil)
                }
                
            }catch {
                
                do {
                    
                    let errorResponse = try decoder.decode(FlickrErrorResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                    
                }catch {
                    
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    
                }
                
                
            }
            
        }
        
        
        task.resume()
        
        return task
        
    }
    
}
