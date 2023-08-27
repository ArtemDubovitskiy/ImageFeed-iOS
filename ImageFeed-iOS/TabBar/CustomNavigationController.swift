//
//  CustomNavigationController.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 09.08.2023.
//

import UIKit

class CustomNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        return visibleViewController
    }
}
