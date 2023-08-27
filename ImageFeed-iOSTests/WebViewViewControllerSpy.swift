//
//  WebViewViewControllerSpy.swift
//  ImageFeed-iOSTests
//
//  Created by Artem Dubovitsky on 27.08.2023.
//
import ImageFeed_iOS
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: ImageFeed_iOS.WebViewPresenterProtocol?
    
    var loadRequestCalled: Bool = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
        
    }
    
    func setProgressHiden(_ isHidden: Bool) {
        
    }
}
