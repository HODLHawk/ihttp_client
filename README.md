# 🌐 IHttpClient - Modern Swift HTTP Client

**A type-safe, actor-based HTTP client with interceptors and caching support**

## 📦 Features

- 🚀 **Full async/await support**
- 🔄 **Request/response interceptors**
- 💾 **Configurable caching**
- 🛡️ **Type-safe error handling**
- 🧵 **Thread-safe (actor-based)**
- ⚙️ **Customizable configuration**

## 📥 Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-repo/IHttpClient.git", from: "1.0.0")
]
```

Or add via Xcode:
File → Add Packages → Enter package URL

## 🏁 Quick Start

1. Define Error Model

```swift
struct ApiError: Decodable, Sendable {
    let message: String
    let code: Int
}
```

2. Initialize Client

```swift
let client = IHttpClient<ApiError>(
    baseURL: "https://api.example.com",
    errorModelType: ApiError.self
)
```

3. Make Requests

```swift
// GET request
let users = try await client.request(
    "/users",
    method: .get
)

// POST with parameters
let response = try await client.request(
    "/posts",
    method: .post,
    parameters: ["title": "Hello"],
    headers: ["X-App-Version": "1.0"]
)
```

## 🛠 Advanced Usage

**Interceptors**

```swift
struct AuthInterceptor: Interceptor {
    func willSend(request: inout URLRequest) {
        request.addValue("Bearer token123", forHTTPHeaderField: "Authorization")
    }
}

client.addInterceptor(AuthInterceptor())
```

**Caching**

```swift
let cacheConfig = CacheConfig(
    memoryCapacity: 20_000_000,  // 20MB
    diskCapacity: 100_000_000    // 100MB
)

let cachedClient = IHttpClient<ApiError>(
    baseURL: "https://api.example.com",
    errorModelType: ApiError.self,
    cacheConfig: cacheConfig
)
```

**Error Handling**

```swift
do {
    let data = try await client.request("/protected")
} catch HTTPError<ApiError>.clientError(let code, let model) {
    print("Error \(code): \(model?.message ?? "Unknown")")
} catch {
    print("Request failed: \(error)")
}
```

## ⚙️ Configuration Options

| Parameter           | Type                  | Description                     | Default Value  |
|---------------------|-----------------------|---------------------------------|----------------|
| `baseURL`           | `String`              | Base API URL                    | **Required**   |
| `errorModelType`    | `Decodable.Type`      | Type for error responses        | **Required**   |
| `session`           | `URLSession`          | Custom URLSession instance      | `.shared`      |
| `cacheConfig`       | `CacheConfig?`        | Cache configuration             | `nil`          |
| `timeoutInterval`   | `TimeInterval`        | Request timeout in seconds      | `60.0`         |
| `enableLogging`     | `Bool`                | Enable debug logging            | `false`        |
| `defaultHeaders`    | `HTTPHeaders`         | Default request headers         | `[:]`          |
| `retryCount`        | `Int`                 | Number of automatic retries     | `0`            |

### Usage Example:

```swift
let config = ClientConfig<ApiError>(
    baseURL: "https://api.example.com/v1",
    errorModelType: ApiError.self,
    session: customSession,
    cacheConfig: CacheConfig(
        memoryCapacity: 20_000_000,
        diskCapacity: 100_000_000
    ),
    timeoutInterval: 30.0,
    enableLogging: true,
    defaultHeaders: [
        "Accept": "application/json",
        "X-App-Version": "1.0.0"
    ]
)
```

## 📝 Best Practices

Reuse clients - Create one client per API endpoint
Centralize error handling - Create wrapper functions
Use interceptors for:
Authentication
Logging
Request modification
Implement retry logic in interceptors

##  🤝 Contributing

Pull requests welcome! Please:

Open an issue first
Follow Swift style guidelines
Add tests for new features

## 📜 License

MIT License
Copyright © 2025 Stepan Bezhuk
