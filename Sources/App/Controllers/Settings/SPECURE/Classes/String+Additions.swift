//
//  String+Additions.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 10/10/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func htmlAttributedString(font: UIFont? = UIFont.systemFont(ofSize: 14, weight: .regular), color: UIColor = RMBTColorManager.tintColor) -> NSAttributedString {
        var currentFont = font
        if currentFont == nil {
            currentFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        }
        guard
            let data = self.data(using: .utf8),
            let string = try? NSMutableAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html,
                          .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil) else { return NSAttributedString() }
        
        string.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: 0, length: string.length))
        if let font = currentFont {
            string.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: string.length))
        }
        
        return string
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
