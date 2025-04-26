//
//  OriginalRequest.swift
//  IHttpClient
//
//  Created by Stepan Bezhuk on 26.04.2025.
//

/// Represents original request configuration
public struct OriginalRequest: Sendable {
    /// Request path component
    public let path: String
    
    /// HTTP method
    public let method: HTTPMethod
    
    /// Request parameters
    public let parameters: HTTPParameters?
    
    /// Request headers
    public let headers: HTTPHeaders?
    
    /// Supported HTTP methods
    public enum HTTPMethod: String, Sendable {
        case get, post, put, delete, patch
    }
}
