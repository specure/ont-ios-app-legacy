//
//  RMBTNetworkInfoTableViewCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 10/5/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTNetworkInfoTableViewCell: UITableViewCell {

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
    
    static let ID = "RMBTNetworkInfoTableViewCell"
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationPositionLabel: UILabel!
    @IBOutlet weak var locationTitleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var networkNameLabel: UILabel!
    @IBOutlet weak var networkNameTitleLabel: UILabel!
    @IBOutlet weak var networkTypeLabel: UILabel!
    @IBOutlet weak var networkTypeTitleLabel: UILabel!
    
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
            self.locationPositionLabel.text = modelView?.networkLocation
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.networkNameTitleLabel.text = LC("test.network")
        self.networkTypeTitleLabel.text = LC("history.filter.networktype")
        self.locationTitleLabel?.text = LC("intro.popup.location.position")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
        locationPositionLabel.textColor = RMBTColorManager.networkInfoValueColor
    }
}
