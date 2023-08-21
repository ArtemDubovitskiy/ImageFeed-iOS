//
//  ProfileImageService.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 18.08.2023.
//
import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    private let urlSession = URLSession.shared
    private var currentTask: URLSessionTask?
    private let builder: URLRequestBuider
    private (set) var avatarURL: URL?
    private var lastUserName: String?
    
    init(builder: URLRequestBuider = .shared) {
        self.builder = builder
    }
    
    func fetchProfileImageURL(
        userName: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        guard let request = makeProfileImageRequest(userName: userName) else {
            print("Invalid fetchProfileImageRequest request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self]
            (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let profilePhoto):
                    guard let profilePhoto = profilePhoto.profileImage?.small else { return }
                    self.avatarURL = URL(string: profilePhoto)
                    completion(.success(profilePhoto))
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.DidChangeNotification,
                            object: self,
                            userInfo: ["URL": profilePhoto])
                case .failure(let error):
                    completion(.failure(error))
                }
                self.currentTask = nil
            }
        }
        self.currentTask = task
        task.resume()
    }
    // MARK: - Private Methods
    private func makeProfileImageRequest(userName: String) -> URLRequest? {
        builder.makeHTTPRequest(
            path: "/users/\(userName)",
            httpMethod: "GET",
            defaultBaseURL: Constants.defaultApiBaseURLString)
    }
}
