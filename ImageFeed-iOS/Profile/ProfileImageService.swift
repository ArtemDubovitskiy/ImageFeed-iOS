//
//  ProfileImageService.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 18.08.2023.
//
import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()

    private let urlSession = URLSession.shared
    private var currentTask: URLSessionTask?
    private let builder: URLRequestBuider
    private (set) var avatarURL: String?
    private var lastUserName: String?
    
    init(builder: URLRequestBuider = .shared) {
        self.builder = builder
    }
    
    func fetchProfileImageURL(
        userName: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        if lastUserName == userName { return }
        currentTask?.cancel()
        lastUserName = userName
        
        guard let request = makeProfileImageRequest(userName: userName) else {
            assertionFailure("Invalid fetchProfileImageRequest request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        let currentTask = fetch(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let profilePhoto):
                    guard let smallPhoto = profilePhoto.profileImage?.small else { return }
                    self.avatarURL = smallPhoto
                    completion(.success(smallPhoto))
                    print("avatar yes")
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
    
    private func makeProfileImageRequest(userName: String) -> URLRequest? {
        builder.makeHTTPRequest(
            path: "/users/\(userName)",
            httpMethod: "GET",
            defaultBaseURL: Constants.defaultApiBaseURLString)
    }
}
// MARK: - Network Connection
private extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletion: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request, completionHandler: { data, response, error in
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
