//
//  ImagesListCellDelegate.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 25.08.2023.
//

import Foundation

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
