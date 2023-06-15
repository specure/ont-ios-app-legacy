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
import UIKit

///
class TopLevelViewController: UIViewController, RMBTColorManagerProtocol {

    ///
    @IBOutlet var sideBarButton: UIBarButtonItem?
    
    ///
    var revealControllerEnabled: Bool = true
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if configuration.RMBT_VERSION == 3 {
            return .all
        }
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if configuration.RMBT_VERSION == 3 {
            return true
        }
        if UIApplication.shared.statusBarOrientation != .portrait {
            return true
        }
        return false
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return RMBTColorManager.statusBarStyle
    }
    
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !RMBTConfig.sharedInstance.RMBT_VERSION_NEW {
            addProjectBackground()
        }
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
       
        if revealControllerEnabled,
            let revealViewController = revealViewController() {
            // Assign action for the side button
            sideBarButton?.target = revealViewController
            sideBarButton?.action = #selector(SWRevealViewController.revealToggle(_:))
        
            view.addGestureRecognizer(revealViewController.edgeGestureRecognizer())
            view.addGestureRecognizer(revealViewController.tapGestureRecognizer())
        
            revealViewController.delegate = self
        } else {
            if let s = sideBarButton, let index = navigationItem.leftBarButtonItems?.firstIndex(of: s) {
                navigationItem.leftBarButtonItems?.remove(at: index)
            }
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func applyColorScheme() { }
}

// MARK: SWRevealViewControllerDelegate

///
extension TopLevelViewController: SWRevealViewControllerDelegate {
    
    ///
    func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        guard let revealViewController = revealViewController() else { return }
        let isPosLeft = position == .left
        
        if isPosLeft {
            view.removeGestureRecognizer(revealViewController.panGestureRecognizer())
            view.addGestureRecognizer(revealViewController.edgeGestureRecognizer())
        } else {
            if let recogniser = revealViewController.edgeGestureRecognizer() {
                if let viewGestures = view.gestureRecognizers {
                    if viewGestures.contains(recogniser) {
                        view.removeGestureRecognizer(recogniser)
                    }
                }
            }

            view.addGestureRecognizer(revealViewController.panGestureRecognizer())
        }
    }
}
