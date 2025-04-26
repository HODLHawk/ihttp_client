//
//  Interceptor.swift
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

import Foundation

public typealias HTTPParameters = [String: Sendable]
public typealias HTTPHeaders = [String: String]

public protocol Interceptor: Sendable {
    func willSend(request: inout URLRequest)
    func didReceive(response: URLResponse, data: Data)
    func onError<ErrorModel: Decodable>(
        response: HTTPURLResponse,
        data: Data,
        originalRequest: (path: String, method: HTTPMethod, parameters: HTTPParameters?, headers: HTTPHeaders?),
        client: DefaultHttpClient
    ) async throws -> HTTPResponse<ErrorModel>?
}

public extension Interceptor {
    func willSend(request: inout URLRequest) {}
    func didReceive(response: URLResponse, data: Data) {}
    func onError<ErrorModel: Decodable>(
        response: HTTPURLResponse,
        data: Data,
        originalRequest: (path: String, method: HTTPMethod, parameters: HTTPParameters?, headers: HTTPHeaders?),
        client: DefaultHttpClient
    ) async throws -> HTTPResponse<ErrorModel>? { nil }
}
