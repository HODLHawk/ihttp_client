//
//  DefaultHttpClient.swift
//
//  Created by Stepan Bezhuk on 24.03.2025.
//

import Foundation

// MARK: - HTTP Client Protocol

/// Protocol defining HTTP client functionality
public protocol DefaultHttpClient: Actor {
  /// Add an interceptor to the HTTP client
  func addInterceptor(_ interceptor: Interceptor)
  
  /// Perform an HTTP request and decode the response
  func request<T: Decodable>(
    _ path: String,
    method: HTTPMethod,
    parameters: HTTPParameters?,
    headers: [String: String]?
  ) async throws -> HTTPResponse<T>
  
  /// Perform a raw HTTP request without interceptors
  func performRawRequest<T: Decodable>(
    _ path: String,
    method: HTTPMethod,
    parameters: [String: Any]?,
    headers: [String: String]?
  ) async throws -> HTTPResponse<T>
}
