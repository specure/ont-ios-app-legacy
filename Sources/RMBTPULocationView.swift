//
//  RMBTPULocationView.swift
//  RMBT
//
//  Created by Tomáš Baculák on 21/01/15.
//  Copyright © 2015 SPECURE GmbH. All rights reserved.
//

import UIKit
import CoreLocation
///
class RMBTPULocationView: RMBTPopupView, RMBTPopupViewProtocol {

    ///
    @IBOutlet var locationTitleLabel: UILabel?
    @IBOutlet var iconImageView: UIImageView?
    @IBOutlet var locationValueLabel: UILabel?
    @IBOutlet var locationPositionLabel: UILabel?

    var location: CLLocation = CLLocation() {
        didSet {
            age = 0
            assignNewLocationToPUView()
        }
    }
    
    let itemNames = [L("intro.popup.location.position"),
                     L("intro.popup.location.accuracy"),
                     L("intro.popup.location.age"),
                     L("intro.popup.location.altitude")]

    var age = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        
        commonInit()
        self.locationTitleLabel?.text = LC("intro.popup.location.position")
        self.iconImageView?.image = self.iconImageView?.image?.tintedImageUsingColor(tintColor: RMBT_TINT_COLOR)
    }
    
    ///
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    ///
    private func commonInit() {
        delegate = self
        //
        // If user has authorized location services, we should start tracking location now, so that when test starts,
        // we already have a more accurate location
        //
        locationValueLabel?.text = RMBTLocationTracker.sharedTracker.startIfAuthorized() ?
            LC("RMBT-DEVSETTINGS-ENABLED")
            :
            LC("RBMT-DISABLED")
        
        self.updatePosition(with: RMBTLocationTracker.sharedTracker.location)
        // Register as observer for location tracker updates
        NotificationCenter.default.addObserver(self, selector: #selector(RMBTPULocationView.locationsDidChange(_:)),
                                               name: NSNotification.Name(rawValue: "RMBTLocationTrackerNotification"),
                                               object: nil)
        
    }

    @objc private func locationsDidChange(_ notification: Notification) {
        var lastLocation: CLLocation?
        
        for l in notification.userInfo?["locations"] as! [CLLocation] { // !
            if CLLocationCoordinate2DIsValid(l.coordinate) {
                lastLocation = l
                
                logger.debug("Location updated to (\(l.rmbtFormattedString()))")
            }
        }
        
        location = lastLocation!
        
        self.updatePosition(with: location)
    }

    func updatePosition(with location: CLLocation?) {
        location?.fetchCountryAndCity { (_, city) in
            if city == nil || SHOW_CITY_AT_POSITION_VIEW == false {
                self.locationValueLabel?.text = location?.rmbtFormattedArray().first
            } else {
                self.locationValueLabel?.text = city
            }
        }
        
        let formattedArray = self.location.rmbtFormattedArray()
        if formattedArray.count > 1 {
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .medium
            let string = String(format: "%@ %@ @%@", formattedArray[0], formattedArray[1], dateFormatter.string(from: Date()))
            self.locationPositionLabel?.text = string
        }
    }
    
// MARK: - RMBTPopupViewProtocol
    func viewWasTapped(_ superView: UIView!) {
        RMBTLocationTracker.sharedTracker.startAfterDeterminingAuthorizationStatus {
            if let vc = UIApplication.shared.delegate?.window??.rootViewController {
                self.popupVC = RMBTPopupViewController.present(in: vc)
                self.popupVC?.titleText = L("intro.popup.location")
                self.assignNewLocationToPUView()
            }
        }
    }

// MARK: - Methods
    override func updateView() {
        age += 1

        assignNewLocationToPUView()
    }

    func assignNewLocationToPUView() {
        self.popupVC?.itemsNames = itemNames

        let formattedArray = location.rmbtFormattedArray()

        self.popupVC?.itemsValues = [formattedArray[0], formattedArray[1], "\(age) s"/*, "Network"*/, formattedArray[3]]
    }
}
