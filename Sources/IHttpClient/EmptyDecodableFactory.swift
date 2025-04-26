//
//  EmptyDecodableFactory.swift
//  IHttpClient
//
//  Created by Stepan Bezhuk on 24.04.2025.
//

/// Factory for creating empty decodable responses
enum EmptyDecodableFactory {
    /// Creates an empty value for decodable types
    /// - Parameter type: The Decodable type to create empty value for
    /// - Returns: Empty value if type is supported, otherwise nil
    static func makeEmptyValue<T: Decodable>(for type: T.Type) -> T? {
        if T.self == EmptyResponse.self {
            return EmptyResponse() as? T
        }
        return nil
    }
}

/// Represents an empty server response
public struct EmptyResponse: Decodable, Equatable, Sendable {
    /// Initializes a new empty response
    public init() {}
}
