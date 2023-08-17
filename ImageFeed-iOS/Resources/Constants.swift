//
//  Constants.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 29.07.2023.
//
import UIKit

enum Constants {
    // MARK: Unsplash api base paths
    static let defaultApiBaseURLString = "https://api.unsplash.com"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let authorizedPath = "/oauth/authorize/native"
    static let defaultBaseURLString = "https://unsplash.com"
    static let baseAuthTokenPath = "/oauth/token"
    // MARK: Unsplash api constants
    static let accessKey = "OcHJu7cYEvzXzyCsFy3-BTjUMLNccpedcCgxqj0rKfE"
    static let secretKey = "EdYkOkzwJunjBY48pJsOrECRMj9xbtrilHN6m53T-1g"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    // MARK: Storage constants
    static let bearerToken = "bearerToken"
}
