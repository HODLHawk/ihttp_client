//
//  HTTPResponse.swift
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

import Foundation

/// Represents an HTTP response with decoded data
/// - Generic parameter T: The decodable response type
public struct HTTPResponse<T: Decodable & Sendable>: Sendable {
    /// The decoded response data
    public let data: T
    /// The original URL response
    public let response: URLResponse
    
    /// Initializes a new HTTP response
    /// - Parameters:
    ///   - data: The decoded data
    ///   - response: The URL response
    public init(data: T, response: URLResponse) {
        self.data = data
        self.response = response
    }
}
