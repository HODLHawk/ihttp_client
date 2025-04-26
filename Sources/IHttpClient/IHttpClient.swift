//
//  IHttpClient.swift
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

import Foundation

public final actor IHttpClient: IHttpClientProtocol {
    private let session: URLSession
    private let baseURL: URL
    private var interceptors: [Interceptor] = []
    
    public init(baseURL: String, session: URLSession = .shared) {
        guard let url = URL(string: baseURL) else {
            fatalError("Invalid URL: \(baseURL)")
        }
        self.baseURL = url
        self.session = session
    }
    
    public func addInterceptor(_ interceptor: Interceptor) {
        interceptors.append(interceptor)
    }
    
    public func request<T: Decodable & Sendable, E: Decodable & Sendable>(
        _ path: String,
        method: OriginalRequest.HTTPMethod = .get,
        parameters: HTTPParameters? = nil,
        headers: HTTPHeaders? = nil,
        errorModelType: E.Type
    ) async throws -> HTTPResponse<T> {
        try await _request(path: path, method: method, parameters: parameters, headers: headers, errorModelType: errorModelType)
    }
    
    private func _request<T: Decodable & Sendable, E: Decodable & Sendable>(
        path: String,
        method: OriginalRequest.HTTPMethod,
        parameters: HTTPParameters?,
        headers: HTTPHeaders?,
        errorModelType: E.Type
    ) async throws -> HTTPResponse<T> {
        var urlRequest = try createURLRequest(path: path, method: method, parameters: parameters, headers: headers)
        applyInterceptors(for: &urlRequest)
        
        let (data, response) = try await session.data(for: urlRequest)
        applyInterceptors(for: response, data: data)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            if response.expectedContentLength == 0 {
                if let emptyValue = EmptyDecodableFactory.makeEmptyValue(for: T.self) {
                    return HTTPResponse(data: emptyValue, response: response)
                }
            }
            throw HTTPError<E>.unknown
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
    
    // MARK: - Helper Methods
    
    private func createURLRequest(
        path: String,
        method: OriginalRequest.HTTPMethod,
        parameters: HTTPParameters?,
        headers: HTTPHeaders?
    ) throws -> URLRequest {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        headers?.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
        if let parameters = parameters {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return urlRequest
    }
    
    private func applyInterceptors(for request: inout URLRequest) {
        interceptors.forEach { $0.willSend(request: &request) }
    }
    
    private func applyInterceptors(for response: URLResponse, data: Data) {
        interceptors.forEach { $0.didReceive(response: response, data: data) }
    }
    
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
    
    public func performRawRequest<T: Decodable & Sendable, E: Decodable & Sendable>(
        _ path: String,
        method: OriginalRequest.HTTPMethod = .get,
        parameters: HTTPParameters? = nil,
        headers: HTTPHeaders? = nil,
        errorModelType: E.Type
    ) async throws -> HTTPResponse<T> {
        try await _performRawRequest(path: path, method: method, parameters: parameters, headers: headers, errorModelType: errorModelType)
    }
    
    private func _performRawRequest<T: Decodable & Sendable, E: Decodable & Sendable>(
        path: String,
        method: OriginalRequest.HTTPMethod,
        parameters: HTTPParameters?,
        headers: HTTPHeaders?,
        errorModelType: E.Type
    ) async throws -> HTTPResponse<T> {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        headers?.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
        if let parameters = parameters {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
}
