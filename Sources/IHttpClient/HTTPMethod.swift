//
//  HTTPMethod.swift
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
