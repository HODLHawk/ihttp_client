//
//  HTTPResponse.swift
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

import Foundation

public struct HTTPResponse<T: Decodable & Sendable>: Sendable {
  public let data: T
  public let response: URLResponse
  
  public init(data: T, response: URLResponse) {
    self.data = data
    self.response = response
  }
}
