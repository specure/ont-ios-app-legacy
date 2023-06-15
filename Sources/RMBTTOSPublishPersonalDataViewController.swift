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

import Foundation
import RMBTClient
import WebKit

///
class RMBTTOSPublishPersonalDataViewController: UIViewController, WKNavigationDelegate {
    
    ///
    @IBOutlet private var publishPersonalDataSwitcher: UISwitch!

    @IBOutlet weak var toolbarView: UIView!
    ///
    private var webView: WKWebView!

    ///
    @IBOutlet private var acceptIntroLabel: UILabel!

    //
    @IBOutlet private var toolBar: UIToolbar!
    
    //
    @IBOutlet internal var titleLabel: UIButton?
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            webView.topAnchor.constraint(equalTo: self.view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: self.toolbarView.topAnchor)
        ])
        
        // NT-367
        //
        self.titleLabel?.setTitle(String.formatStringPublishPersonalData(), for: .normal)
        self.titleLabel?.setTitleColor(RMBT_TINT_COLOR, for: .normal)
        self.titleLabel?.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.titleLabel?.minimumScaleFactor = 0.8
        
        publishPersonalDataSwitcher.tintColor = RMBT_TINT_COLOR
        publishPersonalDataSwitcher.onTintColor = RMBT_TINT_COLOR
        
        self.navigationItem.titleView = titleLabel
        //self.navigationItem.title?.formatStringPrivacyAndPolicy()
        //
        self.acceptIntroLabel.text = String.formatStringPublishPersonalDataAgreementText()
        self.toolBar.formatStringPersonalDataAgreementOptions()

        //acceptIntroLabel.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        
        if let doc = Bundle.main.path(forResource: "publish_personal_data_text", ofType: "html") {
            let url = URL(fileURLWithPath: doc)
//            webView.loadRequest(URLRequest(url: url))
            
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
    }
    
    func applyColorScheme() {
        self.titleLabel?.setTitleColor(RMBTColorManager.navigationBarTitleColor, for: .normal)
        self.view.tintColor = RMBTColorManager.tintColor
        self.toolBar.tintColor = RMBTColorManager.tintColor
        self.toolBar.backgroundColor = RMBTColorManager.navigationBarBackground
        self.toolBar.barTintColor = RMBTColorManager.navigationBarBackground
        for item in self.toolBar.items ?? [] {
            item.tintColor = RMBTColorManager.navigationBarTitleColor
        }
    }
    
    ///
    @IBAction func doContinue(_ sender: AnyObject) {
        RMBTSettings.sharedSettings.publishPublicData = self.publishPersonalDataSwitcher.isOn
        self.dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var action: WKNavigationActionPolicy?
        defer {
            decisionHandler(action ?? .allow)
        }

        guard let url = navigationAction.request.url else { return }
        
        let scheme: String = navigationAction.request.url!.scheme! // !
        if scheme == "file" {
            action = .allow
        } else if scheme == "mailto" {
            // TODO: Open compose dialog
            action = .cancel
        } else {
            presentModalBrowserWithURLString(url.absoluteString) // !
            action = .cancel
        }
    }
}
