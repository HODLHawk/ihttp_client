//
//  AuthInterceptor.swift
//  Shopper-BE
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

import Foundation

class AuthInterceptor: Interceptor {
  private let accessTokenProvider: () -> String?
  
  init(accessTokenProvider: @escaping () -> String?) {
    self.accessTokenProvider = accessTokenProvider
  }
  
  func willSend(request: inout URLRequest) {
    if let token = accessTokenProvider(), !token.isEmpty {
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
  }
  
  func didReceive(response: URLResponse, data: Data) {
    // Немає додаткової логіки обробки отриманої відповіді
  }
  
  func onError(
    response: HTTPURLResponse,
    data: Data,
    originalRequest: (path: String, method: HTTPMethod, parameters: [String: Any]?, headers: [String: String]?),
    client: IHttpClient
  ) async throws -> Any? {
    // AuthInterceptor тільки додає токен до запитів, але не обробляє помилки
    return nil
  }
}
