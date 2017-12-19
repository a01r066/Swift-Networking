//
//  Constants.swift
//  Swift_Networking
//
//  Created by Thanh Minh on 12/19/17.
//  Copyright © 2017 IMT Solutions. All rights reserved.
//

import UIKit

// MARK: - Constants
struct Constants {
    // MARK: Flickr
    struct Flickr {
        static let APIBaseURL = "https://api.flickr.com/services/rest/"
        
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
//        static let SearchLatRange = (-90.0, 90.0)
//        static let SearchLonRange = (-180.0, 180.0)
        static let SearchLatRange = (-10.0, 10.0)
        static let SearchLonRange = (-20.0, 20.0)
    }
    
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
        
        // lat & Lng
        static let Lat = "lat"
        static let Lon = "lon"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let PhotosRecentSearchMethod = "flickr.photos.getRecent"
        
        static let APIKey = "e083f3c57706fd8dc38076ab45804d8d"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let GalleryID = "5704-72157622566655097"
        static let MediumURL = "url_m"
        static let HighURL = "url_h"
        static let UseSafeSearch = "1"
        
        // lat & lng
        static let Lat = 10.0
        static let Lon = 106.0
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let HighURL = "url_h"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
}
