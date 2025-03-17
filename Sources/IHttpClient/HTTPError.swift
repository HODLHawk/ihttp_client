//
//  HTTPError.swift
//  Shopper-BE
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

import Foundation

let unknowClientError: String = "Unknown client error"

public enum HTTPError: Error, Sendable {
  case unknown
  case clientError(Int, APIErrorResponse?)
  case serverError(Int)
}
