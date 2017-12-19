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
    
    let sampleParams = [
        "id":"1001",
        "name":"IOS Programming",
        "pubDate":"2016"
    ] as [String:AnyObject]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("Escape parameters: \(escapedParameters(parameters: sampleParams))")
    
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
        
        let APIBaseURL = Constants.Flickr.APIScheme + Constants.Flickr.APIHost + Constants.Flickr.APIPath
        let urlString = APIBaseURL + escapedParameters(parameters: methodParameters)
        print(urlString)
        
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // GUARD: any error?
            guard (error == nil) else {
                self.displayError("There was an error in your request: \(error?.localizedDescription ?? "")")
                return
            }
            
            // GUARD: any data returned?
            guard let data = data else {
                self.displayError("No data returned by the request!")
                return
            }
            
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                // Deserialization JSON
                // get the photos dictionary at the "photos" key
                // GUARD: "photos" & "photo" in dictionary?
                guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                    self.displayError("Cannot find key: \(Constants.FlickrResponseKeys.Photos) & key: \(Constants.FlickrResponseKeys.Photo) in \(parsedResult).")
                    return
                }
                
                // select a randrom photo
                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
                let photoDictionary = photoArray[randomPhotoIndex] as [String:AnyObject]
                
                guard let imageURLString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String, let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String else {
                    self.displayError("Cannot find key: \(Constants.FlickrResponseKeys.MediumURL) in \(photoDictionary)")
                    return
                }
                
                let imageURL = URL(string: imageURLString)
                if let imageData = try? Data(contentsOf: imageURL!) {
                    performUIUpdatesOnMain {
                        self.flickIv.image = UIImage(data: imageData)
                        self.titleLbl.text = photoTitle
                        self.setUIEnabled(true)
                    }
                }
            } catch let parseErr {
                print("Could not parse the data as json: \(parseErr.localizedDescription)")
            }
        }
        task.resume()
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

