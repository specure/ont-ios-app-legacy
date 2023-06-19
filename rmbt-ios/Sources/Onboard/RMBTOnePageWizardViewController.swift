//
//  RMBTOnePageWizardViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 10/21/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTOnePageWizardViewController: UIViewController {

    private let showPrivacySegue = "show_privacy_segue"
    
    @IBOutlet weak var navBarView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ageButton: UIButton!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var essentialButton: UIButton!
    @IBOutlet weak var agreeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.delegate = self
        
        self.detailsButton.setTitleColor(RMBTColorManager.tintColor, for: .normal)
        self.ageButton.setTitle(RMBT_WIZARD_AGE_LIMITATION, for: .normal)
        self.detailsButton.setTitle(L("wizard.button.details"), for: .normal)
        self.agreeButton.setTitle(L("wizard.button.i_agree_to_all"), for: .normal)
        self.essentialButton.setTitle(L("wizard.button.essential_settings_only"), for: .normal)
        self.prepareText()
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
    }
    
    func prepareText() {
        let titleFont = UIFont.systemFont(ofSize: 20, weight: .regular)
        let titleColor = RMBTColorManager.tintColor
        
        let textFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        let textColor = RMBTColorManager.loopModeValueColor
        
        let title = "<br />" + "<center>" + String.localizedStringWithFormat(L("wizard.one_page.title"), RMBTAppTitle()) + "</center>" + "<br />"
        let privacyLink = "<a href='segue://privacy'>" + L("RMBT-INFO-PRIVACYPOLICY") + "</a>"
        let privacyEmail = "<a href='mailto:" + RMBT_WIZARD_PRIVACY_EMAIL + "'>" + RMBT_WIZARD_PRIVACY_EMAIL + "</a>"
        let titleDescription = String.localizedStringWithFormat(L("wizard.one_page.privacy_description"), privacyLink, privacyEmail) + "<br /><br />"
        
        let analyticsTitle = L("wizard.one_page.analytics_title") + "<br />"
        let analyticsDescription = L("wizard.one_page.analytics_description") + "<br /><br />"
        
        let persistentTitle = L("wizard.one_page.persistent_client_title") + "<br />"
        let persistentDescription = L("wizard.one_page.persistent_client_description") + "<br /><br />"
        
        let finishDescription = L("wizard.one_page.finish_description")
        
        let text = NSMutableAttributedString(attributedString: title.htmlAttributedString(font: titleFont, color: titleColor))
        text.append(titleDescription.htmlAttributedString(font: textFont, color: textColor))
        text.append(analyticsTitle.htmlAttributedString(font: textFont, color: titleColor))
        text.append(analyticsDescription.htmlAttributedString(font: textFont, color: textColor))
        text.append(persistentTitle.htmlAttributedString(font: textFont, color: titleColor))
        text.append(persistentDescription.htmlAttributedString(font: textFont, color: textColor))
        text.append(finishDescription.htmlAttributedString(font: textFont, color: textColor))
        
        self.textView.attributedText = text
        
        self.textView.tintColor = RMBTColorManager.tintColor
        self.textView.backgroundColor = RMBTColorManager.background
    }
    
    func applyColorScheme() {
        self.view.backgroundColor = RMBTColorManager.background
        self.scrollView.backgroundColor = RMBTColorManager.background
        self.agreeButton.backgroundColor = RMBTColorManager.tintColor
        self.agreeButton.setTitleColor(RMBTColorManager.buttonTitleColor, for: .normal)
        self.agreeButton.tintColor = RMBTColorManager.tintColor
        
        self.detailsButton.setTitleColor(RMBTColorManager.navigationBarTitleColor, for: .normal)
        
        self.ageButton.backgroundColor = RMBTColorManager.navigationBarTitleColor.withAlphaComponent(0.6)
        self.navBarView.backgroundColor = RMBTColorManager.navigationBarBackground
    }
    
    @IBAction func agreeButtonClick(_ sender: Any) {
        RMBTSettings.sharedSettings.isClientPersistent = true
        RMBTSettings.sharedSettings.isAnalyticsEnabled = true
        RMBTApplicationController.wizardDone()
        let delegate = UIApplication.shared.delegate as? RMBTAppDelegate
        delegate?.showMainScreen()
    }
    
    @IBAction func essentialButtonClick(_ sender: Any) {
        RMBTSettings.sharedSettings.isClientPersistent = false
        RMBTSettings.sharedSettings.isAnalyticsEnabled = false
        RMBTApplicationController.wizardDone()
        let delegate = UIApplication.shared.delegate as? RMBTAppDelegate
        delegate?.showMainScreen()
    }
    
    @IBAction func detailsButtonClick(_ sender: Any) {
        RMBTSettings.sharedSettings.isClientPersistent = false
        RMBTSettings.sharedSettings.isAnalyticsEnabled = false
        RMBTApplicationController.wizardDone()
        let delegate = UIApplication.shared.delegate as? RMBTAppDelegate
        delegate?.showSettingsScreen()
    }
    
    @IBAction func ageButtonClick(_ sender: Any) {
    }

    func showTos() {
        self.performSegue(withIdentifier: showPrivacySegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let configuration = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        if segue.identifier == showPrivacySegue {
            if let webVC = segue.destination as? RMBTStaticPageViewController {
                webVC.route = configuration.RMBT_CMS_PRIVACY_URL
            }
        }
    }
}

extension RMBTOnePageWizardViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.scheme == "segue" {
            if URL.host == "privacy" {
                self.showTos()
                return false
            }
        }
        return true
    }
}
