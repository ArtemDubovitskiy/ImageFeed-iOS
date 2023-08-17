//
//  URLSession+Extention.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 15.08.2023.
//
import Foundation
//MARK: - HTTP URLRequestBuilder
final class URLRequestBuider {
    static let shared = URLRequestBuider()
    private let storage: OAuth2TokenStorage
    
    init(storage: OAuth2TokenStorage = .shared) {
        self.storage = storage
    }

    func makeHTTPRequest(path: String, httpMethod: String, defaultBaseURL: String) -> URLRequest? {
        guard
            let url = URL(string: defaultBaseURL),
            let baseUrl = URL(string: path, relativeTo: url)
        else { return nil }
        
        var request = URLRequest(url: baseUrl)
        request.httpMethod = httpMethod
        
        if let token = storage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
