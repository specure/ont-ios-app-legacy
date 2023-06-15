//
//  RMBTPUProtocolView.swift
//  RMBT
//
//  Created by Tomáš Baculák on 20/01/15.
//  Copyright © 2015 SPECURE GmbH. All rights reserved.
//

import UIKit

///
class RMBTPUProtocolView: RMBTPopupView, RMBTPopupViewProtocol {
    
    ///
    @IBOutlet private var statusView4: RMBTProgressView!
    
    ///
    @IBOutlet private var statusView6: RMBTProgressView!
    
    //
    @IBOutlet var statusView4Label: UILabel?
    
    //
    @IBOutlet var statusView6Label: UILabel?

    // just to conform the protocol - might be better
    var walledGardenImageView: UIImageView?
    ///
    private let itemNames = [
        L("intro.popup.ip.v4-internal"),
        L("intro.popup.ip.v4-external"),
        L("intro.popup.ip.v6-internal")
    ]

    ///
    private let progressString = L("intro.popup.ip.connection-progress")

    ///
    private let noIpText = L("intro.popup.ip.no-ip-text")

    ///
    private var requestFinished = false

    ///
    private let connectivityService = ConnectivityService()

    ///
    private var check_4: RMBTUICheckmarkView! {
        didSet {
            oldValue?.removeFromSuperview()
        }
    }

    ///
    private var check_6: RMBTUICheckmarkView! {
        didSet {
            oldValue?.removeFromSuperview()
        }
    }

    ///
    private var failure_4: RMBTUICrossView! {
        didSet {
            oldValue?.removeFromSuperview()
        }
    }

    ///
    private var failure_6: RMBTUICrossView! {
        didSet {
            oldValue?.removeFromSuperview()
        }
    }

    //

    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    ///
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    ///
    func commonInit() {
        delegate = self
        itemValues  = [progressString, progressString, progressString]
        
    }
    
    ///
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.statusView4Label?.textColor = RMBT_TINT_COLOR
        self.statusView6Label?.textColor = RMBT_TINT_COLOR
    }

// MARK: - Methods
    
    ///
    func initUIItems() {
        check_4 = RMBTUICheckmarkView(frame: statusView4.frame)
        check_6 = RMBTUICheckmarkView(frame: statusView6.frame)
        
        failure_4 = RMBTUICrossView(frame: statusView4.frame)
        failure_6 = RMBTUICrossView(frame: statusView6.frame)
        
        self.addSubview(check_4)
        self.addSubview(check_6)
        
        self.addSubview(failure_4)
        self.addSubview(failure_6)
        // check connectivity
        connectivityDidChange()
    }

    ///
    func setColorForStatusView(color: UIColor) {
        statusView4.strokeColor = color
        statusView6.strokeColor = color
    }

    ///
    func connectivityDidChange() {
        DispatchQueue.main.async {
            self.showProgressIndicatorViews()
            
            self.itemValues = [self.noIpText, self.noIpText, self.noIpText]
            
            //
            
            // let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) / 2) // wait half a second
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.checkConnectivityStatus()
            }
        }
    }

    ///
    func checkConnectivityStatus() {
        //
        DispatchQueue.global(qos: .default).async {
            self.connectivityService.checkConnectivity { [weak self] connectivityInfo in
                logger.debug("CONNECTIVITY INFO: \(connectivityInfo)")

                let ipv4Info = connectivityInfo.ipv4
                let ipv6Info = connectivityInfo.ipv6

                DispatchQueue.main.async {
                    self?.hideProgressIndicatorViews()

                    if ipv4Info.connectionAvailable {
                        self?.failure_4.isHidden = true
                        self?.check_4.isHidden = false
                        self?.check_4.lineColor = (ipv4Info.nat) ? RMBT_CHECK_MEDIOCRE_COLOR : RMBT_RESULT_TEXT_COLOR
                    } else {
                        self?.failure_4.isHidden = false
                        self?.check_4.isHidden = true
                    }

                    //

                    if ipv6Info.connectionAvailable {
                        self?.failure_6.isHidden = true
                        self?.check_6.isHidden = false
                        self?.check_6.lineColor = RMBT_RESULT_TEXT_COLOR //(ipv6Info.nat) ? RMBT_CHECK_MEDIOCRE_COLOR : RMBT_RESULT_TEXT_COLOR
                    } else {
                        self?.failure_6.isHidden = false
                        self?.check_6.isHidden = true
                    }

                    //

                    if let strongSelf = self {
                        strongSelf.itemValues = [
                            ipv4Info.internalIp ?? strongSelf.noIpText,
                            ipv4Info.externalIp ?? strongSelf.noIpText,
                            ipv6Info.internalIp ?? strongSelf.noIpText
                        ]
                    } else {
                        self?.itemValues = ["", "", ""]
                    }
                    
                    self?.assignValuesToPUView()
                }
            }
        }
    }

    ///
    private func showProgressIndicatorViews() {
        self.failure_6.isHidden = true
        self.check_6.isHidden = true
        self.failure_4.isHidden = true
        self.check_4.isHidden = true
        
        self.statusView4.isHidden = false
        self.statusView6.isHidden = false
    }

    ///
    private func hideProgressIndicatorViews() {
        self.statusView4.isHidden = true
        self.statusView6.isHidden = true
    }

    ///
    private func assignValuesToPUView() {
        self.popupVC?.itemsValues = itemValues
        self.popupVC?.itemsNames = itemNames
    }

    ///
    override func updateView() {
        checkConnectivityStatus()
        //checkWalledGarden()
    }

// MARK: - RMBTPopupViewProtocol
    ///
    func viewWasTapped(_ superView: UIView!) {
        if let vc = UIApplication.shared.delegate?.window??.rootViewController {
            self.popupVC = RMBTPopupViewController.present(in: vc)
            self.popupVC?.titleText = L("intro.popup.ip.connections")
        }

        assignValuesToPUView()
    }
}
