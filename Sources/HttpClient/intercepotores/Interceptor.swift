//
//  Interceptor.swift
//  Shopper-BE
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

import Foundation

// MARK: - Interceptor Protocol
protocol Interceptor {
  func willSend(request: inout URLRequest)
  func didReceive(response: URLResponse, data: Data)
  func onError(
    response: HTTPURLResponse,
    data: Data,
    originalRequest: (path: String, method: HTTPMethod, parameters: [String: Any]?, headers: [String: String]?),
    client: HttpClient
  ) async throws -> Any?
}

// Базова реалізація для зменшення обов'язкового коду в імплементаціях
extension Interceptor {
  func didReceive(response: URLResponse, data: Data) {}

  func onError(
    response: HTTPURLResponse,
    data: Data,
    originalRequest: (path: String, method: HTTPMethod, parameters: [String: Any]?, headers: [String: String]?),
    client: HttpClient
  ) async throws -> Any? {
    return nil
  }
}
