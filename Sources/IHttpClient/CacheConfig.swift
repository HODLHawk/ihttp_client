//
//  CacheConfig.swift
//  IHttpClient
//
//  Created by Stepan Bezhuk on 26.04.2025.
//

import Foundation

/// HTTP request caching configuration
public struct CacheConfig {
    /// Maximum cache size in bytes (default 10MB)
    public let memoryCapacity: Int
    
    /// Maximum disk cache size in bytes (default 50MB)
    public let diskCapacity: Int
    
    /// Cache storage directory (system by default)
    public let diskPath: String?
    
    public init(memoryCapacity: Int = 10_000_000, diskCapacity: Int = 50_000_000, diskPath: String? = nil) {
        self.memoryCapacity = memoryCapacity
        self.diskCapacity = diskCapacity
        self.diskPath = diskPath
    }
}
