//
//  Interceptor.swift
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

import Foundation

/// Protocol for intercepting HTTP requests and responses
public protocol Interceptor: Sendable {
    /// Called before sending a request
    /// - Parameter request: The request about to be sent
    func willSend(request: inout URLRequest)
    
    /// Called after receiving a response
    /// - Parameters:
    ///   - response: The received response
    ///   - data: The response data
    func didReceive(response: URLResponse, data: Data)
    
    /// Called when an error occurs, allows modifying or retrying the request
    /// - Parameters:
    ///   - response: The error response
    ///   - data: The error data
    ///   - originalRequest: The original request
    ///   - client: The HTTP client
    /// - Returns: A new response if the error was handled, nil otherwise
    func onError<ErrorModel: Decodable>(response: HTTPURLResponse, data: Data, originalRequest: OriginalRequest, client: IHttpClientProtocol) async throws -> HTTPResponse<ErrorModel>?
}

public extension Interceptor {
    /// Default empty implementation for willSend
    func willSend(request: inout URLRequest) {}
    /// Default empty implementation for didReceive
    func didReceive(response: URLResponse, data: Data) {}
    /// Default empty implementation for onError
    func onError<ErrorModel: Decodable>(response: HTTPURLResponse, data: Data, originalRequest: OriginalRequest, client: IHttpClientProtocol) async throws -> HTTPResponse<ErrorModel>? { nil }
}
