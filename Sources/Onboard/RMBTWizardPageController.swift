//
//  RMBTWizardPageController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 10/13/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTWizardPageController: UIViewController {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var subtitleTextview: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    @IBOutlet weak var statusSwitch: UISwitch!
    @IBOutlet weak var switchTitle: UILabel!
    @IBOutlet weak var switchView: UIView!
    
    private var actionHandler: (_ vc: RMBTWizardPageController, _ index: Int) -> Void = { _, _ in }
    
    var buttonsTitles: [String] = []
    
    var titleText: String = "" {
        didSet {
            if self.isViewLoaded {
                self.titleLabel.text = titleText
            }
        }
    }
    
    var subtitle: NSAttributedString? = NSAttributedString() {
        didSet {
            if self.isViewLoaded {
                self.subtitleTextview.attributedText = subtitle
            }
        }
    }
    
    var icon: UIImage? {
        didSet {
            if self.isViewLoaded {
                self.iconImageView.image = icon
            }
        }
    }
    
    var isShowStatus: Bool = false
    var status: Bool = false
    var statusTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel.text = self.titleText
        self.subtitleTextview.attributedText = self.subtitle
        self.iconImageView.image = self.icon
        self.subtitleTextview.delegate = self
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        self.setButtons(titles: self.buttonsTitles, actionHandler: self.actionHandler)
        
        self.switchView.isHidden = !self.isShowStatus
        self.statusSwitch.isOn = self.status
        self.switchTitle.text = self.statusTitle
        self.statusSwitch.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
    }

    func setButtons(titles: [String], actionHandler: @escaping (_ vc: RMBTWizardPageController, _ index: Int) -> Void) {
        self.actionHandler = actionHandler
        self.buttonsTitles = titles
        
        if self.isViewLoaded {
            for view in self.buttonsStackView.subviews {
                view.removeFromSuperview()
            }
            
            for (index, title) in titles.enumerated() {
                let button = self.button(with: title)
                button.tag = index
                self.buttonsStackView.addArrangedSubview(button)
            }
        }
    }
    
    func button(with title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(RMBTColorManager.tintColor, for: .normal)
        button.addTarget(self, action: #selector(buttonDidClick(_:)), for: .touchUpInside)
        return button
    }
    
    @objc func buttonDidClick(_ sender: UIButton) {
        self.actionHandler(self, sender.tag)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func applyColorScheme() {
        self.view.backgroundColor = RMBTColorManager.background
        self.titleLabel.textColor = RMBTColorManager.tintColor
        self.subtitleTextview.textColor = RMBTColorManager.tintColor
        self.view.tintColor = RMBTColorManager.tintColor
        self.switchTitle.textColor = RMBTColorManager.tintColor
        
        self.statusSwitch.tintColor = RMBTColorManager.switchBackgroundColor
        self.statusSwitch.onTintColor = RMBTColorManager.tintColor
        self.statusSwitch.thumbTintColor = RMBTColorManager.thumbTintColor
        self.statusSwitch.backgroundColor = RMBTColorManager.switchBackgroundColor
        self.statusSwitch.layer.cornerRadius = self.statusSwitch.frame.size.height / 2
    }
    
    func showTos() {
        if let tos = UIStoryboard.tos() {
            self.present(tos, animated: true, completion: nil)
        }
    }
}

extension RMBTWizardPageController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.scheme == "segue" {
            if URL.host == "privacy" {
                self.showTos()
            }
        }
        return false
    }
}
