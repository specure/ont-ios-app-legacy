//
//  RMBTAdvertisingManager.swift
//  RMBT_ONT
//
//  Created by Sergey Glushchenko on 7/22/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit
import GoogleMobileAds

class RMBTAdvertisingManager: NSObject {
    enum State {
        case unknowed
        case loading
        case loaded
        case error
    }
    static let shared = RMBTAdvertisingManager()
    
    var adMobBannerView: GADBannerView = GADBannerView(adSize: kGADAdSizeBanner)
    var adMobBigBannerView: GADBannerView = GADBannerView(adSize: kGADAdSizeMediumRectangle)
    
    var state = State.unknowed
    
    var onLoadedAdMobHandler: (_ error: Error?) -> Void = { _ in }
    
    override init() {
        super.init()
        adMobBannerView.delegate = self
        adMobBannerView.tag = 123
        adMobBigBannerView.tag = 321
    }
    
    func configureAdMobBanner(_ adUnitID: String, appId: String, rootViewController: UIViewController?) {
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [(kGADSimulatorID as! String)]
        adMobBannerView.adUnitID = adUnitID
        adMobBannerView.rootViewController = rootViewController
        adMobBigBannerView.adUnitID = adUnitID
        adMobBigBannerView.rootViewController = rootViewController
    }
    
    func reloadingAdMobBanner() {
        if state != .loading,
            adMobBannerView.adUnitID != nil {
            self.state = .loading
            self.loadAdvertising(for: self.adMobBannerView)
            self.loadAdvertising(for: self.adMobBigBannerView)
        }
    }
    
    func loadAdvertising(for banner: GADBannerView) {
        let request = GADRequest()
        banner.load(request)
    }
    
    func showAdMobBanner(with rect: CGRect, in view: UIView) {
        self.clearBanner(in: view)
        adMobBannerView.frame = rect
        view.addSubview(adMobBannerView)
    }
    
    func showAdMobBigBanner(with rect: CGRect, in view: UIView) {
        self.clearBanner(in: view)
        adMobBigBannerView.frame = rect
        view.addSubview(adMobBigBannerView)
    }
    
    func clearBanner(in view: UIView) {
        if view.subviews.contains(adMobBannerView) {
            adMobBannerView.removeFromSuperview()
        }
        if view.subviews.contains(adMobBigBannerView) {
            adMobBigBannerView.removeFromSuperview()
        }
    }
}

extension RMBTAdvertisingManager: GADBannerViewDelegate {
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print(error)
        self.state = State.error
        self.onLoadedAdMobHandler(error)
        logger.debug("error advertising loading \(error.localizedDescription)")
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.state = State.loaded
        self.onLoadedAdMobHandler(nil)
        logger.debug("advertising loaded")
    }
}
