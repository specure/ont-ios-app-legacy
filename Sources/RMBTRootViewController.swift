//
//  RMBTRootViewController.swift
//  RMBT_ONT
//
//  Created by Sergey Glushchenko on 8/23/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTRootViewController: SWRevealViewController {

    enum ViewController {
        case standard
        case settings
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .lightContent
            // Fallback on earlier versions
        }//self.frontViewController.preferredStatusBarStyle
    }
    
    var showViewController: ViewController = .standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if showViewController != .standard {
            if showViewController == .settings {
                self.frontViewController = UIStoryboard.settingsScreen()
            }
        } else {
            let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
            if configuration.RMBT_VERSION >= 3 {
                let vc = UIStoryboard(name: "RMBTLoopMode", bundle: nil).instantiateInitialViewController()
                self.frontViewController = vc
            } else {
                let vc = UIStoryboard(name: "RMBTGenericMainView", bundle: nil).instantiateInitialViewController()
                self.frontViewController = vc
            }
        }
        // Do any additional setup after loading the view.
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
