//
//  IHttpClientProtocol.swift
//
//  Created by Stepan Bezhuk on 24.03.2025.
//

import Foundation

/// Protocol defining HTTP client interface
public protocol IHttpClientProtocol: Actor {
    /// Type for decoding error responses
    associatedtype ErrorModel: Decodable & Sendable
    
    /// Makes an HTTP request with interceptors
    /// - Parameters:
    ///   - path: Endpoint path
    ///   - method: HTTP method
    ///   - parameters: Request parameters
    ///   - headers: Additional headers
    /// - Returns: Decoded HTTP response
    func request<T: Decodable>(
        _ path: String,
        method: OriginalRequest.HTTPMethod,
        parameters: HTTPParameters?,
        headers: HTTPHeaders?
    ) async throws -> HTTPResponse<T>
    
    /// Makes a raw HTTP request bypassing interceptors
    /// - Parameters:
    ///   - path: Endpoint path
    ///   - method: HTTP method
    ///   - parameters: Request parameters
    ///   - headers: Additional headers
    /// - Returns: Decoded HTTP response
    func performRawRequest<T: Decodable>(
        _ path: String,
        method: OriginalRequest.HTTPMethod,
        parameters: HTTPParameters?,
        headers: HTTPHeaders?
    ) async throws -> HTTPResponse<T>
    
    /// Adds a new request/response interceptor
    /// - Parameter interceptor: Interceptor to add
    func addInterceptor(_ interceptor: Interceptor)
    
    /// Clears all cached responses
    func clearCache()
    
    /// Gets current cache size in bytes
    /// - Returns: Total cache size (memory + disk)
    func getCacheSize() -> Int
    
    /// Removes cached response for specific URL
    /// - Parameter url: URL to remove cache for
    func removeCachedResponse(for url: URL)
    
    /// Gets cached response for specific request
    /// - Parameter request: Original URLRequest
    /// - Returns: Cached response if available
    func getCachedResponse(for request: URLRequest) -> CachedURLResponse?
    
    /// Updates client configuration
    /// - Parameter config: New configuration
    func updateConfig<NewErrorModel: Decodable & Sendable>(_ config: ClientConfig<NewErrorModel>)
    
    /// Returns current configuration
    /// - Returns: Active configuration
    func getConfig() -> ClientConfig<ErrorModel>
    
    /// Creates client with configuration
    /// - Parameter config: Complete client configuration
    init<Model: Decodable & Sendable>(config: ClientConfig<Model>)
}

public extension IHttpClientProtocol {
    /// Convenience initializer
    /// - Parameters:
    ///   - baseURL: Base URL for requests
    ///   - errorModelType: Type for decoding error responses
    ///   - session: URLSession to use (default: .shared)
    ///   - cacheConfig: Cache configuration (default: nil)
    init(
        baseURL: String,
        errorModelType: ErrorModel.Type,
        session: URLSession = .shared,
        cacheConfig: CacheConfig? = nil
    ) {
        self.init(config: ClientConfig(
            baseURL: baseURL,
            errorModelType: errorModelType,
            sessionConfiguration: session.configuration,
            cacheConfig: cacheConfig
        ))
    }
}
