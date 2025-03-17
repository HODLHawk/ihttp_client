# HTTP Client

This project provides an asynchronous HTTP client for interacting with REST APIs, supporting HTTP request configurations, error handling, and integration with interceptors. The client uses standard HTTP methods (GET, POST, PUT, DELETE) to communicate with APIs.

## Features

- Sending HTTP requests with support for various methods (GET, POST, PUT, DELETE).
- Automatic header management, e.g., `Content-Type: application/json`.
- Support for query parameters in JSON format.
- Interceptor mechanism for handling requests and responses.
- Error handling with customizable behavior via interceptors.
- Simple and convenient API for interacting with HTTP requests.

## Example Usage

```swift
import Foundation

// Initialize the client
let client = IHttpClient(baseURL: URL(string: "https://api.example.com")!)

// Example of a GET request
async {
    do {
        let response: HTTPResponse<MyModel> = try await client.request("/path/to/resource")
        print(response.data)
    } catch {
        print("Error: \(error)")
    }
}

// Example of a POST request
async {
    do {
        let parameters: [String: Any] = ["key": "value"]
        let response: HTTPResponse<MyModel> = try await client.request("/path/to/resource", method: .post, parameters: parameters)
        print(response.data)
    } catch {
        print("Error: \(error)")
    }
}
