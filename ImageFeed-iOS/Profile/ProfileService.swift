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
        currentTask = urlSession.objectTask(for: request) {
            [weak self] (response: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch response {
                case .success(let profileResult):
                    let profile = Profile(result: profileResult)
                    self.profile = profile
                    completion(.success(profile))
//                    self.currentTask = nil
                case .failure(let error):
                    completion(.failure(error))
//                    self.currentTask = nil
                }
            }
        }
//        self.currentTask = currentTask
//        currentTask.resume()
    }
    // MARK: - Private Methods
    private func makefetchProfileRequest(token: String) -> URLRequest? {
        builder.makeHTTPRequest(
            path: "/me",
            httpMethod: "GET",
            defaultBaseURL: Constants.defaultApiBaseURLString)
    }
}
