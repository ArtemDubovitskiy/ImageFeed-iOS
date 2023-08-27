//
//  ProfileService.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 14.08.2023.
//
import Foundation
import WebKit

final class ProfileService {
    static let shared = ProfileService()
    
    private let urlSession = URLSession.shared
    private (set) var profile: Profile?
    private var currentTask: URLSessionTask?
    private let builder: URLRequestBuider
    private let storage: OAuth2TokenStorage
    private var lastToken: String?
    
    init(builder: URLRequestBuider = .shared,
         storage: OAuth2TokenStorage = .shared) {
        self.builder = builder
        self.storage = storage
    }
    
    func fetchProfile(
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        guard let request = makefetchProfileRequest() else {
            print("Invalid fetchProfile request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        let task = urlSession.objectTask(for: request) {
            [weak self] (response: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch response {
                case .success(let profileResult):
                    let profile = Profile(result: profileResult)
                    self.profile = profile
                    completion(.success(profile))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        self.currentTask = task
        task.resume()
    }
    
    func logout() {
        ProfileService.clean()
        storage.clearToken()
    }
    
    static func clean() {
       HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
       WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
          records.forEach { record in
             WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
          }
       }
    }
    
    // MARK: - Private Methods
    private func makefetchProfileRequest() -> URLRequest? {
        builder.makeHTTPRequest(
            path: "/me",
            httpMethod: "GET",
            defaultBaseURL: Constants.defaultApiBaseURLString)
    }
}
