//
//  ClientConfig.swift
//  IHttpClient
//
//  Created by Stepan Bezhuk on 26.04.2025.
//

import Foundation

/// Global configuration for HTTP client
public struct ClientConfig<ErrorModel: Decodable & Sendable> {
    /// Base URL for all requests
    public let baseURL: String
    
    /// Type used for decoding error responses
    public let errorModelType: ErrorModel.Type
    
    /// Configuration for underlying URLSession
    public let sessionConfiguration: URLSessionConfiguration
    
    /// Cache configuration settings
    public let cacheConfig: CacheConfig?
    
    /// Default headers applied to all requests
    public let defaultHeaders: HTTPHeaders
    
    /// Request timeout interval in seconds
    public let timeoutInterval: TimeInterval
    
    /// Enables debug logging for requests/responses
    public let enableLogging: Bool
    
    /// Initializes a new client configuration
    /// - Parameters:
    ///   - baseURL: Base URL for all requests
    ///   - errorModelType: Type for decoding error responses
    ///   - sessionConfiguration: URLSession configuration (default: .default)
    ///   - cacheConfig: Cache configuration (default: nil)
    ///   - defaultHeaders: Default headers (default: empty)
    ///   - timeoutInterval: Request timeout in seconds (default: 60)
    ///   - enableLogging: Enables debug logging (default: false)
    public init(
        baseURL: String,
        errorModelType: ErrorModel.Type,
        sessionConfiguration: URLSessionConfiguration = .default,
        cacheConfig: CacheConfig? = nil,
        defaultHeaders: HTTPHeaders = [:],
        timeoutInterval: TimeInterval = 60.0,
        enableLogging: Bool = false
    ) {
        self.baseURL = baseURL
        self.errorModelType = errorModelType
        self.sessionConfiguration = sessionConfiguration
        self.cacheConfig = cacheConfig
        self.defaultHeaders = defaultHeaders
        self.timeoutInterval = timeoutInterval
        self.enableLogging = enableLogging
    }
}
