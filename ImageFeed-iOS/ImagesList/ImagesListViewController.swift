//
//  ViewController.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 04.04.2023.
//
import UIKit
import Kingfisher
import ProgressHUD

final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService()
    private var imageListServiceObserver: NSObjectProtocol?
    private let placeholder = UIImage(named: "Stub")
    weak var delegate: ImagesListCellDelegate?
    var photos: [Photo] = []

    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.DidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
            }
        imagesListService.fetchPhotosNextPage()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    // MARK: - PrepareForSegue
    override func prepare(for seque: UIStoryboardSegue, sender: Any?) {
        guard seque.identifier == showSingleImageSegueIdentifier,
              let viewController = seque.destination as? SingleImageViewController,
              let indexPath = sender as? IndexPath else {
            super.prepare(for: seque, sender: sender)
            return
        }
        let imageURLString = photos[indexPath.row].largeImageURL
        let imageURL = URL(string: imageURLString)
        viewController.imageURL = imageURL
    }
}
// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let image = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWight = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWight = image.size.width
        let scale = imageViewWight / imageWight
        let cellHight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tableView.numberOfRows(inSection: 0) {
            imagesListService.fetchPhotosNextPage()
        }
    }
}
// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}
// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure (let error):
                UIBlockingProgressHUD.dismiss()
                let alert = UIAlertController(
                            title: "Что-то пошло не так(",
                            message: "\(error.localizedDescription)",
                            preferredStyle: .alert)
                alert.addAction(UIAlertAction(
                            title: "Ок",
                            style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
// MARK: - ConfigCell
extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.delegate = self
        let photo = photos[indexPath.row]
        if let thumbImageUrl = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(with: thumbImageUrl, placeholder: placeholder) {
                [weak self] result in
                guard let self = self else {
                    return
                }
                switch result {
                case .success:
                    cell.date(photo.createdAt)
                    cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                    self.photos = self.imagesListService.photos
                case .failure (let error):
                    print("Изображение не загружено: \(error)")
                    cell.cellImage.image = placeholder
                }
            }
        }
    }
}
// MARK: - UpdateTableViewAnimated
extension ImagesListViewController {
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}


