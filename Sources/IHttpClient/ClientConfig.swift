//
//  ClientConfig.swift
//  IHttpClient
//
//  Created by Stepan Bezhuk on 26.04.2025.
//

import Foundation

/// Global HTTP client configuration
public struct ClientConfig {
    /// Base URL for all requests
    public let baseURL: String
    
    /// URLSession configuration (default: .default)
    public let sessionConfiguration: URLSessionConfiguration
    
    /// Cache configuration (nil disables caching)
    public let cacheConfig: CacheConfig?
    
    /// Default headers for all requests
    public let defaultHeaders: HTTPHeaders
    
    /// Default timeout interval for requests (seconds)
    public let timeoutInterval: TimeInterval
    
    /// Enables request/response logging
    public let enableLogging: Bool
    
    public init(baseURL: String, sessionConfiguration: URLSessionConfiguration = .default, cacheConfig: CacheConfig? = nil, defaultHeaders: HTTPHeaders = [:], timeoutInterval: TimeInterval = 60.0, enableLogging: Bool = false) {
        self.baseURL = baseURL
        self.sessionConfiguration = sessionConfiguration
        self.cacheConfig = cacheConfig
        self.defaultHeaders = defaultHeaders
        self.timeoutInterval = timeoutInterval
        self.enableLogging = enableLogging
    }
}
