//
//  ProfileViewController.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 23.07.2023.
//
import UIKit

final class ProfileViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var loginNameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    
    @IBOutlet private var logoutButton: UIButton!
    
    @IBAction private func didTapLogoutButton() {
    }
}
