//
//  URLFactory.swift
//  TelaDog
//
//  Created by Pierre BARTHELEMY on 04/04/2023.
//

import Foundation

public class URLFactory {
    internal static var baseComponents: URLComponents {
        var urlComponents = URLComponents()
        
        urlComponents.scheme = "https"
        urlComponents.host = "dog.ceo"
        
        return urlComponents
    }
    
    public static func breeds() -> URL? {
        var urlComponents = URLFactory.baseComponents
        urlComponents.path.append("/api/breeds/list/all")
        return urlComponents.url
    }
    
    public static func image(breed: String, subBreed: String) -> URL? {
        var urlComponents = URLFactory.baseComponents
        if subBreed.isEmpty {
            urlComponents.path.append("/api/breed/\(breed)/images/random")
        } else {
            urlComponents.path.append("/api/breed/\(breed)/\(subBreed)/images/random")
        }
        
        return urlComponents.url
    }
}
