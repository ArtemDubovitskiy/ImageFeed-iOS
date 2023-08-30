//
//  ProfileViewTests.swift
//  ImageFeed-iOSTests
//
//  Created by Artem Dubovitsky on 28.08.2023.
//
@testable import ImageFeed_iOS
import XCTest
// MARK: - ProfileViewPresenterSpy
final class ProfileViewPresenterSpy: ProfilePresenterProtocol {
    var view: ImageFeed_iOS.ProfileViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var profile: ImageFeed_iOS.Profile?
    var avatarURL: URL?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
}
// MARK: - ProfileViewControllerSpy
final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ImageFeed_iOS.ProfilePresenterProtocol?
    var updateAvatarCalled: Bool = false
    var updateProfileDetailsCalled: Bool = false
    
    func updateAvatar(url: URL?) {
        updateAvatarCalled = true
    }
    
    func updateProfileDetails(profile: ImageFeed_iOS.Profile?) {
        updateProfileDetailsCalled = true
    }
}
// MARK: - ProfileViewUnitTests
final class ProfileViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()

        viewController.presenter = presenter
        presenter.view = viewController

        //when
        _ = viewController.view

        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)  //behaviour verification
    }
    
    func testPresenterUpdateAvatarCalled() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(view: viewController)
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(viewController.updateAvatarCalled)
    }
    
    func testPresenterUpdaseProfileDetailsCalled() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(view: viewController)
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(viewController.updateProfileDetailsCalled)
    }
}
