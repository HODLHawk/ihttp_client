//
//  ClientConfig.swift
//  IHttpClient
//
//  Created by Stepan Bezhuk on 26.04.2025.
//

import Foundation

/// Global HTTP client configuration with generic error model type
public struct ClientConfig<ErrorModel: Decodable & Sendable> {
    /// Base URL for all requests
    public let baseURL: String
    
    /// Type for decoding error responses
    public let errorModelType: ErrorModel.Type
    
    /// URLSession configuration
    public let sessionConfiguration: URLSessionConfiguration
    
    /// Cache configuration
    public let cacheConfig: CacheConfig?
    
    /// Default headers for all requests
    public let defaultHeaders: HTTPHeaders
    
    /// Request timeout interval
    public let timeoutInterval: TimeInterval
    
    /// Enables request/response logging
    public let enableLogging: Bool
    
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
