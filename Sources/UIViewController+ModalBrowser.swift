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
import KINWebBrowser
import RMBTClient

///
protocol ModalBrowser {

    ///
    func presentModalBrowserWithURLString(_ url: String)
}

///
extension UIViewController: ModalBrowser {

    ///
    func presentModalBrowserWithURLString(_ url: String) {
        let webViewController = KINWebBrowserViewController.navigationControllerWithWebBrowser()

        webViewController?.navigationBar.isTranslucent = false

        present(webViewController!, animated: true, completion: nil)

        let webBrowser = webViewController?.rootWebBrowser()
//        webBrowser?.loadURLString(RMBTLocalizeURLString(url as NSString))
        webBrowser?.loadURLString(url)
        
        webBrowser?.showsPageTitleInNavigationBar = false
        webBrowser?.showsURLInNavigationBar = false
        webBrowser?.actionButtonHidden = false
        webBrowser?.barTintColor = RMBTColorManager.navigationBarBackground
        webBrowser?.tintColor = RMBTColorManager.navigationBarTitleColor
    }
    
    func presentModalBrowserWithURL(_ url: URL) {
        let webViewController = KINWebBrowserViewController.navigationControllerWithWebBrowser()
        
        webViewController?.navigationBar.isTranslucent = false
        
        present(webViewController!, animated: true, completion: nil)
        
        let webBrowser = webViewController?.rootWebBrowser()
        //        webBrowser?.loadURLString(RMBTLocalizeURLString(url as NSString))
        let content = try? String(contentsOf: url)
        webBrowser?.loadHTMLString(content)
        
        webBrowser?.showsPageTitleInNavigationBar = false
        webBrowser?.showsURLInNavigationBar = false
        webBrowser?.actionButtonHidden = false
        webBrowser?.barTintColor = RMBTColorManager.navigationBarBackground
        webBrowser?.tintColor = RMBTColorManager.navigationBarTitleColor
    }

}
