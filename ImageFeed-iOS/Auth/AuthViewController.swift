//
//  AuthViewController.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 29.07.2023.
//
import UIKit

final class AuthViewController: UIViewController {
    private let ShowWebViewSegueIdentifier = "ShowWebView"
        
    override func prepare(for seque: UIStoryboardSegue, sender: Any?) {
        if seque.identifier == ShowWebViewSegueIdentifier {
            guard
                let webViewViewController = seque.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(ShowWebViewSegueIdentifier)") }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: seque, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        // TODO: process code
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
