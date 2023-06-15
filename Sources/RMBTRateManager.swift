//
//  RMBTRateManager.swift
//  UnitTests
//
//  Created by Sergey Glushchenko on 11/27/17.
//  Copyright © 2017 SPECURE GmbH. All rights reserved.
//

import UIKit
import StoreKit

class RMBTRateManager: NSObject {
    private let prefix = "RMBTRatePrefix"
    private let datePrefix = "date"
    
    static let manager = RMBTRateManager()
    
    enum Action {
        case yes
        case no
        case remind
    }
    
    var isDisabled = true
    var title: String?
    var message: String? = "If you like MyApp, please take the time and write review"
    var applicationId: String?
    var cancelLabel: String? = "No, Thanks"
    var rateLabel: String? = "Yes"
    var remindLabel: String? = "Remind Me Later"
    var completionHandler: (_ identifier: String, _ action: Action) -> Void = { _, _ in }
    
    //@params
    //maxCount - how much counts before display popup
    //duration - duration after last popup for display popup
    func tick(with identifier: String, maxCount: Int, duration: Double) {
        if isDisabled == true {
            return
        }
        var counts = UserDefaults.standard.integer(forKey: prefix + identifier)
        let dateInterval = UserDefaults.standard.double(forKey: prefix + datePrefix + identifier)
        if counts == -1 { //Disabled rate by this identifier
            return
        }
        counts += 1
        if maxCount <= counts && (Date().timeIntervalSince1970 - dateInterval > duration) {
            if #available( iOS 10.3,*) {
                SKStoreReviewController.requestReview()
                UserDefaults.standard.set(0, forKey: prefix + identifier)
                UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: prefix + datePrefix + identifier)
                UserDefaults.standard.synchronize()
            }
//            let alert = self.alertController({ [weak self] (action) in
//                if action == .no || action == .yes {
//                    UserDefaults.standard.set(-1, forKey: (self?.prefix ?? "") + identifier)
//                    UserDefaults.standard.synchronize()
//                }
//                if action == .yes {
//                    if let applicationId = self?.applicationId {
//                        let link = String(format: "itms://itunes.apple.com/us/app/apple-store/id%@?mt=8", applicationId)
//                        if let url = URL(string: link) {
//                            UIApplication.shared.openURL(url)
//                        }
//                    }
//                    self?.completionHandler(identifier, action)
//                }
//            })
//            if let delegate = UIApplication.shared.delegate,
//                let window = delegate.window {
//                window?.rootViewController?.present(alert, animated: true, completion: nil)
//            }
//            UserDefaults.standard.set(0, forKey: prefix + identifier)
        } else {
            UserDefaults.standard.set(counts, forKey: prefix + identifier)
        }
        
        UserDefaults.standard.synchronize()
    }
    
    private func alertController(_ completionHandler: @escaping (_ action: Action) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: self.title, message: self.message, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: self.rateLabel, style: .default) { (_) in
            completionHandler(.yes)
        }
        
        let noAction = UIAlertAction(title: self.cancelLabel, style: .cancel) { (_) in
            completionHandler(.no)
        }
        
        let remindAction = UIAlertAction(title: self.remindLabel, style: .default) { (_) in
            completionHandler(.remind)
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        alert.addAction(remindAction)
        
        return alert
    }
    
}
