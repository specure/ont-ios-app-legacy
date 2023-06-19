/*****************************************************************************************************
 * Copyright 2014-2016 SPECURE GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *****************************************************************************************************/

import Foundation

///
protocol StringAttribute {

}

/// taken from http://stackoverflow.com/questions/3586871/bold-non-bold-text-in-a-single-uilabel/17743543#33910728
extension UILabel: StringAttribute {

//    ///
//    func boldRange(range: Range<String.Index>) {
//        if let text = self.attributedText {
//            let attr = NSMutableAttributedString(attributedString: text)
//            let start = text.string.startIndex.distanceTo(range.startIndex)
//            let length = range.startIndex.distanceTo(range.endIndex)
//            attr.addAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: self.font.pointSize)], range: NSRange(location: start, length: length))
//            self.attributedText = attr
//        }
//    }
    
    func boldRangeNew(range: NSRange) {
        if let text = self.attributedText {
            let attr = NSMutableAttributedString(attributedString: text)
            attr.addAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: self.font.pointSize)], range: range)
            self.attributedText = attr
        }
    }

    ///
    func boldSubstring(_ substr: String) {
//        let range = self.text?.range(of: substr)
//        if let r = range {
//            boldRange(range: r)
//        }
        let len = substr as NSString
        let range = NSRange(location: 0, length: len.length)
        boldRangeNew(range: range)
    }
}

extension String {
    func attributedPlaceholder(_ color: UIColor = UIColor.white) -> NSAttributedString {
        let placeholder = NSAttributedString(string: self, attributes: [NSAttributedString.Key.foregroundColor: color])
        return placeholder
    }
}
