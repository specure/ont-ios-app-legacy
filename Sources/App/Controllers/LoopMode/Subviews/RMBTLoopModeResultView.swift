//
//  RMBTLoopModeResultView.swift
//  RMBT_ONT
//
//  Created by Sergey Glushchenko on 7/29/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTLoopModeResultView: RMBTGradientView {

    @IBOutlet weak var rootView: UIView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var valueLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    
    var emptyBackgroundColor: UIColor = UIColor.clear
    var notEmptyBackgroundColor: UIColor = UIColor.clear
    var emptyTextColor: UIColor = UIColor.white
    var notEmptyTextColor: UIColor = UIColor.white
    var emptyValueTextColor: UIColor = UIColor.white
    var notEmptyValueTextColor: UIColor = UIColor.white
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initGradient()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initGradient()
    }
    
    override func initGradient() {
        super.initGradient()
        
        self.colors = [
            RMBTColorManager.tintPrimaryColor,
            RMBTColorManager.tintSecondaryColor
        ]
    }
    
    var isEmpty: Bool = false {
        didSet {
            self.applyColorScheme()
        }
    }
    
    func applyColorScheme() {
        self.rootView?.backgroundColor = isEmpty == true ? self.emptyBackgroundColor : self.notEmptyBackgroundColor
        self.titleLabel?.textColor = isEmpty == true ? self.emptyTextColor : self.notEmptyTextColor
        self.valueLabel?.textColor = isEmpty == true ? self.emptyValueTextColor : self.notEmptyValueTextColor
        self.subtitleLabel?.textColor = isEmpty == true ? self.emptyTextColor : self.notEmptyTextColor
        self.initGradient()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
}
