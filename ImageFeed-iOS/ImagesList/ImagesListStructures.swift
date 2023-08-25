//
//  ImagesListStructures.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 21.08.2023.
//
import Foundation

struct PhotoResult: Codable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let blurHash: String?
    let likes: Int
    let likedByUser: Bool
    let description: String?
    let user: ProfileResult
    let urls: UrlsResult
    
    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case blurHash
        case likes
        case likedByUser = "liked_by_user"
        case description
        case user
        case urls
    }
}

struct UrlsResult: Codable {
    let raw: String?
    let full: String?
    let regular: String?
    let small: String?
    let thumb: String?
}

struct LikeResult: Decodable {
    let photo: PhotoResult
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

extension Photo {
    init(result photo: PhotoResult) {
        self.init(
            id: photo.id,
            size: CGSize(width: photo.width, height: photo.height),
            createdAt: ISO8601DateFormatter().date(from: photo.createdAt ?? ""),
            welcomeDescription: photo.description ?? "",
            thumbImageURL: photo.urls.thumb ?? "",
            largeImageURL: photo.urls.full ?? "",
            isLiked: photo.likedByUser)
    }
}
