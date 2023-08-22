//
//  ImagesListService.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 21.08.2023.
//
import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private let urlSession = URLSession.shared
    private var currentTask: URLSessionTask?
    private let builder: URLRequestBuider
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    init(builder: URLRequestBuider = .shared) {
        self.builder = builder
    }
    
    func fetchPhotosNextPage(
        completion: @escaping (Result<Photo, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        
        let nextPage = lastLoadedPage == nil
        ? 1
        : lastLoadedPage! + 1
        
        guard let request = makeImagesListRequest(page: nextPage) else {
            print("Invalid fetchProfile request")
            completion(.failure(NetworkError.invalidRequest))
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
//                    completion(.success(photos))
                case .failure(let error):
                    print(error)
//                    break
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
}
