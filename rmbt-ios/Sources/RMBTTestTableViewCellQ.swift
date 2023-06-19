//
//  RMBTTestTableViewCell_Q.swift
//  RMBT
//
//  Created by Tomáš Baculák on 29/01/15.
//  Copyright © 2015 SPECURE GmbH. All rights reserved.
//

import UIKit

///
class RMBTTestTableViewCellQ: UITableViewCell {

    ///
    @IBOutlet var titleLabel: UILabel!

    ///
    @IBOutlet var statusView: UIView!

    //

    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    ///
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    ///
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    ///
    func commonInit() {
        // Load xib file
        guard let nibView = Bundle.main.loadNibNamed("RMBTTestTableViewCell_Q", owner: self, options: nil)![0] as? UITableViewCell
            else {
            return
        }

        //nibView.frame = self.frame
        nibView.frame = CGRect(x: 0, y: 0, width: 320, height: 30)

        nibView.backgroundColor = TEST_TABLE_BACKGROUND_COLOR

        titleLabel.textColor = INITIAL_SCREEN_TEXT_COLOR

        addSubview(nibView)
    }

    ///
    func aTestDidStart() {

    }

    ///
    func aTestDidFinish() {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.statusView.removeFromSuperview()

                let check = RMBTUICheckmarkView(frame: self.statusView.frame)
                check.lineColor = INITIAL_SCREEN_TEXT_COLOR

                self.addSubview(check)
            }
        }
    }
}
