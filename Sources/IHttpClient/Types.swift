//
//  Types.swift
//  IHttpClient
//
//  Created by Stepan Bezhuk on 26.04.2025.
//

/// Dictionary type for HTTP parameters
/// - Key: Parameter name
/// - Value: Parameter value (must conform to Sendable)
public typealias HTTPParameters = [String: Sendable]

/// Dictionary type for HTTP headers
/// - Key: Header name
/// - Value: Header value
public typealias HTTPHeaders = [String: String]
