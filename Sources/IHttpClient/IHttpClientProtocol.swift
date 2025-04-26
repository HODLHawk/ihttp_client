//
//  IHttpClientProtocol.swift
//
//  Created by Stepan Bezhuk on 24.03.2025.
//  Documentation last updated: 27.06.2025
//

import Foundation

/// Protocol defining the interface for HTTP client implementations
/// - Note: All implementations must be thread-safe (marked with `actor`)
public protocol IHttpClientProtocol: Actor {
    
    // MARK: - Request Methods
    
    /// Performs HTTP request with full interceptor support
    /// - Parameters:
    ///   - path: Endpoint path (appended to baseURL)
    ///   - method: HTTP method (GET, POST etc.)
    ///   - parameters: Request body parameters (will be JSON-encoded)
    ///   - headers: Additional HTTP headers
    ///   - errorModelType: Type for decoding error responses
    /// - Returns: Decoded response wrapped in `HTTPResponse`
    /// - Throws: `HTTPError` for failed requests
    func request<T: Decodable, E: Decodable>(_ path: String, method: OriginalRequest.HTTPMethod, parameters: HTTPParameters?, headers: HTTPHeaders?, errorModelType: E.Type) async throws -> HTTPResponse<T>
    
    /// Performs raw HTTP request bypassing interceptors
    /// - Parameters:
    ///   - path: Endpoint path
    ///   - method: HTTP method
    ///   - parameters: Request body parameters
    ///   - headers: Additional headers
    ///   - errorModelType: Type for error response decoding
    /// - Returns: Decoded response
    func performRawRequest<T: Decodable, E: Decodable>(_ path: String, method: OriginalRequest.HTTPMethod, parameters: HTTPParameters?, headers: HTTPHeaders?, errorModelType: E.Type) async throws -> HTTPResponse<T>
    
    // MARK: - Interceptors
    
    /// Registers new request/response interceptor
    /// - Parameter interceptor: Interceptor implementation
    func addInterceptor(_ interceptor: Interceptor)
    
    // MARK: - Cache Management
    
    /// Clears all cached responses (both memory and disk)
    func clearCache()
    
    /// Gets current cache size in bytes
    /// - Returns: Total size of cached data
    func getCacheSize() -> Int
    
    /// Removes cached response for specific URL
    /// - Parameter url: URL to remove cached response for
    func removeCachedResponse(for url: URL)
    
    /// Retrieves cached response for request
    /// - Parameter request: Original URLRequest
    /// - Returns: Cached response if exists
    func getCachedResponse(for request: URLRequest) -> CachedURLResponse?
    
    // MARK: - Configuration
    
    /// Updates client configuration
    /// - Parameter config: New configuration
    /// - Note: May recreate underlying URLSession if configuration changed significantly
    func updateConfig(_ config: ClientConfig)
    
    /// Returns current client configuration
    /// - Returns: Active configuration
    func getConfig() -> ClientConfig
    
    // MARK: - Initialization
    
    /// Creates client with full configuration
    /// - Parameter config: Complete client settings
    init(config: ClientConfig)
}

// MARK: - Default Implementations

public extension IHttpClientProtocol {
    /// Convenience initializer for backward compatibility
    /// - Parameters:
    ///   - baseURL: Base API URL string
    ///   - session: URLSession to use (default: .shared)
    ///   - cacheConfig: Optional cache configuration
    init(baseURL: String, session: URLSession = .shared,cacheConfig: CacheConfig? = nil) {
        self.init(config: ClientConfig(
            baseURL: baseURL,
            sessionConfiguration: session.configuration,
            cacheConfig: cacheConfig
        ))
    }
}
