//
//  RMBTPopupView.swift
//  RMBT
//
//  Created by Tomáš Baculák on 16/01/15.
//  Copyright © 2015 SPECURE GmbH. All rights reserved.
//

import UIKit

@objc protocol RMBTPopupViewProtocol {
    func viewWasTapped(_ superView: UIView!)
}

class RMBTPopupView: UIView {
    
    /// TODO - better solution here !!!
    internal var itemValues: [String] = []

    weak var delegate: RMBTPopupViewProtocol?
    
    var popupVC: RMBTPopupViewController?
    
    var isShouldUserInterectionEnabled = true {
        didSet {
            self.isUserInteractionEnabled = isShouldUserInterectionEnabled
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    private func commonInit() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(RMBTPopupView.didTap))
        addGestureRecognizer(recognizer)
    }

    @objc func didTap() {
        delegate?.viewWasTapped(self.superview)
    }
    
    func updateView() {

    }
}
