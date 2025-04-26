//
//  IHttpClient.swift
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

import Foundation

/// Main HTTP client implementation
public final actor IHttpClient<ErrorModel: Decodable & Sendable>: IHttpClientProtocol {
    // MARK: - Properties
    private var config: ClientConfig<ErrorModel>
    private var session: URLSession
    private var interceptors: [Interceptor] = []
    
    private var baseURL: URL {
        guard let url = URL(string: config.baseURL) else {
            fatalError("Invalid baseURL in config: \(config.baseURL)")
        }
        return url
    }

    // MARK: - Initialization
    
    public init<Model: Decodable & Sendable>(config: ClientConfig<Model>) {
        self.config = config as! ClientConfig<ErrorModel>
        self.session = Self.configureSession(config: config)
    }
    
    public init(
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
    
    // MARK: - Public Methods
    
    public func request<T: Decodable>(
        _ path: String,
        method: OriginalRequest.HTTPMethod = .get,
        parameters: HTTPParameters? = nil,
        headers: HTTPHeaders? = nil
    ) async throws -> HTTPResponse<T> {
        try await _request(
            path: path,
            method: method,
            parameters: parameters,
            headers: headers
        )
    }
    
    public func performRawRequest<T: Decodable>(
        _ path: String,
        method: OriginalRequest.HTTPMethod = .get,
        parameters: HTTPParameters? = nil,
        headers: HTTPHeaders? = nil
    ) async throws -> HTTPResponse<T> {
        try await _performRawRequest(
            path: path,
            method: method,
            parameters: parameters,
            headers: headers
        )
    }
    
    public func addInterceptor(_ interceptor: Interceptor) {
        interceptors.append(interceptor)
    }
    
    public func clearCache() {
        session.configuration.urlCache?.removeAllCachedResponses()
    }
    
    public func getCacheSize() -> Int {
        guard let cache = session.configuration.urlCache else { return 0 }
        return cache.currentMemoryUsage + cache.currentDiskUsage
    }
    
    public func removeCachedResponse(for url: URL) {
        session.configuration.urlCache?.removeCachedResponse(for: URLRequest(url: url))
    }
    
    public func getCachedResponse(for request: URLRequest) -> CachedURLResponse? {
        session.configuration.urlCache?.cachedResponse(for: request)
    }
    
    public func updateConfig<NewErrorModel: Decodable & Sendable>(_ config: ClientConfig<NewErrorModel>) {
        self.config = config as! ClientConfig<ErrorModel>
        if session.configuration != config.sessionConfiguration {
            self.session = Self.configureSession(config: config)
        }
    }
    
    public func getConfig() -> ClientConfig<ErrorModel> {
        return config
    }
    
    // MARK: - Private Methods
    
    private func _request<T: Decodable>(
        path: String,
        method: OriginalRequest.HTTPMethod,
        parameters: HTTPParameters?,
        headers: HTTPHeaders?
    ) async throws -> HTTPResponse<T> {
        var urlRequest = try createURLRequest(
            path: path,
            method: method,
            parameters: parameters,
            headers: headers
        )
        
        applyInterceptors(for: &urlRequest)
        let (data, response) = try await session.data(for: urlRequest)
        applyInterceptors(for: response, data: data)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            if response.expectedContentLength == 0,
               let emptyValue = EmptyDecodableFactory.makeEmptyValue(for: T.self) {
                return HTTPResponse(data: emptyValue, response: response)
            }
            throw HTTPError<ErrorModel>.unknown
        }
        
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
        
        try validateResponse(httpResponse, data: data)
        
        if httpResponse.statusCode == 204 || data.isEmpty {
            guard let emptyValue = EmptyDecodableFactory.makeEmptyValue(for: T.self) else {
                throw HTTPError<ErrorModel>.emptyResponse
            }
            return HTTPResponse(data: emptyValue, response: response)
        }
        
        let decodedData = try JSONDecoder().decode(T.self, from: data)
        return HTTPResponse(data: decodedData, response: response)
    }
    
    private func _performRawRequest<T: Decodable>(
        path: String,
        method: OriginalRequest.HTTPMethod,
        parameters: HTTPParameters?,
        headers: HTTPHeaders?
    ) async throws -> HTTPResponse<T> {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = config.timeoutInterval
        
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
            throw HTTPError<ErrorModel>.unknown
        }
        
        try validateResponse(httpResponse, data: data)
        
        if httpResponse.statusCode == 204 || data.isEmpty {
            guard let emptyValue = EmptyDecodableFactory.makeEmptyValue(for: T.self) else {
                throw HTTPError<ErrorModel>.emptyResponse
            }
            return HTTPResponse(data: emptyValue, response: response)
        }
        
        let decodedData = try JSONDecoder().decode(T.self, from: data)
        return HTTPResponse(data: decodedData, response: response)
    }
    
    private static func configureSession<Model: Decodable & Sendable>(
        config: ClientConfig<Model>
    ) -> URLSession {
        let configuration = config.sessionConfiguration
        
        if let cacheConfig = config.cacheConfig {
            let cache = URLCache(
                memoryCapacity: cacheConfig.memoryCapacity,
                diskCapacity: cacheConfig.diskCapacity,
                directory: cacheConfig.diskPath.flatMap(URL.init(string:))
            )
            configuration.urlCache = cache
            configuration.requestCachePolicy = .useProtocolCachePolicy
        }
        
        configuration.timeoutIntervalForRequest = config.timeoutInterval
        
        if !config.defaultHeaders.isEmpty {
            configuration.httpAdditionalHeaders = config.defaultHeaders
        }
        
        return URLSession(configuration: configuration)
    }
    
    private func createURLRequest(
        path: String,
        method: OriginalRequest.HTTPMethod,
        parameters: HTTPParameters?,
        headers: HTTPHeaders?
    ) throws -> URLRequest {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = config.timeoutInterval
        
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
    
    private func applyInterceptors(for request: inout URLRequest) {
        interceptors.forEach { $0.willSend(request: &request) }
    }
    
    private func applyInterceptors(for response: URLResponse, data: Data) {
        interceptors.forEach { $0.didReceive(response: response, data: data) }
    }
    
    private func validateResponse(
        _ response: HTTPURLResponse,
        data: Data
    ) throws {
        switch response.statusCode {
        case 200..<300: return
        case 400..<500:
            let model = try? JSONDecoder().decode(ErrorModel.self, from: data)
            throw HTTPError<ErrorModel>.clientError(response.statusCode, model)
        case 500..<600:
            throw HTTPError<ErrorModel>.serverError(response.statusCode)
        default:
            throw HTTPError<ErrorModel>.unknown
        }
    }
    
    private func handleRetry<T: Decodable>(
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
