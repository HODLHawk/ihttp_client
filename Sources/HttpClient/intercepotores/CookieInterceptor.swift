//
//  CookieInterceptor.swift
//  Shopper-BE
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

import Foundation

class CookieInterceptor: Interceptor {
  private let refreshTokenKey = "refreshToken"
  private(set) var refreshToken: String?
  private var cookieStorage: [String: String] = [:]
  
  func willSend(request: inout URLRequest) {
    // Додаємо збережені куки до запиту, якщо вони є
    if !cookieStorage.isEmpty {
      let cookieString = cookieStorage.map { "\($0.key)=\($0.value)" }.joined(separator: "; ")
      request.setValue(cookieString, forHTTPHeaderField: "Cookie")
    }
  }
  
  func didReceive(response: URLResponse, data: Data) {
    if let httpResponse = response as? HTTPURLResponse,
       let allHeaderFields = httpResponse.allHeaderFields as? [String: String],
       let setCookie = allHeaderFields["Set-Cookie"] {
      
      let cookies = setCookie.split(separator: ";").map { $0.trimmingCharacters(in: .whitespaces) }
      for cookie in cookies {
        if cookie.contains("=") {
          let parts = cookie.split(separator: "=", maxSplits: 1)
          if parts.count == 2 {
            let key = String(parts[0])
            let value = String(parts[1])
            cookieStorage[key] = value
            
            // Зберігаємо refreshToken окремо, якщо знайдено
            if key == refreshTokenKey {
              refreshToken = value
            }
          }
        }
      }
    }
  }
  
  func onError(
    response: HTTPURLResponse,
    data: Data,
    originalRequest: (path: String, method: HTTPMethod, parameters: [String: Any]?, headers: [String: String]?),
    client: HttpClient
  ) async throws -> Any? {
    // CookieInterceptor не обробляє помилки, а тільки отримує куки
    return nil
  }
}
