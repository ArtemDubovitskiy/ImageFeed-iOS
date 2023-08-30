//
//  WebViewPresenterSpy.swift
//  ImageFeed-iOSTests
//
//  Created by Artem Dubovitsky on 27.08.2023.
//
import ImageFeed_iOS
import Foundation

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didUpdateProgressValue(_ newValue: Double) {

    }

    func code(from url: URL) -> String? {
        return nil
    }
}
