//
//  OAuth2Service.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 02.08.2023.
//
import Foundation

final class OAuth2Service {

    static let shared = OAuth2Service()
    private let urlSession: URLSession
    private var currentTask: URLSessionTask?
    private var lastCode: String?
    private let storage: OAuth2TokenStorage
    private let builder: URLRequestBuider
    
    init(
        urlSession: URLSession = .shared,
        storage: OAuth2TokenStorage = .shared,
        builder: URLRequestBuider = .shared
    ) {
        self.urlSession = urlSession
        self.storage = storage
        self.builder = builder
    }

    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        currentTask?.cancel()
        lastCode = code
        guard let request = authTokenRequest(code: code) else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        currentTask = urlSession.objectTask(for: request) { [weak self] (response: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch response {
                case .success(let body):
                    let authToken = body.accessToken
                    self.storage.token = authToken
                    completion(.success(authToken))
//                    self.currentTask = nil
                case .failure(let error):
                    completion(.failure(error))
//                    self.lastCode = nil
                }
            }
        }
//        self.currentTask = currentTask
//        currentTask.resume()
    }
}

extension OAuth2Service {
    private func authTokenRequest(code: String) -> URLRequest? {
        builder.makeHTTPRequest(
            path: "\(Constants.baseAuthTokenPath)"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            defaultBaseURL: Constants.defaultBaseURLString
        )
    }

    private struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        let tokenType: String
        let scope: String
        let createdAt: Int

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case scope
            case createdAt = "created_at"
        }
    }
}
