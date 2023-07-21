//
//  ViewController.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 04.04.2023.
//
import UIKit

class ImagesListViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
    // MARK: - Extensions
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell)
        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell) {
    }
}
