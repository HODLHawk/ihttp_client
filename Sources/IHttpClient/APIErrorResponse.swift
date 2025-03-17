//
//  APIErrorResponse.swift
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

public struct APIErrorResponse: Decodable, Sendable {
  public let message: String?
  public let code: String?
  
  public init(message: String?, code: String?) {
    self.message = message
    self.code = code
  }
}
