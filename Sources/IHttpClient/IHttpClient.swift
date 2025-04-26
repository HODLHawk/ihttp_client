//
//  IHttpClient.swift
//
//  Created by Stepan Bezhuk on 14.03.2025.
//  Documentation last updated: 27.06.2025
//

import Foundation

/// A modern, thread-safe HTTP client with interceptors, caching and configuration support.
///
/// ## Features
/// - Async/await native interface
/// - Request/response interception
/// - Configurable caching (memory/disk)
/// - Centralized configuration
/// - Comprehensive error handling
///
/// ## Usage
/// ```swift
/// let config = ClientConfig(
///     baseURL: "https://api.example.com",
///     cacheConfig: CacheConfig(memoryCapacity: 20_000_000)
/// )
/// let client = IHttpClient(config: config)
///
/// let response = try await client.request(
///     "/users",
///     method: .get,
///     errorModelType: APIError.self
/// )
/// ```
public final actor IHttpClient: IHttpClientProtocol {
    // MARK: - Properties
    
    /// Current client configuration
    private var config: ClientConfig
    
    /// Underlying URLSession instance
    private var session: URLSession
    
    /// Registered request/response interceptors
    private var interceptors: [Interceptor] = []
    
    /// Computed base URL from configuration
    private var baseURL: URL {
        guard let url = URL(string: config.baseURL) else {
            fatalError("Invalid baseURL in config: \(config.baseURL)")
        }
        return url
    }
    
    // MARK: - Initialization
    
    /// Initializes a new HTTP client with full configuration
    /// - Parameter config: Complete client configuration
    public init(config: ClientConfig) {
        self.config = config
        self.session = Self.configureSession(config: config)
    }
    
    /// Convenience initializer for backward compatibility
    /// - Parameters:
    ///   - baseURL: Base API URL string
    ///   - session: URLSession to use (default: .shared)
    ///   - cacheConfig: Optional cache configuration
    public init(
        baseURL: String,
        session: URLSession = .shared,
        cacheConfig: CacheConfig? = nil
    ) {
        self.init(config: ClientConfig(
            baseURL: baseURL,
            sessionConfiguration: session.configuration,
            cacheConfig: cacheConfig
        ))
    }
    
    // MARK: - Configuration Management
    
    /// Updates client configuration
    /// - Parameter config: New configuration settings
    ///
    /// ## Note
    /// Recreates URLSession if session configuration changed
    public func updateConfig(_ config: ClientConfig) {
        self.config = config
        if session.configuration != config.sessionConfiguration {
            self.session = Self.configureSession(config: config)
        }
    }
    
    /// Returns current client configuration
    /// - Returns: Active configuration object
    public func getConfig() -> ClientConfig {
        return config
    }
    
    // MARK: - Cache Management
    
    /// Clears all cached responses (both memory and disk)
    public func clearCache() {
        session.configuration.urlCache?.removeAllCachedResponses()
    }
    
    /// Gets current cache size in bytes
    /// - Returns: Total size of cached data (memory + disk)
    public func getCacheSize() -> Int {
        guard let cache = session.configuration.urlCache else { return 0 }
        return cache.currentMemoryUsage + cache.currentDiskUsage
    }
    
    /// Removes cached response for specific URL
    /// - Parameter url: URL to remove cache for
    public func removeCachedResponse(for url: URL) {
        let request = URLRequest(url: url)
        session.configuration.urlCache?.removeCachedResponse(for: request)
    }
    
    /// Retrieves cached response for request
    /// - Parameter request: Original URLRequest
    /// - Returns: Cached response if available
    public func getCachedResponse(for request: URLRequest) -> CachedURLResponse? {
        return session.configuration.urlCache?.cachedResponse(for: request)
    }
    
    // MARK: - Request Methods
    
    /// Makes an HTTP request with full interceptor support
    /// - Parameters:
    ///   - path: Endpoint path
    ///   - method: HTTP method
    ///   - parameters: Request body parameters
    ///   - headers: Additional headers
    ///   - errorModelType: Type for decoding error responses
    /// - Returns: Decoded response
    public func request<T: Decodable & Sendable, E: Decodable & Sendable>(
        _ path: String,
        method: OriginalRequest.HTTPMethod = .get,
        parameters: HTTPParameters? = nil,
        headers: HTTPHeaders? = nil,
        errorModelType: E.Type
    ) async throws -> HTTPResponse<T> {
        try await _request(
            path: path,
            method: method,
            parameters: parameters,
            headers: headers,
            errorModelType: errorModelType
        )
    }
    
    /// Makes a raw HTTP request bypassing interceptors
    /// - Parameters:
    ///   - path: Endpoint path
    ///   - method: HTTP method
    ///   - parameters: Request body parameters
    ///   - headers: Additional headers
    ///   - errorModelType: Type for decoding error responses
    /// - Returns: Decoded response
    public func performRawRequest<T: Decodable & Sendable, E: Decodable & Sendable>(
        _ path: String,
        method: OriginalRequest.HTTPMethod = .get,
        parameters: HTTPParameters? = nil,
        headers: HTTPHeaders? = nil,
        errorModelType: E.Type
    ) async throws -> HTTPResponse<T> {
        try await _performRawRequest(
            path: path,
            method: method,
            parameters: parameters,
            headers: headers,
            errorModelType: errorModelType
        )
    }
    
    /// Adds new request interceptor
    /// - Parameter interceptor: Interceptor implementation
    public func addInterceptor(_ interceptor: Interceptor) {
        interceptors.append(interceptor)
    }
    
    // MARK: - Private Implementation
    
    /// Internal request implementation with interceptors
    private func _request<T: Decodable & Sendable, E: Decodable & Sendable>(
        path: String,
        method: OriginalRequest.HTTPMethod,
        parameters: HTTPParameters?,
        headers: HTTPHeaders?,
        errorModelType: E.Type
    ) async throws -> HTTPResponse<T> {
        var urlRequest = try createURLRequest(
            path: path,
            method: method,
            parameters: parameters,
            headers: headers
        )
        
        // Apply request interceptors
        applyInterceptors(for: &urlRequest)
        
        // Execute request
        let (data, response) = try await session.data(for: urlRequest)
        
        // Apply response interceptors
        applyInterceptors(for: response, data: data)
        
        // Handle empty responses
        guard let httpResponse = response as? HTTPURLResponse else {
            if response.expectedContentLength == 0,
               let emptyValue = EmptyDecodableFactory.makeEmptyValue(for: T.self) {
                return HTTPResponse(data: emptyValue, response: response)
            }
            throw HTTPError<E>.unknown
        }
        
        // Handle retry logic
        let originalRequest = OriginalRequest(
            path: path,
            method: method,
            parameters: parameters,
            headers: headers
        )
        
        if let retriedResponse = try await handleRetry(
            httpResponse: httpResponse,
            data: data,
            originalRequest: originalRequest
        ) as HTTPResponse<T>? {
            return retriedResponse
        }
        
        // Validate response status
        try validateResponse(httpResponse, data: data, errorModelType: errorModelType)
        
        // Handle no-content responses
        if httpResponse.statusCode == 204 || data.isEmpty {
            guard let emptyValue = EmptyDecodableFactory.makeEmptyValue(for: T.self) else {
                throw HTTPError<E>.emptyResponse
            }
            return HTTPResponse(data: emptyValue, response: response)
        }
        
        // Decode successful response
        let decodedData = try JSONDecoder().decode(T.self, from: data)
        return HTTPResponse(data: decodedData, response: response)
    }
    
    /// Internal raw request implementation
    private func _performRawRequest<T: Decodable & Sendable, E: Decodable & Sendable>(
        path: String,
        method: OriginalRequest.HTTPMethod,
        parameters: HTTPParameters?,
        headers: HTTPHeaders?,
        errorModelType: E.Type
    ) async throws -> HTTPResponse<T> {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = config.timeoutInterval
        
        // Merge default and request-specific headers
        let allHeaders = config.defaultHeaders.merging(headers ?? [:]) { $1 }
        allHeaders.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
        if let parameters = parameters {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError<E>.unknown
        }
        
        try validateResponse(httpResponse, data: data, errorModelType: errorModelType)
        
        if httpResponse.statusCode == 204 || data.isEmpty {
            guard let emptyValue = EmptyDecodableFactory.makeEmptyValue(for: T.self) else {
                throw HTTPError<E>.emptyResponse
            }
            return HTTPResponse(data: emptyValue, response: response)
        }
        
        let decodedData = try JSONDecoder().decode(T.self, from: data)
        return HTTPResponse(data: decodedData, response: response)
    }
    
    // MARK: - Private Helpers
    
    /// Configures URLSession based on configuration
    private static func configureSession(config: ClientConfig) -> URLSession {
        let configuration = config.sessionConfiguration
        
        // Configure caching
        if let cacheConfig = config.cacheConfig {
            let cache = URLCache(
                memoryCapacity: cacheConfig.memoryCapacity,
                diskCapacity: cacheConfig.diskCapacity,
                directory: cacheConfig.diskPath.flatMap(URL.init(string:))
            )
            configuration.urlCache = cache
            configuration.requestCachePolicy = .useProtocolCachePolicy
        }
        
        // Apply timeout
        configuration.timeoutIntervalForRequest = config.timeoutInterval
        
        // Apply default headers
        if !config.defaultHeaders.isEmpty {
            configuration.httpAdditionalHeaders = config.defaultHeaders
        }
        
        return URLSession(configuration: configuration)
    }
    
    /// Creates configured URLRequest
    private func createURLRequest(
        path: String,
        method: OriginalRequest.HTTPMethod,
        parameters: HTTPParameters?,
        headers: HTTPHeaders?
    ) throws -> URLRequest {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = config.timeoutInterval
        
        // Merge default and request-specific headers
        let allHeaders = config.defaultHeaders.merging(headers ?? [:]) { $1 }
        allHeaders.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
        if let parameters = parameters {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        return urlRequest
    }
    
    /// Applies request interceptors
    private func applyInterceptors(for request: inout URLRequest) {
        interceptors.forEach { $0.willSend(request: &request) }
    }
    
    /// Applies response interceptors
    private func applyInterceptors(for response: URLResponse, data: Data) {
        interceptors.forEach { $0.didReceive(response: response, data: data) }
    }
    
    /// Validates HTTP response status codes
    private func validateResponse<E: Decodable & Sendable>(
        _ response: HTTPURLResponse,
        data: Data,
        errorModelType: E.Type
    ) throws {
        switch response.statusCode {
        case 200..<300:
            return
        case 400..<500:
            let errorModel = try? JSONDecoder().decode(E.self, from: data)
            throw HTTPError<E>.clientError(response.statusCode, errorModel)
        case 500..<600:
            throw HTTPError<E>.serverError(response.statusCode)
        default:
            throw HTTPError<E>.unknown
        }
    }
    
    /// Handles request retry logic
    private func handleRetry<T: Decodable & Sendable>(
        httpResponse: HTTPURLResponse,
        data: Data,
        originalRequest: OriginalRequest
    ) async throws -> HTTPResponse<T>? {
        for interceptor in interceptors {
            if let retriedResponse: HTTPResponse<T> = try? await interceptor.onError(
                response: httpResponse,
                data: data,
                originalRequest: originalRequest,
                client: self
            ) {
                return retriedResponse
            }
        }
        return nil
    }
}
