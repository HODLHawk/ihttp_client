//
//  HTTPResponse.swift
//  Shopper-BE
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

import Foundation

public struct HTTPResponse<T: Decodable & Sendable>: Sendable {
  let data: T
  let response: URLResponse
  
  public init(data: T, response: URLResponse) {
    self.data = data
    self.response = response
  }
}
