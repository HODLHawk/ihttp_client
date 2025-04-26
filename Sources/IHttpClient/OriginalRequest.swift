//
//  OriginalRequest.swift
//  IHttpClient
//
//  Created by Stepan Bezhuk on 26.04.2025.
//

public struct OriginalRequest: Sendable {
    let path: String
    let method: HTTPMethod
    let parameters: HTTPParameters?
    let headers: HTTPHeaders?
    
    public enum HTTPMethod: String, Sendable {
        case get, post, put, delete, patch
    }
}
