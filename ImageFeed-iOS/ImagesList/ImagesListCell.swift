//
//  ImagesListCell.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 20.07.2023.
//
import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_Ru")
        return formatter
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        print("cancelDownloadTask")
    }
    
    func setIsLiked(isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "like_button_active") : UIImage(named: "like_button_no_active")
        likeButton.setImage(likeImage, for: .normal)
    }
    
    func date(_ createdAt: Date?) {
        if let createdAt = createdAt {
            dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            dateLabel.text = dateFormatter.string(from: Date())
        }
    }
}
