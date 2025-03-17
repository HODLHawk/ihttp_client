//
//  Interceptor.swift
//  Shopper-BE
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

import Foundation

public typealias HTTPParameters = [String: Sendable]

// MARK: - Interceptor Protocol
public protocol Interceptor: Sendable {
  func willSend(request: inout URLRequest)
  func didReceive(response: URLResponse, data: Data)
  func onError<T: Decodable>(
    response: HTTPURLResponse,
    data: Data,
    originalRequest: (path: String, method: HTTPMethod, parameters: HTTPParameters?, headers: [String: String]?),
    client: IHttpClient
  ) async throws -> HTTPResponse<T>?
}
