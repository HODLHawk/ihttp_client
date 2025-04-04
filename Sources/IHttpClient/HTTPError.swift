//
//  HTTPError.swift
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

import Foundation

let unknowClientError: String = "Unknown client error"
let clientErrorOccurred: String = "Client error occurred"
let serverErrorOccurred: String = "Server error occurred"
let statusCodeStr: String = "Status Code"

public enum HTTPError: Error, Sendable {
  case unknown
  case clientError(Int, APIErrorResponse?)
  case serverError(Int)
}

extension HTTPError {
  public var message: String {
    switch self {
    case .unknown:
      return unknowClientError
    case .clientError(_, let apiErrorResponse):
      return apiErrorResponse?.message ?? clientErrorOccurred
    case .serverError(let statusCode):
      return "\(serverErrorOccurred), \(statusCodeStr) : \(statusCode)"
    }
  }
  
  public var code: String? {
    switch self {
    case .clientError(_, let apiErrorResponse):
      return apiErrorResponse?.code
    default:
      return nil
    }
  }
}
