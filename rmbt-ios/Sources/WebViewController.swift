/*****************************************************************************************************
 * Copyright 2013 appscape gmbh
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

import UIKit
import RMBTClient
import WebKit

///
class WebViewController: TopLevelViewController, WKNavigationDelegate {

    ///
    @IBOutlet fileprivate var webView: WKWebView!
    
    var url: URL?
    var string: String?
    
    var onlyOpen: Bool = false
    
    var isShowNavigationBar = false

    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            webView.topAnchor.constraint(equalTo: self.view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        if let url = url {
            webView.navigationDelegate = self
            webView.load(URLRequest(url: url))
        } else if let string = string {
            webView.navigationDelegate = self
            webView.loadHTMLString(string, baseURL: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isShowNavigationBar {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isShowNavigationBar {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        super.viewWillDisappear(animated)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var action: WKNavigationActionPolicy?
        defer {
            decisionHandler(action ?? .allow)
        }

        guard let url = navigationAction.request.url else { return }
        
        let scheme: String = url.scheme!
        if scheme == "file" {
            action = .allow
        } else if scheme == "mailto" {
            // TODO: Open compose dialog
            action = .cancel
        } else if self.string != nil || self.url != nil {
            action = .allow
        } else if onlyOpen == false {
            presentModalBrowserWithURLString(url.absoluteString)
            action = .cancel
        }
    }
}
