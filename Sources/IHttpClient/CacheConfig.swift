//
//  CacheConfig.swift
//  IHttpClient
//
//  Created by Stepan Bezhuk on 26.04.2025.
//

import Foundation

/// Configuration for HTTP request caching
public struct CacheConfig {
    /// Maximum in-memory cache size in bytes
    public let memoryCapacity: Int
    
    /// Maximum disk cache size in bytes
    public let diskCapacity: Int
    
    /// Custom directory path for cache storage
    public let diskPath: String?
    
    /// Initializes a new cache configuration
    /// - Parameters:
    ///   - memoryCapacity: Size of in-memory cache in bytes (default: 10MB)
    ///   - diskCapacity: Size of disk cache in bytes (default: 50MB)
    ///   - diskPath: Optional custom directory path (default: nil)
    public init(
        memoryCapacity: Int = 10_000_000,
        diskCapacity: Int = 50_000_000,
        diskPath: String? = nil
    ) {
        self.memoryCapacity = memoryCapacity
        self.diskCapacity = diskCapacity
        self.diskPath = diskPath
    }
}
