//
//  AuthViewController.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 29.07.2023.
//
import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    weak var delegate: AuthViewControllerDelegate?
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(showWebViewSegueIdentifier)") }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
//        delegate?.authViewController(self, didAuthenticateWithCode: code)
        OAuth2Service.shared.fetchOAuthToken(code) { [weak self ] result in
            guard let self = self else { return }
            switch result {
            case .success(let authToken):
                print("Token: \(authToken)")
                OAuth2TokenStorage.shared.token = authToken
            case .failure(let error):
                print("Token error: \(error)")
            }
            DispatchQueue.main.async {
                self.delegate?.authViewController(self, didAuthenticateWithCode: code)
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
