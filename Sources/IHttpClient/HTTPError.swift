//
//  HTTPError.swift
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

import Foundation

/// Contains constants for HTTP error messages
public struct HTTPErrorConstants {
    /// Default message for unknown client errors
    public static let unknownClientError: String = "Unknown client error"
    
    /// Message for empty responses
    public static let emptyResponseError: String = "Empty response"
    
    /// Default message for client errors
    public static let clientErrorOccurred: String = "Client error occurred"
    
    /// Default message for server errors
    public static let serverErrorOccurred: String = "Server error occurred"
    
    /// Label for status codes
    public static let statusCodeStr: String = "Status Code"
}

/// Represents HTTP request errors
public enum HTTPError<ErrorModel: Decodable & Sendable>: Error, Sendable {
    /// Unknown/unclassified error
    case unknown
    
    /// Empty response received
    case emptyResponse
    
    /// Client error (4xx status code)
    /// - Parameters:
    ///   - Int: HTTP status code
    ///   - ErrorModel?: Optional decoded error model
    case clientError(Int, ErrorModel?)
    
    /// Server error (5xx status code)
    /// - Parameter Int: HTTP status code
    case serverError(Int)
}

extension HTTPError {
    /// Returns a human-readable error message
    public var message: String {
        switch self {
        case .unknown: return HTTPErrorConstants.unknownClientError
        case .emptyResponse: return HTTPErrorConstants.emptyResponseError
        case .clientError(_, let model):
            return (model as? CustomStringConvertible)?.description ?? HTTPErrorConstants.clientErrorOccurred
        case .serverError(let code):
            return "\(HTTPErrorConstants.serverErrorOccurred), \(HTTPErrorConstants.statusCodeStr): \(code)"
        }
    }
    
    /// Extracts the decoded error model from client errors
    /// - Returns: The error model if available
    public func getErrorModel() -> ErrorModel? {
        guard case .clientError(_, let model) = self else { return nil }
        return model
    }
}
