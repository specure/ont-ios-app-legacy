//
//  RMBTNetworkInfoCollectionViewCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 10/5/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTNetworkInfoCollectionViewCell: UICollectionViewCell {

    class RMBTNetworkInfoModelView {
        var location: String?
        var networkName: String?
        var networkType: String?
        var networkLocation: String?
        
        init(with networkInfo: RMBTNetworkInfo?) {
            self.location = networkInfo?.location
            self.networkName = networkInfo?.networkName
            self.networkType = networkInfo?.networkType
            self.networkLocation = networkInfo?.networkLocation
        }
    }
    
    static let ID = "RMBTNetworkInfoCollectionViewCell"
    
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationTitleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var networkNameLabel: UILabel!
    @IBOutlet weak var networkNameTitleLabel: UILabel!
    @IBOutlet weak var networkTypeLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var networkTypeTitleLabel: UILabel!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var isLandscape: Bool = false {
        didSet {
            if isLandscape {
                self.topConstraint.constant = 3
            } else {
                self.topConstraint.constant = 25
            }
        }
    }
    
    var modelView: RMBTNetworkInfoModelView? {
        didSet {
            self.locationLabel.text = modelView?.location
            self.networkNameLabel.text = modelView?.networkName
            self.networkTypeLabel.text = modelView?.networkType
            self.positionLabel.text = modelView?.networkLocation
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.networkNameTitleLabel.text = LC("test.network")
        self.networkTypeTitleLabel.text = LC("history.filter.networktype")
        self.locationTitleLabel?.text = LC("intro.popup.location.position")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
    }
    
    func applyColorScheme() {
        networkNameTitleLabel.textColor = RMBTColorManager.networkInfoTitleColor
        networkTypeTitleLabel.textColor = RMBTColorManager.networkInfoTitleColor
        locationTitleLabel.textColor = RMBTColorManager.networkInfoTitleColor
        separatorView.backgroundColor = RMBTColorManager.tableViewSeparator
        
        networkNameLabel?.textColor = RMBTColorManager.networkInfoValueColor
        networkTypeLabel?.textColor = RMBTColorManager.networkInfoValueColor
        locationLabel.textColor = RMBTColorManager.networkInfoValueColor
        positionLabel.textColor = RMBTColorManager.networkInfoValueColor
    }

}
