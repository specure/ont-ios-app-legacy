//
//  RMBTNavigationController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 26.12.2020.
//  Copyright © 2020 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTNavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
