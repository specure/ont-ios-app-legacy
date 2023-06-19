//
//  UIView+Constraint.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11/22/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

extension UIView {
    
    enum ConstraintIdentifier: String {
        case width
        case height
    }
    
    func constraint(with identifier: String) -> NSLayoutConstraint? {
        for constraint in self.constraints where constraint.identifier == identifier {
            return constraint
        }
        
        return nil
    }
}
