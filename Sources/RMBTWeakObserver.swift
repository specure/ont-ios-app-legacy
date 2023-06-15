//
//  RMBTWeakObserver.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 9/23/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTWeakObserver: NSObject {
    weak var delegate: NSObject?
    
    init(_ delegate: NSObject) {
        self.delegate = delegate
    }
}
