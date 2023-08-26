//
//  String+DateFromISO.swift
//  ImageFeed-iOS
//
//  Created by Artem Dubovitsky on 26.08.2023.
//

import Foundation

extension String {
    private static let formatterDateISO = ISO8601DateFormatter()
    
    func convertStringToDateFormat() -> Date? {
        let date = String.formatterDateISO.date(from: self)
        return date
    }
}
