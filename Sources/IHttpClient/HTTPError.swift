//
//  HTTPError.swift
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

import Foundation

public struct HTTPErrorConstants {
  public static let unknownClientError: String = "Unknown client error"
  public static let emptyResponseError: String = "Empty response"
  public static let clientErrorOccurred: String = "Client error occurred"
  public static let serverErrorOccurred: String = "Server error occurred"
  public static let statusCodeStr: String = "Status Code"
}

public enum HTTPError<ErrorModel: Decodable & Sendable>: Error, Sendable {
  case unknown
  case emptyResponse
  case clientError(Int, ErrorModel?)
  case serverError(Int)
}

// Дефолтна реалізація для APIErrorResponse
extension HTTPError where ErrorModel == APIErrorResponse {
  public var message: String {
    switch self {
    case .unknown: return HTTPErrorConstants.unknownClientError
    case .emptyResponse: return HTTPErrorConstants.emptyResponseError
    case .clientError(_, let model): return model?.message ?? HTTPErrorConstants.clientErrorOccurred
    case .serverError(let code): return "\(HTTPErrorConstants.serverErrorOccurred), \(HTTPErrorConstants.statusCodeStr): \(code)"
    }
  }
  
  public var code: String? {
    guard case .clientError(_, let model) = self else { return nil }
    return model?.code
  }
}

// Узагальнена реалізація для будь-якої моделі
extension HTTPError {
  public func getErrorModel() -> ErrorModel? {
    guard case .clientError(_, let model) = self else { return nil }
    return model
  }
}
