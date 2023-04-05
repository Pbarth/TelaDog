//
//  NetworkHeader.swift
//  TelaDog
//
//  Created by Pierre BARTHELEMY on 04/04/2023.
//

import Foundation

public enum NetworkHeader: Equatable {
    case accept(String)
    case acceptCharset(String)
    case acceptLanguage(String)
    case acceptEncoding(String)
    case authorization(String)
    case contentType(String)
    case contentDisposition(String)
    case userAgent(String)
    case custom(String, String)
    
    var name: String {
        switch self {
        case .accept:
            return "Accept"
        case .acceptCharset:
            return "Accept-Charset"
        case .acceptLanguage:
            return "Accept-Language"
        case .acceptEncoding:
            return "Accept-Encoding"
        case .authorization:
            return "Authorization"
        case .contentType:
            return "Content-Type"
        case .contentDisposition:
            return "Content-Disposition"
        case .userAgent:
            return "User-Agent"
        case .custom(let name, _):
            return name
        }
    }
    
    var value: String {
        switch self {
        case .accept(let value),
             .acceptCharset(let value),
             .acceptLanguage(let value),
             .acceptEncoding(let value),
             .authorization(let value),
             .contentType(let value),
             .contentDisposition(let value),
             .userAgent(let value):
            return value
        case .custom(_, let value):
            return value
        }
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.value == rhs.value
    }
}
