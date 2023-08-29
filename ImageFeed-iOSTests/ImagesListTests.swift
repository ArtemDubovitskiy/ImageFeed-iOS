//
//  ImagesListTests.swift
//  ImageFeed-iOSTests
//
//  Created by Artem Dubovitsky on 29.08.2023.
//
@testable import ImageFeed_iOS
import XCTest

// MARK: - ImagesListViewPresenterSpy
final class ImagesListViewPresenterSpy: ImagesListPresenterProtocol {
    var imagesListService: ImageFeed_iOS.ImagesListService
    var viewDidLoadCalled: Bool = false
    var didfetchPhotosNextPageCalled: Bool = false
    var didchangeLikeCalled: Bool = false
    var view: ImagesListViewControllerProtocol?
    
    init(imagesListService: ImagesListService) {
        self.imagesListService = imagesListService
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchPhotosNextPage() {
        didfetchPhotosNextPageCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        didchangeLikeCalled = true
    }
}
// MARK: - ImagesListViewControllerSpy
final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImageFeed_iOS.ImagesListPresenterProtocol?
    var photos: [ImageFeed_iOS.Photo]
    
    init(photos: [Photo]) {
        self.photos = photos
    }
    
    func updateTableViewAnimated() {
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.fetchPhotosNextPage()
    }
    
    func changeLike() {
        presenter?.changeLike(photoId: "", isLike: true)
        { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
// MARK: - ImagesListUnitTests
final class ImagesListTests: XCTestCase {
    func testImagesListViewControllerCallsViewDidLoad() {
        //given
        let viewController = ImagesListViewController()
        let imagesListService = ImagesListService()
        let presenter = ImagesListViewPresenterSpy(imagesListService: imagesListService)

        viewController.presenter = presenter
        presenter.view = viewController

        //when
        _ = viewController.view

        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)  //behaviour verification
    }
    
    func testChangeLikeCalled() {
        // given
        let photos: [Photo] = []
        let imagesListService = ImagesListService.shared
        let view = ImagesListViewControllerSpy(photos: photos)
        let presenter = ImagesListViewPresenterSpy(imagesListService: imagesListService)
        view.presenter = presenter
        presenter.view = view
        
        // when
        view.changeLike()
        
        // then
        XCTAssertTrue(presenter.didchangeLikeCalled) //behaviour verification
    }
    
    func testDidFetchPhotosNextPageCalled() {
        //given
        let tableView = UITableView()
        let tableCell = UITableViewCell()
        let indexPath: IndexPath = IndexPath(row: 2, section: 2)
        let photos: [Photo] = []
        let imagesListService = ImagesListService.shared
        let view = ImagesListViewControllerSpy(photos: photos)
        let presenter = ImagesListViewPresenterSpy(imagesListService: imagesListService)
        view.presenter = presenter
        presenter.view = view  //behaviour verification
        
        //when
        view.tableView(tableView, willDisplay: tableCell, forRowAt: indexPath)
        
        //then
        XCTAssertTrue(presenter.didfetchPhotosNextPageCalled) //behaviour verification
    }
}
