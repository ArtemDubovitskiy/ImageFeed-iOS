//
//  URLSession+Extension.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 18.08.2023.
//
import Foundation

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request, completionHandler: { data, response, error in
            // TODO [Sprint 11] - Написать реализацию
        })
        return task
    }
}
