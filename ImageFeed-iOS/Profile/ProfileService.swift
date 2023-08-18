//
//  ProfileService.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 14.08.2023.
//
import Foundation

final class ProfileService {
    static let shared = ProfileService()
    
    private let urlSession = URLSession.shared
    private (set) var profile: Profile?
    private var currentTask: URLSessionTask?
    private let builder: URLRequestBuider
    private var lastToken: String?
    
    init(builder: URLRequestBuider = .shared) {
        self.builder = builder
    }
    
    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        if lastToken == token { return }
        currentTask?.cancel()
        lastToken = token
        
        guard let request = makefetchProfileRequest(token: token) else {
            assertionFailure("Invalid fetchProfile request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        let currentTask = fetch(for: request) { [weak self] response in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch response {
                case .success(let profileResult):
                    let profile = Profile(result: profileResult)
                    self.profile = profile
                    completion(.success(profile))
                    self.currentTask = nil
                case .failure(let error):
                    completion(.failure(error))
                    self.currentTask = nil
                }
            }
        }
        self.currentTask = currentTask
        currentTask.resume()
    }
    // MARK: - Private Methods
    private func fetch(
        for request: URLRequest,
        completion: @escaping (Result<ProfileResult, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<ProfileResult, Error> in
                Result { try decoder.decode(ProfileResult.self, from: data) }
            }
            completion(response)
        }
    }
    
    private func makefetchProfileRequest(token: String) -> URLRequest? {
        builder.makeHTTPRequest(
            path: "/me",
            httpMethod: "GET",
            defaultBaseURL: Constants.defaultApiBaseURLString)
    }
}
// MARK: - Network Connection
extension URLSession {
    func data(
        for request: URLRequest?,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletion: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request!, completionHandler: { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode
            {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletion(.success(data))
                } else {
                    fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletion(.failure(NetworkError.urlSessionError))
            }
        })
        task.resume()
        return task
    }
}

