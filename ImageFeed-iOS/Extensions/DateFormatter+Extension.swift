//
//  DateFormatter.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 26.08.2023.
//
import Foundation

extension DateFormatter {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_Ru")
        return formatter
    }()
}
