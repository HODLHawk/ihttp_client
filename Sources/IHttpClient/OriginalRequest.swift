//
//  OriginalRequest.swift
//  IHttpClient
//
//  Created by Stepan Bezhuk on 26.04.2025.
//

/// Represents the original request configuration
public struct OriginalRequest: Sendable {
    /// The request path
    let path: String
    /// The HTTP method
    let method: HTTPMethod
    /// Optional request parameters
    let parameters: HTTPParameters?
    /// Optional request headers
    let headers: HTTPHeaders?
    
    /// Supported HTTP methods
    public enum HTTPMethod: String, Sendable {
        case get, post, put, delete, patch
    }
}
