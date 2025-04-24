//
//  EmptyDecodableFactory.swift
//  IHttpClient
//
//  Created by Stepan Bezhuk on 24.04.2025.
//

enum EmptyDecodableFactory {
  static func makeEmptyValue<T: Decodable>(for type: T.Type) -> T? {
    if T.self == EmptyResponse.self {
      return EmptyResponse() as? T
    }
    return nil
  }
}

public struct EmptyResponse: Decodable, Equatable {
  init() {}
}
