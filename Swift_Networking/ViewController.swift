//
//  ViewController.swift
//  Swift_Networking
//
//  Created by Thanh Minh on 12/19/17.
//  Copyright © 2017 IMT Solutions. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var flickIv: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var grabImageBt: UIButton!
    
    @IBOutlet weak var searchTf: UITextField!
    
    @IBOutlet weak var latTf: UITextField!
    @IBOutlet weak var lngTf: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
    }

    // Prepare parameters
    private func escapedParameters(parameters: [String:AnyObject]) -> String {
        if(parameters.isEmpty){
            return ""
        } else {
            var keyValuePairs = [String]()
            for(key, value) in parameters {
                // make sure that it is a string value
                let stringValue = "\(value)"
                
                // escape string
                let escapeString = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                // append string
                keyValuePairs.append(key + "=" + "\(escapeString ?? "")")
            }
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
    
    @IBAction func getFlickImage(_ sender: Any) {
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.GalleryPhotosMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.GalleryID: Constants.FlickrParameterValues.GalleryID,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
            ] as [String:AnyObject]
        
        // create url and request
        let urlString = Constants.Flickr.APIBaseURL + escapedParameters(parameters: methodParameters)
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                self.displayError("There was an error with your request: \(error?.localizedDescription ?? "")")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                self.displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                self.displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                self.displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                self.displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                self.displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in \(parsedResult)")
                return
            }
        
            // select a random photo
            let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
            let photoDictionary = photoArray[randomPhotoIndex] as [String:AnyObject]
            let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
            
            /* GUARD: Does our photo have a key for 'url_m'? */
            guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                self.displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                return
            }
            
            // if an image exists at the url, set the image and title
            let imageURL = URL(string: imageUrlString)
            if let imageData = try? Data(contentsOf: imageURL!) {
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.flickIv.image = UIImage(data: imageData)
                    self.titleLbl.text = photoTitle ?? "(Untitled)"
                }
            } else {
                self.displayError("Image does not exist at \(imageURL)")
            }
        }
        
        // start the task!
        task.resume()
    }
    
    @IBAction func searchByText(_ sender: Any) {
//        var components = URLComponents()
//        components.scheme = Constants.Flickr.APIScheme
//        components.host = Constants.Flickr.APIHost
//        components.path = Constants.Flickr.APIPath
//
//        // Initialize queryItems
//        components.queryItems = [URLQueryItem]()
//
//        let queryItem1 = URLQueryItem(name: Constants.FlickrParameterKeys.Method, value: Constants.FlickrParameterValues.SearchMethod)
//        let queryItem2 = URLQueryItem(name: Constants.FlickrParameterKeys.APIKey, value: Constants.FlickrParameterValues.APIKey)
//        let queryItem3 = URLQueryItem(name: Constants.FlickrParameterKeys.Text, value: searchTf.text)
//        let queryItem4 = URLQueryItem(name: Constants.FlickrParameterKeys.Format, value: Constants.FlickrParameterValues.ResponseFormat)
//        let queryItem5 = URLQueryItem(name: Constants.FlickrParameterKeys.Extras, value: Constants.FlickrParameterValues.MediumURL)
//
//        components.queryItems?.append(queryItem1)
//        components.queryItems?.append(queryItem2)
//        components.queryItems?.append(queryItem3)
//        components.queryItems?.append(queryItem4)
//        components.queryItems?.append(queryItem5)
//
//        print("By URLComponents: ", components.url!)
        let searchParams = [
            Constants.FlickrParameterKeys.SafeSearch:Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Text:searchTf.text ?? "",
            Constants.FlickrParameterKeys.Extras:Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.APIKey:Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.Method:Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.Format:Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback:Constants.FlickrParameterValues.DisableJSONCallback
            ] as [String : AnyObject]
        
        let url = flickrURLFromParameters(searchParams)
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                self.displayError("There was an error with your request: \(error?.localizedDescription ?? "")")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                self.displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                self.displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                self.displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                self.displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                self.displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in \(parsedResult)")
                return
            }
            
            // select a random photo
            let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
            let photoDictionary = photoArray[randomPhotoIndex] as [String:AnyObject]
            let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
            
            /* GUARD: Does our photo have a key for 'url_m'? */
            guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                self.displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                return
            }
            
            // if an image exists at the url, set the image and title
            let imageURL = URL(string: imageUrlString)
            if let imageData = try? Data(contentsOf: imageURL!) {
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.flickIv.image = UIImage(data: imageData)
                    self.titleLbl.text = photoTitle ?? "(Untitled)"
                }
            } else {
                self.displayError("Image does not exist at \(imageURL)")
            }
        }
        
        // start the task!
        task.resume()
    }
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }

    @IBAction func searchByLatLng(_ sender: Any) {
        let latLonTuples = getLatLon()
        
        let searchParams = [
            Constants.FlickrParameterKeys.SafeSearch:1,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL + ", " + Constants.FlickrParameterValues.HighURL,
//            Constants.FlickrParameterKeys.BoundingBox:getBbox(),
            Constants.FlickrParameterKeys.Lat: latLonTuples.0,
            Constants.FlickrParameterKeys.Lon: latLonTuples.1,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.PhotosRecentSearchMethod,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
            ] as [String : AnyObject]
        
        let searchURL = Constants.Flickr.APIBaseURL + escapedParameters(parameters: searchParams)
        print(searchURL)
        
        guard let url = URL(string: searchURL) else { return }
        let request = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard (error == nil) else {
                self.displayError("\(error?.localizedDescription ?? "")")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
//                print(jsonData)
                guard let photosDictionary = jsonData["photos"] as? [String:AnyObject], let photoDictionaries = photosDictionary["photo"] as? [[String:AnyObject]] else { return }
//                print(photoDictionaries)

                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoDictionaries.count)))
                let photoDictionary = photoDictionaries[randomPhotoIndex]
                if let imageURLString = photoDictionary["url_m"] as? String, let photoTitle = photoDictionary["title"] as? String {
                    print(imageURLString)
                    print(photoTitle)
                    let imageURL = URL(string: imageURLString)
                    let imageData = try Data(contentsOf: imageURL!)
                    
                    performUIUpdatesOnMain {
                        self.setUIEnabled(true)
                        self.flickIv.image = UIImage(data: imageData)
                        self.titleLbl.text = photoTitle
                    }
                }
            } catch let err {
                self.displayError(err.localizedDescription)
            }
        }
        task.resume()
    }
    
    // get lat/lng
    func getLatLon() -> (Double, Double) {
        if let lat = Double(latTf.text!), let lon = Double(lngTf.text!) {
            return (lat, lon)
        } else {
            return (Constants.FlickrParameterValues.Lat, Constants.FlickrParameterValues.Lon)
        }
    }
    
    // get bbox string
    func getBbox() -> String {
        if let lat = Double(latTf.text!), let lng = Double(lngTf.text!) {
            let minLng = min(lng - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
            let minLat = max(lat - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
            
            let maxLng = min(lng + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
            let maxLat = min(lat + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
            
            return "\(minLng),\(minLat),\(maxLng),\(maxLat)"
        } else {
            return "0, 0, 0, 0"
        }
    }
    
    // Configure UI
    func setUIEnabled(_ enabled: Bool){
        grabImageBt.isEnabled = enabled
        if enabled {
            grabImageBt.alpha = 1.0
        } else {
            grabImageBt.alpha = 0.5
        }
    }

    // Display error
    func displayError(_ error: String){
        print("Error: \(error)")
        performUIUpdatesOnMain {
            self.setUIEnabled(true)
        }
    }
}

