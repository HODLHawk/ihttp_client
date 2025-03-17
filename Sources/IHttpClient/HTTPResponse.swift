//
//  HTTPResponse.swift
//  Shopper-BE
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

import Foundation

public struct HTTPResponse<T> {
  let data: T
  let response: URLResponse
}
