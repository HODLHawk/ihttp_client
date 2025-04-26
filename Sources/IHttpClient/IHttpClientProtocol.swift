//
//  IHttpClientProtocol.swift
//
//  Created by Stepan Bezhuk on 24.03.2025.
//

import Foundation

public protocol IHttpClientProtocol: Actor {
    func addInterceptor(_ interceptor: Interceptor)
    
    func request<T: Decodable, E: Decodable>(
        _ path: String,
        method: OriginalRequest.HTTPMethod,
        parameters: HTTPParameters?,
        headers: HTTPHeaders?,
        errorModelType: E.Type
    ) async throws -> HTTPResponse<T>
    
    func performRawRequest<T: Decodable, E: Decodable>(
        _ path: String,
        method: OriginalRequest.HTTPMethod,
        parameters: HTTPParameters?,
        headers: HTTPHeaders?,
        errorModelType: E.Type
    ) async throws -> HTTPResponse<T>
}
