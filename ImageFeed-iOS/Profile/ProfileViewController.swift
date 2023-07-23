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
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var loginNameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    @IBOutlet var logoutButton: UIButton!
    
    @IBAction func didTapLogoutButton() {
    }
}
