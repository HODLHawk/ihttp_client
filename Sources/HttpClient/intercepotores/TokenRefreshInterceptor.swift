//
//  TokenRefreshInterceptor.swift
//  Shopper-BE
//
//  Created by Stepan Bezhuk on 17.03.2025.
//

import Foundation

class TokenRefreshInterceptor: Interceptor {
  private let tokenService: TokenService
  
  init(tokenService: TokenService) {
    self.tokenService = tokenService
  }
  
  func willSend(request: inout URLRequest) {
    if let accessToken = tokenService.getAccessToken() {
      request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    }
  }
  
  func onError<T: Decodable>(
    response: HTTPURLResponse,
    data: Data,
    originalRequest: (path: String, method: HTTPMethod, parameters: [String: Any]?, headers: [String: String]?),
    client: HttpClient
  ) async throws -> HTTPResponse<T>? {
    if response.statusCode == 401 {
      // Спроба оновлення токена
      do {
        let newToken = try await tokenService.refreshAccessToken(using: client)
        
        // Оновлення токена в заголовках
        var newHeaders = originalRequest.headers ?? [:]
        newHeaders["Authorization"] = "Bearer \(newToken)"
        
        // Повторний запит із оновленим токеном
        return try await client.performRawRequest(
          originalRequest.path,
          method: originalRequest.method,
          parameters: originalRequest.parameters,
          headers: newHeaders
        )
      } catch {
        // Якщо оновлення не вдалося, то виходимо з акаунту або кидаємо помилку
        tokenService.clearTokens()
        throw error
      }
    }
    return nil
  }
}

// Приклад сервісу для роботи з токенами
class TokenService {
  func getAccessToken() -> String? {
    // Отримання збереженого access token
    return UserDefaults.standard.string(forKey: "accessToken")
  }
  
  func refreshAccessToken(using client: HttpClient) async throws -> String {
    // Логіка оновлення токена через DioClient
    let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") ?? ""
    let response: TokenResponse = try await client.performRawRequest(
      "/auth/refresh",
      method: .post,
      parameters: ["refreshToken": refreshToken],
      headers: ["Content-Type": "application/json"]
    ).data
    
    UserDefaults.standard.setValue(response.accessToken, forKey: "accessToken")
    UserDefaults.standard.setValue(response.refreshToken, forKey: "refreshToken")
    
    return response.accessToken
  }
  
  func clearTokens() {
    UserDefaults.standard.removeObject(forKey: "accessToken")
    UserDefaults.standard.removeObject(forKey: "refreshToken")
  }
}

struct TokenResponse: Decodable {
  let accessToken: String
  let refreshToken: String
}
