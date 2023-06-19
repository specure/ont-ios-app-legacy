//
//  MarkdownView.swift
//  RMBT
//
//  Created by Polina on 11.06.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import Foundation
import MarkdownView
import SafariServices

extension MarkdownView {
    func setOnTouchLink(_ view: UIViewController) {
        self.onTouchLink = { [weak view] request in
            guard let url = request.url else { return false }

            if url.scheme == "http" || url.scheme == "https" {
                let safari = SFSafariViewController(url: url)
                view?.present(safari, animated: true, completion: nil)
                return false
            } else {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return false
            }
        }
    }
}
