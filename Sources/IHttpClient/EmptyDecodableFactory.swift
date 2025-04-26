//
//  EmptyDecodableFactory.swift
//  IHttpClient
//
//  Created by Stepan Bezhuk on 24.04.2025.
//

/// Factory for creating empty decodable values
enum EmptyDecodableFactory {
    /// Creates an empty value for the specified Decodable type
    /// - Parameter type: The type to create empty value for
    /// - Returns: Empty value if type is supported (currently only EmptyResponse), otherwise nil
    static func makeEmptyValue<T: Decodable>(for type: T.Type) -> T? {
        if T.self == EmptyResponse.self {
            return EmptyResponse() as? T
        }
        return nil
    }
}

/// Represents an empty server response
public struct EmptyResponse: Decodable, Equatable, Sendable {
    /// Initializes an empty response
    public init() {}
}
