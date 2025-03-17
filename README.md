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
```

# HTTP Client with Interceptors

This repository contains an HTTP client for performing asynchronous HTTP requests with support for interceptors. The HTTP client allows you to customize the request and response flow, including modifying headers, handling errors, and retrying requests.

## Features

- **Custom Interceptors**: Modify request/response behavior before and after sending requests.
- **Asynchronous Requests**: Uses async/await for non-blocking network operations.
- **Flexible Error Handling**: Provides a custom error handling mechanism with retry support.
- **Easy-to-use Interface**: Simple API for sending GET, POST, PUT, and DELETE requests.

## Example Usage

```swift
import Foundation

// Initialize the HTTP client
let client = HTTPClient(baseURL: URL(string: "https://api.example.com")!)

// Add the LoggingInterceptor
client.addInterceptor(LoggingInterceptor())

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
```

## Interceptor example

```swift
import Foundation

// Define a custom interceptor that logs request and response details
class LoggingInterceptor: Interceptor {
    
    // This method is called before sending the request
    func willSend(request: inout URLRequest) {
        print("Request: \(request.httpMethod ?? "Unknown method") \(request.url?.absoluteString ?? "Unknown URL")")
    }
    
    // This method is called after receiving the response
    func didReceive(response: URLResponse, data: Data) {
        if let httpResponse = response as? HTTPURLResponse {
            print("Response: \(httpResponse.statusCode) from \(httpResponse.url?.absoluteString ?? "Unknown URL")")
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
            print("Response Data: \(json)")
        }
    }
    
    // Optional: This method can be used to handle errors or retry logic
    func onError<T: Decodable>(
        response: HTTPURLResponse,
        data: Data,
        originalRequest: (path: String, method: HTTPMethod, parameters: HTTPParameters?, headers: [String: String]?),
        client: IHttpClient
    ) async throws -> HTTPResponse<T>? {
        // Retry on server errors (5xx responses)
        if (500...599).contains(response.statusCode) {
            print("Server error detected, retrying...")
            return try await client.request(originalRequest.path, method: originalRequest.method, parameters: originalRequest.parameters, headers: originalRequest.headers)
        }
        
        // Return nil if we don't want to retry
        return nil
    }
}

```
