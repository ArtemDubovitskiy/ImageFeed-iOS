//
//  ProfileViewController.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 23.07.2023.
//
import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    let profileService = ProfileService.shared
    let profileImageService = ProfileImageService.shared
    private var profile: Profile = Profile(
        username: "ekaterina_nov",
        name: "Екатерина Новикова",
        loginName: "@ekaterina_nov",
        bio: "Hello, world!"
    )
    private var profileImageServiceObserver: NSObjectProtocol?
    // MARK: - Private Properties
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "avatar")
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(named: "Logout_button")!,
            target: ProfileViewController?.self,
            action: #selector(Self.didTapLogoutButton))
        button.contentEdgeInsets = UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 8)
        button.tintColor = .ypRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypBlack
        
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
        
        if let profile = profileService.profile {
            self.profile = profile
            updateProfileDetails(profile: profile)
        } else {
            print("ошибка")
        }
        
        if let url = profileImageService.avatarURL {
            updateAvatar(url: url)
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.DidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                self?.updateAvatar(notification: notification)
            }
        setupProfileViewConstrains()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let profile = profileService.profile else {
            assertionFailure("no saved profile")
            return }
        self.nameLabel.text = profile.name
        self.descriptionLabel.text = profile.bio
        self.loginNameLabel.text = profile.loginName
        
        profileImageService.fetchProfileImageURL(userName: profile.username) { _ in }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    // MARK: - Private Methods
    private func updateProfileDetails(profile: Profile) {
        self.profile = profile
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    @objc
    private func updateAvatar(notification: Notification) {
        guard
            isViewLoaded,
            let userInfo = notification.userInfo,
            let profileImageURL = userInfo["URL"] as? String,
            let url = URL(string: profileImageURL)
        else { return }
        updateAvatar(url: url)
    }
    
    private func updateAvatar(url: URL) {
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(with: url)
    }
    
    private func setupProfileViewConstrains() {
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutButton.leadingAnchor.constraint(greaterThanOrEqualTo: avatarImageView.trailingAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    // MARK: - IBAction
    @objc
    private func didTapLogoutButton() {
        let alert = UIAlertController(
                    title: "Пока, пока!",
                    message: "Уверены что хотите выйти?",
                    preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(
                    title: "Да",
                    style: .default,
                    handler: nil))
        alert.addAction(UIAlertAction(
                    title: "Нет",
                    style: .default,
                    handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
