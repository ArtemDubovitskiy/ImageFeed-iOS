//
//  ImagesListService.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 21.08.2023.
//
import Foundation

final class ImagesListService {
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private let urlSession = URLSession.shared
    private var currentTask: URLSessionTask?
    private let builder: URLRequestBuider
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    init(builder: URLRequestBuider = .shared) {
        self.builder = builder
    }
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        
        let nextPage = lastLoadedPage == nil
        ? 1
        : lastLoadedPage! + 1
        
        guard let request = makeImagesListRequest(page: nextPage) else {
            print("Invalid fetchPhotos request")
            return
        }
        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let photoResult):
                    let photos = photoResult.map { Photo(result: $0) }
                    self.photos.append(contentsOf: photos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default
                        .post(
                            name: ImagesListService.DidChangeNotification,
                            object: nil)
                case .failure(let error):
                    print(error)
                }
                self.currentTask = nil
            }
        }
        self.currentTask = task
        task.resume()
    }
    
    func changeLike(photoId: String,
                    isLike: Bool,
                    _ completion: @escaping (Result<Void, Error>) -> Void
    ) { assert(Thread.isMainThread)
        guard let request = makeLikeRequest(photoID: photoId, isLike: isLike) else {
            print("Invalid like ")
            return
        }
        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<LikeResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(id: photo.id,
                                             size: photo.size,
                                             createdAt: photo.createdAt,
                                             welcomeDescription: photo.welcomeDescription,
                                             thumbImageURL: photo.thumbImageURL,
                                             largeImageURL: photo.largeImageURL,
                                             isLiked: !photo.isLiked
                        )
                        self.photos[index] = newPhoto
                        completion(.success(()))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        self.currentTask = task
        task.resume()
    }
    // MARK: - Private Methods
    private func makeImagesListRequest(page: Int) -> URLRequest? {
        builder.makeHTTPRequest(
            path: "/photos"
            + "?page=\(page)"
            + "&&per_page=10",
            httpMethod: "GET",
            defaultBaseURL: Constants.defaultApiBaseURLString)
    }
    private func makeLikeRequest(photoID: String, isLike: Bool) -> URLRequest? {
        builder.makeHTTPRequest(
            path: "/photos/\(photoID)/like",
            httpMethod: isLike ? "POST" : "DELETE",
            defaultBaseURL: Constants.defaultApiBaseURLString)
    }
}
