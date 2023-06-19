//
//  RMBTTestTableViewCell_M.swift
//  RMBT
//
//  Created by Tomáš Baculák on 29/01/15.
//  Copyright © 2015 SPECURE GmbH. All rights reserved.
//

import UIKit

///
class RMBTTestTableViewCellM: UITableViewCell {

    ///
    @IBOutlet var titleLabel: UILabel!

    ///
    //@IBOutlet var valueLabel: UILabel!

    ///
    @IBOutlet var statusView: UIView!
    
    ///
    var checkView: RMBTUICheckmarkView?

    ///
    let label = UILabel()

    ///
    var isCellFinished = false

    //

    ///
    override func awakeFromNib() {
        super.awakeFromNib()

        accessoryView = nil
        accessoryType = .none

        titleLabel.textColor = INITIAL_SCREEN_TEXT_COLOR
        label.textColor = INITIAL_SCREEN_TEXT_COLOR
        //valueLabel.textColor = INITIAL_SCREEN_TEXT_COLOR
    }

    ///
    func assignFinalValue(value: String) {
        statusView.removeFromSuperview()

        let check = RMBTUICheckmarkView(frame: statusView.frame)
        check.lineColor = UIColor.white

        addSubview(check)

        //var _label = UILabel()
        label.frame         = CGRect(x: 0, y: 0, width: boundsWidth / 2 - 20, height: boundsHeight)
        //label.textColor     = INITIAL_SCREEN_TEXT_COLOR ?? UIColor.whiteColor()
        label.textAlignment = NSTextAlignment.right
        label.font          = UIFont(name: MAIN_FONT, size: 13.0)
        label.text          = value

        self.accessoryView = label
    }

    ///
    func assignResultValue(value: String, final: Bool) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                if self.accessoryView == nil {

                    self.label.frame         = CGRect(x: 0, y: 0, width: self.boundsWidth/2 - 20, height: self.boundsHeight)
                    //self.label.textColor     = INITIAL_SCREEN_TEXT_COLOR ?? UIColor.whiteColor()
                    self.label.textAlignment = NSTextAlignment.right
                    self.label.font          = UIFont(name: MAIN_FONT, size: 13.0)
                    //
                    self.accessoryView  = self.label
                }

                self.label.text = value

                if final && !self.isCellFinished {

                    self.isCellFinished = true

                    self.statusView.removeFromSuperview()

                    self.checkView = RMBTUICheckmarkView(frame: self.statusView.frame)
                    self.checkView!.lineColor = INITIAL_SCREEN_TEXT_COLOR

                    self.addSubview(self.checkView!)

    //                self.layer.removeAllAnimations()
    //
    //                UIView.animateWithDuration(0.3, animations: {
    //                    self.label.transform = CGAffineTransformScale(self.label.transform, 1.3, 1.3)
    //                    }, completion: { finished in
    //                        self.label.transform = CGAffineTransformIdentity
    //                })
                }
            }
        }
    }
    
    func resetSubviews() {
        
        self.isCellFinished = false
        
        if let check = self.checkView {
            
            self.checkView?.removeFromSuperview()
            
            self.statusView = RMBTProgressView(frame: check.frame)
            self.addSubview(self.statusView)
        }
    }
}
