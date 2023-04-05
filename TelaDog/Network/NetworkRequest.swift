//
//  NetworkRequest.swift
//  TelaDog
//
//  Created by Pierre BARTHELEMY on 04/04/2023.
//

import Foundation
import Combine

public class NetworkRequest<T>: NSObject where T: Codable {
    
    private var file: String = ""
    private var function: String = ""
    private var line: Int = 0
    internal var url: URL?
    internal var parameters: [String: String]?
    private var decodable: T.Type?
    internal var body: Data?
    private var encodeData: (() throws -> Data?)?
    internal var headers: [NetworkHeader] = [NetworkHeader]()
    internal var method: NetworkEnum.Method = .get
    internal var response: NetworkRequest<T>.Response?
    private var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = JSONDecoder.DateDecodingStrategy.deferredToDate
    private var retries: Int = 0
    private var shouldTrace: Bool = false
    
    public init(file: String = #fileID, function: String = #function, line: Int = #line, url: URL? = nil, parameters: [String: String]? = nil, decodable: T.Type? = nil, headers: [NetworkHeader] = [NetworkHeader](), method: NetworkEnum.Method = .get, response: NetworkRequest<T>.Response? = nil) {
        self.file = file
        self.function = function
        self.line = line
        self.url = url
        self.parameters = parameters
        self.decodable = decodable
        self.body = nil
        self.headers = headers
        self.method = method
        self.response = response
    }
    
    public func url(_ string: String) -> Self {
        guard let newUrl = URL(string: string) else {
            return self
        }
        self.url = newUrl
        return self
    }
    
    public func url(_ url: URL) -> Self {
        self.url = url
        return self
    }
    
    public func parameters(_ parameters: [String: String]) -> Self {
        self.parameters = parameters
        return self
    }
    
    public func decodable(_ decodable: T.Type) -> Self where T: Codable {
        self.decodable = decodable
        return self
    }
    
    public func encodeData(_ data: @escaping (() throws -> Data?)) -> Self {
        self.encodeData = data
        return self
    }
    
    public func body<U>(_ body: U) -> Self where U: Codable {
        let encoder = JSONEncoder()
        let iso8601Full: DateFormatter = DateFormatter()
        iso8601Full.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        encoder.dateEncodingStrategy = .formatted(iso8601Full)
        self.body = try? encoder.encode(body)
        return self
    }
    
    public func headers(headers: [NetworkHeader]) -> Self {
        for header in headers {
            if self.headers.map({ $0.name }).contains(header.name) {
                self.headers.removeAll(where: { $0.name == header.name })
            }
            self.headers.append(header)
        }
        return self
    }
    
    public func method(_ method: NetworkEnum.Method) -> Self {
        self.method = method
        return self
    }
    
    public func dateDecodingStrategy(_ strategy: JSONDecoder.DateDecodingStrategy) -> Self {
        self.dateDecodingStrategy = strategy
        return self
    }
    
    public func retries(number: Int = 0) -> Self {
        self.retries = number
        return self
    }
    
    public func trace() -> Self {
        self.shouldTrace = true
        return self
    }
    
    public func call() -> AnyPublisher<T, Error> {
        guard let urlToCall = buildUrl() else {
            return Fail(error: NetworkError(type: .malformedURL(description: "Malformed URL", recovery: nil)))
                .eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: urlToCall)
        
        urlRequest.httpMethod = method.rawValue
        
        if let bodyData = encodeData {
            let bodyData = try? bodyData()
            urlRequest.httpBody = bodyData
            body = bodyData
        }
        
        for header in headers {
            urlRequest.addValue(header.value, forHTTPHeaderField: header.name)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, response: URLResponse) in
                if let httpResponse = response as? HTTPURLResponse {
                    self.response = Response(body: data, statusCode: httpResponse.statusCode, headers: httpResponse.allHeaderFields)
                    
                    guard httpResponse.statusCode < 400 else {
                        self.traceRequest()
                        throw NetworkError(type: .unknown(description: "\(self.response?.body?.json(format: false) ?? "")", recovery: nil), httpStatus: httpResponse.status)
                    }
                    
                    if self.shouldTrace {
                        self.traceRequest()
                    }
                }
                return data
            })
            .mapError({ (error: Error) -> Error in
                error
            })
            .retry(times: 3, if: { (error: Error) in
                if let statusCode = self.response?.statusCode, statusCode >= 500 {
                    return true
                } else {
                    return false
                }
            })
            .decode(type: T.self, decoder: decoder)
            .mapError({ (error: Error) -> Error in
                error
            })
            .eraseToAnyPublisher()
    }
    
    internal func buildUrl() -> URL? {
        guard let urlToCall = url else {
            return nil
        }
        var components = URLComponents(url: urlToCall, resolvingAgainstBaseURL: false)
        
        if let queryParameters = parameters, !queryParameters.isEmpty {
            components?.queryItems = [URLQueryItem]()
            for parameter in queryParameters {
                components?.queryItems?.append(URLQueryItem(name: parameter.key, value: parameter.value))
            }
        }
        
        return components?.url
    }
}

extension NetworkRequest {
    private func traceRequest() {
        if let lUrl =  self.url?.absoluteString {
            let lRespondeCode = self.response?.statusCode ?? 580
            let lResult = lRespondeCode < 400 ? "SUCCESS" : "FAILED"
            var lRequestParameters: String = ""
            parameters?.forEach({ lRequestParameters += $0.key.indent(by: 2) + " : " + $0.value + "\n" })
            var lRequestHeaders: String = ""
            headers.forEach({ lRequestHeaders += $0.name.indent(by: 2) + " : " + $0.value + "\n" })
            var lRequestBody: String = ""
            
            if let bodyData = body {
                lRequestBody = bodyData.json(format: true, padding: "    ") ?? ""
            }
            
            var lResponseHeaders: String = ""
            response?.headers.forEach({ (key: AnyHashable, value: Any) in
                var headerName: String = "Unknown Header".indent(by: 2)
                var headerValue: String = "Unknown Value"
                if let stringKey = key as? String {
                    headerName = stringKey.indent(by: 2)
                }
                if let stringValue = value as? String {
                    headerValue = stringValue
                }
                
                lResponseHeaders += headerName + " : " + headerValue + "\n"
            })
            
            let responseBody = response?.body?.json(format: true) ?? ""
            let response = """
              \nResult: \(lResult)
              
              Parameters
              \(!lRequestParameters.isEmpty ? lRequestParameters : "NONE".indent(by: 2))
              
              Request
                Method: \(method.rawValue)
                Url   : \(lUrl)
                Header:
              \(!lRequestHeaders.isEmpty ? lRequestHeaders : "NONE".indent(by: 2))
                Body:
              \(!lRequestBody.isEmpty ? lRequestBody : "NONE".indent(by: 2))
              
              Response:
                HTTP Code: \(lRespondeCode)
                Headers:
              \(!lResponseHeaders.isEmpty ? lResponseHeaders : "NONE".indent(by: 2))
                Body:
              \(!responseBody.isEmpty ? responseBody : "NONE".indent(by: 2))
              """
            var reqHeaders: [String: String] = [String: String]()
            headers.forEach({ reqHeaders[$0.name] = $0.value })
            print(response)
        } else {
            print("No URL")
        }
    }
}

extension NetworkRequest {
    public class Response {
        public var body: Data?
        public var statusCode: Int
        public var headers: [AnyHashable: Any]
        
        internal init(body: Data? = nil, statusCode: Int, headers: [AnyHashable: Any]) {
            self.body = body
            self.statusCode = statusCode
            self.headers = headers
        }
    }
}
