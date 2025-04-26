//
//  IHttpClientProtocol.swift
//
//  Created by Stepan Bezhuk on 24.03.2025.
//

import Foundation

/// Protocol defining the interface for HTTP client implementations
public protocol IHttpClientProtocol: Actor {
    associatedtype ErrorModel: Decodable & Sendable
    
    // MARK: - Request Methods
    
    /// Makes an HTTP request with full interceptor support
    func request<T: Decodable>(
        _ path: String,
        method: OriginalRequest.HTTPMethod,
        parameters: HTTPParameters?,
        headers: HTTPHeaders?
    ) async throws -> HTTPResponse<T>
    
    /// Makes a raw HTTP request bypassing interceptors
    func performRawRequest<T: Decodable>(
        _ path: String,
        method: OriginalRequest.HTTPMethod,
        parameters: HTTPParameters?,
        headers: HTTPHeaders?
    ) async throws -> HTTPResponse<T>
    
    // MARK: - Interceptors
    
    /// Adds new request interceptor
    func addInterceptor(_ interceptor: Interceptor)
    
    // MARK: - Cache Management
    
    /// Clears all cached responses
    func clearCache()
    
    /// Gets current cache size
    func getCacheSize() -> Int
    
    /// Removes cached response for URL
    func removeCachedResponse(for url: URL)
    
    /// Gets cached response for request
    func getCachedResponse(for request: URLRequest) -> CachedURLResponse?
    
    // MARK: - Configuration
    
    /// Updates client configuration
    func updateConfig<NewErrorModel: Decodable & Sendable>(_ config: ClientConfig<NewErrorModel>)
    
    /// Returns current configuration
    func getConfig() -> ClientConfig<ErrorModel>
    
    // MARK: - Initialization
    
    /// Creates client with configuration
    init<Model: Decodable & Sendable>(config: ClientConfig<Model>)
}

public extension IHttpClientProtocol {
    /// Convenience initializer
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
