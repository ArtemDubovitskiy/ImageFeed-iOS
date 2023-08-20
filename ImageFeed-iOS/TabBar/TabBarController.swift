//
//  TabBarController.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 20.08.2023.
//
import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "CustomNavigationController"
        )
            
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        profileViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 6,left: 0,bottom: -6,right: 0)
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
