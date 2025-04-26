//
//  OriginalRequest.swift
//  IHttpClient
//
//  Created by Stepan Bezhuk on 26.04.2025.
//

/// Represents original request configuration
public struct OriginalRequest: Sendable {
    /// Request path component
    let path: String
    
    /// HTTP method
    let method: HTTPMethod
    
    /// Request parameters
    let parameters: HTTPParameters?
    
    /// Request headers
    let headers: HTTPHeaders?
    
    /// Supported HTTP methods
    public enum HTTPMethod: String, Sendable {
        case get, post, put, delete, patch
    }
}
