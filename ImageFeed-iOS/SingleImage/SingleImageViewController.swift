//
//  SingleImageViewController.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 23.07.2023.
//

import UIKit

final class SingleImageViewController: UIViewController {
    @IBOutlet var imageView: UIView!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
