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
class HelpViewController: TopLevelViewController {

    ///
    @IBOutlet fileprivate var helpView: WKWebView!

    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        helpView = WKWebView()
        helpView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(helpView)
        
        NSLayoutConstraint.activate([
            helpView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            helpView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            helpView.topAnchor.constraint(equalTo: self.view.topAnchor),
            helpView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        let url = URL(string: RMBTLocalizeURLString(configuration.RMBT_HELP_URL))
        let urlRequest = URLRequest(url: url!)

        // TODO: use KINWebBrowser to get back/forward buttons like statistics

        helpView?.load(urlRequest)
    }
}

// MARK: SWRevealViewControllerDelegate

///
extension HelpViewController {

    ///
    override func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        super.revealController(revealController, didMoveTo: position)
        helpView?.scrollView.isScrollEnabled = position == FrontViewPosition.left
    }
}
