//
//  HTTPError.swift
//
//  Created by Stepan Bezhuk on 14.03.2025.
//

import Foundation

/// Contains constants for HTTP error messages
public struct HTTPErrorConstants {
    /// Message for unknown client errors
    public static let unknownClientError: String = "Unknown client error"
    /// Message for empty responses
    public static let emptyResponseError: String = "Empty response"
    /// Message when client error occurs
    public static let clientErrorOccurred: String = "Client error occurred"
    /// Message when server error occurs
    public static let serverErrorOccurred: String = "Server error occurred"
    /// String representation for status code
    public static let statusCodeStr: String = "Status Code"
}

/// Represents possible HTTP errors
/// - Generic parameter ErrorModel: The decodable error model type
public enum HTTPError<ErrorModel: Decodable & Sendable>: Error, Sendable {
    /// Unknown error occurred
    case unknown
    /// Response was empty
    case emptyResponse
    /// Client error (4xx) with status code and optional error model
    case clientError(Int, ErrorModel?)
    /// Server error (5xx) with status code
    case serverError(Int)
}

extension HTTPError {
    /// Returns a human-readable error message
    public var message: String {
        switch self {
        case .unknown: return HTTPErrorConstants.unknownClientError
        case .emptyResponse: return HTTPErrorConstants.emptyResponseError
        case .clientError(_, let model):
            if let model = model as? CustomStringConvertible {
                return model.description
            }
            return HTTPErrorConstants.clientErrorOccurred
        case .serverError(let code):
            return "\(HTTPErrorConstants.serverErrorOccurred), \(HTTPErrorConstants.statusCodeStr): \(code)"
        }
    }
    
    /// Extracts the error model from the error
    /// - Returns: The error model if available
    public func getErrorModel() -> ErrorModel? {
        guard case .clientError(_, let model) = self else { return nil }
        return model
    }
}
