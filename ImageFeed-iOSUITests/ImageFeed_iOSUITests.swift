//
//  ImageFeed_iOSUITests.swift
//  ImageFeed-iOSUITests
//
//  Created by Artem Dubovitsky on 29.08.2023.
//
import XCTest

final class ImageFeed_iOSUITests: XCTestCase {
    private let app = XCUIApplication()
    
    private let login = "" // Пожалуйста, введите ваш e-mail
    private let password = "" // Пожалуйста, введите ваш пароль
    private let nameLabel = "" // Пожалуйста, введите ваши Имя и Фамилию
    private let loginNameLabel = "" // Пожалуйста, введите ваше имя пользователя @...
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()

        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText(login)
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText(password)
        sleep(1)
        
        app.toolbars.buttons["Done"].tap()
        sleep(1)
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
        
    func testFeed() throws {
        let tablesQuery = app.tables
            
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["Like button"].tap()
        cellToLike.buttons["Like button"].tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["Back button"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["\(nameLabel)"].exists)
        XCTAssertTrue(app.staticTexts["\(loginNameLabel)"].exists)
        
        app.buttons["Logout button"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
