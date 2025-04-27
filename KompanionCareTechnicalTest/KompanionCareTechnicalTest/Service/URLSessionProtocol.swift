//
//  URLSessionProtocol.swift
//  KompanionCareTechnicalTest
//
//  Created by Romain Dubreucq on 27/04/2025.
//

import Foundation

protocol URLSessionProtocol {
    func data(from url: URL, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}
