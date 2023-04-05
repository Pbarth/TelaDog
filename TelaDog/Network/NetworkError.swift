//
//  NetworkError.swift
//  TelaDog
//
//  Created by Pierre BARTHELEMY on 04/04/2023.
//

import Foundation

public class NetworkError: Error {
    public var underlyingError: Error?
    public var type: NetworkError.NetworkErrorType = .unknown(description: nil, recovery: nil)
    public var httpStatus: HTTPStatusCode?
    public var errorDescription: String? {
        switch type {
        case .malformedURL(let errorDescription, _),
                .noUser(let errorDescription, _),
                .custom(let errorDescription, _),
                .socketTimeout(let errorDescription, _),
                .pingTimeout(let errorDescription, _),
                .unknown(let errorDescription, _):
            return errorDescription
        }
    }
    
    public var recoverySuggestion: String? {
        switch type {
        case .malformedURL(_, let recoverySuggestion),
                .noUser(_, let recoverySuggestion),
                .custom(_, let recoverySuggestion),
                .unknown(_, let recoverySuggestion):
            return recoverySuggestion
            
        default:
            return "No recovery suggestion"
        }
    }
    
    public init(type: NetworkErrorType, httpStatus: HTTPStatusCode? = nil, underlyingError: Error? = nil) {
        self.type = type
        self.underlyingError = underlyingError
        self.httpStatus = httpStatus
    }
    
    public enum NetworkErrorType: Error {
        case custom(description: String?, recovery: String?)
        case malformedURL(description: String?, recovery: String?)
        case noUser(description: String?, recovery: String?)
        case socketTimeout(description: String?, recovery: String?)
        case pingTimeout(description: String?, recovery: String?)
        case unknown(description: String?, recovery: String?)
        
        public enum Response {
            case badRequest
        }
    }
}
