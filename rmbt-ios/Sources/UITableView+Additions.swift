//
//  UITableView+Additions.swift
//  RMBT_ONT
//
//  Created by Sergey Glushchenko on 8/19/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

extension UITableView {
    func register(cell forCellIdentifier: String) {
        let nib = UINib(nibName: forCellIdentifier, bundle: nil)
        self.register(nib, forCellReuseIdentifier: forCellIdentifier)
    }
}
