//
//  SingleImageViewController.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 23.07.2023.
//
import UIKit
import Kingfisher
import ProgressHUD

final class SingleImageViewController: UIViewController {
    var imageURL: URL?
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    // MARK: - IBAction
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        let share = UIActivityViewController(
            activityItems: [imageURL as Any],
            applicationActivities: nil
            )
            present(share, animated: true, completion: nil)
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        showSingleImage()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    // MARK: - Private Methods
    private func showSingleImage() {
        guard let imageURL = imageURL else { return }
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: imageURL) { [ weak self ] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let fullImage):
                scrollView.minimumZoomScale = 0.1
                scrollView.maximumZoomScale = 1.25
                self.rescaleAndCenterImageInScrollView(image: fullImage.image)
            case .failure:
                self.showError()
            }
        }
    }
    private func showError() {
        let alert = UIAlertController(
                    title: "Что-то пошло не так(",
                    message: "Попробовать еще раз?",
                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(
                    title: "Повторить",
                    style: .default) { [weak self] _ in
                        self?.dismiss(animated: true)
                    })
        alert.addAction(UIAlertAction(
                    title: "Не надо",
                    style: .default) { [weak self] _ in
                        self?.showSingleImage()
                    })
        self.present(alert, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}
// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let halfWidth = (scrollView.bounds.size.width - imageView.frame.size
               .width) / 2
        let halfHeight = (scrollView.bounds.size.height - imageView.frame.size
               .height) / 2
        scrollView.contentInset = .init(top: halfHeight, left: halfWidth, bottom: 0, right: 0)
    }
}
