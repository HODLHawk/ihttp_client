//
//  APIErrorResponse.swift
//  Shopper-BE
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

public struct APIErrorResponse: Decodable, Sendable {
  // Add your API error response properties here
  let message: String?
  let code: String?
}
