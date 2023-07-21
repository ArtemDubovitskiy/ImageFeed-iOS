//
//  ImagesListCell.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 20.07.2023.
//
import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
}
