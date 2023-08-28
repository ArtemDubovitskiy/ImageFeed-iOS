//
//  ProfilePresenter.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 28.08.2023.
//
import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    var profile: Profile? { get }
    var avatarURL: URL? { get }
    
    func viewDidLoad()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    var profileImageServiceObserver: NSObjectProtocol?
    var profile: Profile? {
        profileService.profile
    }
    var avatarURL: URL? {
        profileImageService.avatarURL
    }
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    init(view: ProfileViewControllerProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        view?.updateProfileDetails(profile: profileService.profile)
        view?.updateAvatar(url: avatarURL)
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.view?.updateAvatar(url: self.avatarURL)
        }
        profileImageService.fetchProfileImageURL(userName: profile?.username ?? "")
        { _ in }
    }
}
