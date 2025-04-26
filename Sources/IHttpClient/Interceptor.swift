//
//  Interceptor.swift
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

import Foundation

/// Protocol for intercepting HTTP requests/responses
public protocol Interceptor: Sendable {
    /// Called before request is sent
    /// - Parameter request: Request to modify
    func willSend(request: inout URLRequest)
    
    /// Called after response is received
    /// - Parameters:
    ///   - response: Received response
    ///   - data: Response data
    func didReceive(response: URLResponse, data: Data)
    
    /// Called when error occurs (allows retry/modification)
    /// - Parameters:
    ///   - response: Error response
    ///   - data: Response data
    ///   - originalRequest: Original request
    ///   - client: HTTP client instance
    /// - Returns: New response if error was handled
    func onError<ErrorModel: Decodable>(
        response: HTTPURLResponse,
        data: Data,
        originalRequest: OriginalRequest,
        client: any IHttpClientProtocol
    ) async throws -> HTTPResponse<ErrorModel>?
}

public extension Interceptor {
    /// Default empty implementation
    /// - Parameter request: Request to modify
    func willSend(request: inout URLRequest) {}
    
    /// Default empty implementation
    /// - Parameters:
    ///   - response: Received response
    ///   - data: Response data
    func didReceive(response: URLResponse, data: Data) {}
    
    /// Default empty implementation
    /// - Parameters:
    ///   - response: Error response
    ///   - data: Response data
    ///   - originalRequest: Original request
    ///   - client: HTTP client instance
    /// - Returns: nil (no retry)
    func onError<ErrorModel: Decodable>(
        response: HTTPURLResponse,
        data: Data,
        originalRequest: OriginalRequest,
        client: any IHttpClientProtocol
    ) async throws -> HTTPResponse<ErrorModel>? { nil }
}
