//
//  IHttpClient.swift
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

import Foundation

/// Default implementation of HttpClient protocol
public final actor IHttpClient: DefaultHttpClient {
  private let session: URLSession
  private let baseURL: URL
  private var interceptors: [Interceptor] = []
  
  /// Initializes a new HTTP client with the specified base URL and session
  /// - Parameters:
  ///   - baseURL: The base URL for all requests
  ///   - session: The URL session to use (defaults to shared session)
  public init(baseURL: String, session: URLSession = .shared) {
    guard let url = URL(string: baseURL) else {
      fatalError("Invalid URL: \(baseURL)")
    }
    self.baseURL = url
    self.session = session
  }
  
  /// Add an interceptor to modify requests and responses
  /// - Parameter interceptor: The interceptor to add
  public func addInterceptor(_ interceptor: Interceptor) {
    interceptors.append(interceptor)
  }
  
  /// Perform an HTTP request with full interceptor support
  /// - Parameters:
  ///   - path: The path to request (appended to the base URL)
  ///   - method: The HTTP method to use
  ///   - parameters: The parameters to include in the request
  ///   - headers: Additional headers to include
  /// - Returns: The decoded response
  public func request<T: Decodable>(
    _ path: String,
    method: HTTPMethod = .get,
    parameters: HTTPParameters? = nil,
    headers: [String: String]? = nil
  ) async throws -> HTTPResponse<T> {
    var urlRequest = try createURLRequest(path: path, method: method, parameters: parameters, headers: headers)
    
    applyInterceptors(for: &urlRequest, interceptors: interceptors)
    
    let (data, response) = try await session.data(for: urlRequest)
    
    applyInterceptors(for: response, data: data, interceptors: interceptors)
    
    guard !data.isEmpty else {
      throw HTTPError.unknown
    }
    
    if let httpResponse = response as? HTTPURLResponse,
       let retriedResponse = try await handleErrorIfNeeded(
        response: httpResponse,
        data: data,
        originalRequest: (path: path, method: method, parameters: parameters, headers: headers),
        client: self,
        interceptors: interceptors
       ) as HTTPResponse<T>? {
      return retriedResponse
    }
    
    if let httpResponse = response as? HTTPURLResponse {
      try handleStandardError(response: httpResponse, data: data)
    }
    
    let decodedData = try JSONDecoder().decode(T.self, from: data)
    return HTTPResponse(data: decodedData, response: response)
  }
  
  /// Perform a raw HTTP request without interceptor processing
  /// - Parameters:
  ///   - path: The path to request (appended to the base URL)
  ///   - method: The HTTP method to use
  ///   - parameters: The parameters to include in the request
  ///   - headers: Additional headers to include
  /// - Returns: The decoded response
  public func performRawRequest<T: Decodable>(
    _ path: String,
    method: HTTPMethod = .get,
    parameters: [String: Any]? = nil,
    headers: [String: String]? = nil
  ) async throws -> HTTPResponse<T> {
    var urlRequest = URLRequest(url: baseURL.appendingPathComponent(path))
    urlRequest.httpMethod = method.rawValue
    headers?.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
    
    if let parameters = parameters {
      urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
      urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    let (data, response) = try await session.data(for: urlRequest)
    
    guard !data.isEmpty, let httpResponse = response as? HTTPURLResponse else {
      throw HTTPError.unknown
    }
    
    if (400..<600).contains(httpResponse.statusCode) {
      throw HTTPError.clientError(httpResponse.statusCode, nil)
    }
    
    let decodedData = try JSONDecoder().decode(T.self, from: data)
    return HTTPResponse(data: decodedData, response: response)
  }
  
  // MARK: - Private Methods
  
  private func createURLRequest(
    path: String,
    method: HTTPMethod,
    parameters: [String: Sendable]?,
    headers: [String: String]?
  ) throws -> URLRequest {
    var urlRequest = URLRequest(url: baseURL.appendingPathComponent(path))
    urlRequest.httpMethod = method.rawValue
    
    headers?.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
    
    if let parameters = parameters {
      urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters)
      urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    return urlRequest
  }
  
  private func applyInterceptors(for request: inout URLRequest, interceptors: [Interceptor]) {
    for interceptor in interceptors {
      interceptor.willSend(request: &request)
    }
  }
  
  private func applyInterceptors(for response: URLResponse, data: Data, interceptors: [Interceptor]) {
    for interceptor in interceptors {
      interceptor.didReceive(response: response, data: data)
    }
  }
  
  private func handleErrorIfNeeded<T: Decodable>(
    response: HTTPURLResponse,
    data: Data,
    originalRequest: (path: String, method: HTTPMethod, parameters: HTTPParameters?, headers: [String: String]?),
    client: DefaultHttpClient,
    interceptors: [Interceptor]
  ) async throws -> HTTPResponse<T>? {
    for interceptor in interceptors {
      if let retriedResponse = try? await interceptor.onError(
        response: response,
        data: data,
        originalRequest: originalRequest,
        client: client
      ) as HTTPResponse<T>? {
        return retriedResponse
      }
    }
    return nil
  }
  
  private func handleStandardError(response: HTTPURLResponse, data: Data) throws {
    switch response.statusCode {
    case 300..<500:
      let clientErrorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
      throw HTTPError.clientError(response.statusCode, clientErrorResponse)
    case 500..<600:
      throw HTTPError.serverError(response.statusCode)
    default:
      break
    }
  }
}
