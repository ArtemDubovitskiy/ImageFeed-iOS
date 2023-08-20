//
//  SplashViewController.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 08.08.2023.
//
import UIKit

final class SplashViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let storage = OAuth2TokenStorage.shared
    private let service = OAuth2Service.shared
    private var profile: Profile?
    private var wasChecked: Bool = false
    
    private let splashImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        view.addSubview(splashImageView)
        
        setupSplashViewConstrains()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkAuthStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    // MARK: - Private Methods
    private func checkAuthStatus() {
        // TODO - Исправить заглушку на рабочее решение / горят сроки:
        guard !wasChecked else { return }
        wasChecked = true
        if storage.token != nil {
            UIBlockingProgressHUD.show()
            fetchProfile()
            UIBlockingProgressHUD.dismiss()
            switchToTabBarController()
        } else {
            switchToAuthController()
        }
    }
    private func switchToAuthController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController")
        guard let authViewController = viewController as? AuthViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            showAlert()
            fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    private func setupSplashViewConstrains() {
        NSLayoutConstraint.activate([
            splashImageView.widthAnchor.constraint(equalToConstant: 75),
            splashImageView.heightAnchor.constraint(equalToConstant: 78),
            splashImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
//            UIBlockingProgressHUD.show()
            self.fetchOAuthToken(code)
        }
//        UIBlockingProgressHUD.show()
    }
    
    private func fetchOAuthToken(_ code: String) {
        UIBlockingProgressHUD.show()
        service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.fetchProfile()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                showAlert()
            }
        }
    }
    
    private func fetchProfile() {
//        UIBlockingProgressHUD.show()
        profileService.fetchProfile() { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.profile = profile
                self.profileImageService.fetchProfileImageURL(userName: profile.username) { _ in }
                self.switchToTabBarController()
            case .failure:
                showAlert()
//                break
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
    private func showAlert() {
        let alert = UIAlertController(
                    title: "Что-то пошло не так(",
                    message: "Не удалось войти в систему",
                    preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ок", style: .cancel) { [weak self ] _ in
            guard let self else { return }
            switchToAuthController()
        }
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
}
