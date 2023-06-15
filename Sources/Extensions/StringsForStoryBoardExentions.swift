//
//  File.swift
//  RMBT
//
//  Created by Tomas Baculák on 19/12/2016.
//  Copyright © 2016 SPECURE GmbH. All rights reserved.
//

import Foundation

extension UINavigationItem {
    
    //
    func formatInfoPageTitle() {
        self.title = L("RMBT-NI-INFO")
    }
    
    //
    //
    func formatHistoryResultPageTitle() {
        self.title = L("RMBT-NI-HISTORY-TESTRESULT")
    }
    
    //
    func formatHistoryResultPageDetailTitle() {
        self.title = L("RMBT-NI-HISTORY-DETAILS")
    }
}

extension UISegmentedControl {
    
    //
    func formatStringsMapOptions() {
        if RMBT_IS_USE_BASIC_STREETS_SATELLITE_MAP_TYPE {
            setTitle(L("RMBT-MAP-BASIC"), forSegmentAt: 0)
            setTitle(L("RMBT-MAP-STREETS"), forSegmentAt: 1)
            setTitle(L("RMBT-MAP-SATELLITE"), forSegmentAt: 2)
        } else {
            setTitle(L("RMBT-MAP-STANDARD"), forSegmentAt: 0)
            setTitle(L("RMBT-MAP-SATELLITE"), forSegmentAt: 1)
            setTitle(L("RMBT-MAP-HYBRID"), forSegmentAt: 2)
        }
    }
}

extension UIToolbar {

    //
    func formatStringAgreementOptions() {
    
        items![1].title = L("RBMT-BASE-DECLINE")
        items![3].title = L("RBMT-BASE-AGREE")
    }
    
    //
    func formatStringPersonalDataAgreementOptions() {
        
        items![1].title = L("RBMT-BASE-CONTINUE")
    }
}

extension UITableViewHeaderFooterView {

    class func formatSettingsHeader(_ ip: Int) -> UITableViewHeaderFooterView {
        let view = formatGenericHeader()
        
        switch ip {
        case 1: view.textLabel!.formatStringNerdMode()
        default:
            break
        }
        
        return view
    }
    
    class func formatSettingsFooter(_ ip: Int) -> UITableViewHeaderFooterView {
        let view = formatGenericFooter()
        
        switch ip {
        case 0: view.textLabel?.formatStringAnonymousModeDescription()
        case 1: view.textLabel?.formatStringNerdModeDescription()
        case 2: view.textLabel?.formatStringDevelopersSettingDescription()
        
        default:
            break
        }
        
        return view
    }
    
    class func formatNMSettingsHeader(_ ip: Int) -> UITableViewHeaderFooterView {
        let view = formatGenericHeader()
        
        switch ip {
        case 0: view.textLabel?.formatStringGeneral()
        case 1: view.textLabel?.formatStringQualityOfService()
            
        default:
            break
        }
        
        return view
    }
    
    class func formatNMSettingsFooter(_ ip: Int) -> UITableViewHeaderFooterView {
        let view = formatGenericFooter()
        
        switch ip {
        case 1: view.textLabel?.formatStringQualityOfServiceDesctiption()
            
        default:
            break
        }
        
        return view
    }
    
    // Helpers
    private class func formatGenericFooter() -> UITableViewHeaderFooterView {
        let view = UITableViewHeaderFooterView()
            view.frame = CGRect(x: 0, y: 0, width: 320, height: 95)
        return view
    }
    
    private class func formatGenericHeader() -> UITableViewHeaderFooterView {
        let view = UITableViewHeaderFooterView()
            view.frame = CGRect(x: 0, y: 0, width: 320, height: 35) // TODO:
        return view
    }
}

extension String {

    // Settings NKOM
    mutating func formatStringSettings() { self = L("RMBT-NI-SETTINGS") }
    
    // Nerd mode settings
    mutating func formatStringNerdModeSetting() { self = L("RMBT-SETTINGS-NERDMODESETTINGS") }
    
    // Developer settings
    mutating func formatStringDeveloperSettings() { self = L("RMBT-SETTINGS-DEVELOPERSETTINGS") }
    
    // Terms and Conditions
    //mutating func formatStringPrivacyAndPolicy() { self = L("RMBT-INFO-PRIVACYPOLICY") }
    static func formatStringPrivacyAndPolicy() -> String {
        return String.localizedStringWithFormat(L("RMBT-INFO-PRIVACYPOLICY"), RMBTAppTitle())
    }
    
    static func formatStringOnlyPrivacyAndPolicy() -> String {
        return String.localizedStringWithFormat(L("RMBT-INFO-ONLY-PRIVACYPOLICY"))
    }
    
    static func formatStringTermAndConditions() -> String {
        return String.localizedStringWithFormat(L("RMBT-INFO-TERMS-AND-CONDITIONS"))
    }
    
    // Publish personal data
    static func formatStringPublishPersonalData() -> String {
        return String.localizedStringWithFormat(L("RMBT-INFO-PUBLISH-PERSONAL-DATA"), RMBTAppTitle())
    }
    ///
    //
    static func formatStringAgreementText() -> String {
        return String.localizedStringWithFormat(L("RBMT-BASE-AGREEMENT"), RMBTAppTitle())
    }
    
    static func formatStringAgreementTermsText() -> String {
        return String.localizedStringWithFormat(L("RBMT-BASE-AGREEMENT-TERMS-AND-CONDITIONS"), RMBTAppTitle())
    }
    
    static func formatStringAgreementPrivacyPolicyText() -> String {
        return String.localizedStringWithFormat(L("RBMT-BASE-AGREEMENT-PRIVACY-POLICY"), RMBTAppTitle())
    }
    
    static func formatStringDataSourcesText() -> String {
        return String.localizedStringWithFormat(L("info.text.open_data_sources_notice"), RMBT_SITE_FOR_DATA_SOURCES, RMBTAppTitle(), RMBT_COUNTRY_FOR_DATA_SOURCES)
    }
    
    //
    static func formatStringPublishPersonalDataAgreementText() -> String {
        return String.localizedStringWithFormat(L("RBMT-PERSONAL-DATA-AGREEMENT"), RMBTAppTitle())
    }
    
    // make two lines instead of one
    mutating func adjustStringForTwoLines() {
        self = self.replacingOccurrences(of: " ", with: "\n")
    }
    
    static func formatStringsMenu(_ tag: Int) -> String {
        switch tag {
        case 0: return formatStringHome()
        case 1: return formatStringHistory()
        case 2: return formatStringMaps()
        case 3: return formatStringStatistics()
        case 5: return formatStringSurvey()
        case 6: return formatStringHelp()
        default: break
        }
        
        return ""
    }
    
    // Helpers
    ////////////////
    // Menu
    fileprivate static func formatStringHome() -> String { return L("RMBT-NI-HOME") }
    fileprivate static func formatStringHistory() -> String { return L("RMBT-NI-HISTORY") }
    fileprivate static func formatStringMaps() -> String { return L("RMBT-NI-MAPS") }
    fileprivate static func formatStringStatistics() -> String { return L("RMBT-NI-STATISTICS") }
    fileprivate static func formatStringHelp() -> String { return L("RMBT-NI-HELP") }
    fileprivate static func formatStringSurvey() -> String { return L("RMBT-NI-SURVEY") }
}

extension UILabel {
    
    ///
    //
    func formatStringIpv4only() { text = L("RMBT-SETTINGS-IPV4ONLY") }
    func formatStringIpv6only() { text = L("RMBT-SETTINGS-IPV6ONLY") }
    func formatStringEnableQosMeasurements() { text = L("RMBT-SETTINGS-ENABLEQOSMEASUMENTS") }
    func formatStringEnablePublishPersonalData() { text = L("RMBT-SETTINGS-ENABLEPUBLISHPERSONALDATA") }
    func formatStringEnableSubmitZeroTesting() { text = L("RMBT-SETTINGS-ENABLESUBMITZEROTESTING") }
    
    ////////////////
    // Main
    func formatStringPing() {
        text = L("RMBT-HOME-PING")
        
        if var t = text {
            t.adjustStringForTwoLines()
            text = t
        }
    }
    //
    func formatStringDownloadMBPS() {
        text = L("RMBT-HOME-DOWNLOADMBPS")
        
        if var t = text {
            t.adjustStringForTwoLines()
            text = t
        }
    }
    //
    func formatStringUploadMBPS() {
        text = L("RMBT-HOME-UPLOADMBPS")
        
        if var t = text {
            t.adjustStringForTwoLines()
            text = t
        }
    }
    //
    func formatStringStart() { text = L("RMBT-HOME-START") }
    func formatStringStartAgain() { text = L("RMBT-HOME-STARTAGAIN") }
    
    //
    func formatStringsMenu(_ ip: Int) {
        self.text = String.formatStringsMenu(ip)
    }
    
    // Helpers
    ////////////////
    // Settings
    fileprivate func formatStringEnableNerdMode() { text = L("RMBT-SETTINGS-ENABLENERDMODE") }
    fileprivate func formatStringAnonymousMode() { text = L("RMBT-SETTINGS-ANONYMOUSMODE") }
    fileprivate func formatStringDeveloperSettings() { text = L("RMBT-SETTINGS-DEVELOPERSETINGS") }
    fileprivate func formatStringAdvancedSettings() { text = L("RMBT-SETTINGS-ADVANCEDSETTINGS") }
    // headers
    fileprivate func formatStringNerdMode() { text = L("RMBT-SETTINGS-NERDMODE") }
    // footers
    fileprivate func formatStringAnonymousModeDescription() { text = L("RMBT-SETTINGS-ANONYMOUSMODEDESCRIPTION") }
    fileprivate func formatStringNerdModeDescription() { text = L("RMBT-SETTINGS-NERDMODEDESCRIPTION") }
    fileprivate func formatStringDevelopersSettingDescription() { text = L("RMBT-SETTINGS-DEVELOPERSSETTINGSDESCRIPTION") }
    
    func formatStringsSetting(_ ip: Int) {
        switch ip {
        case 0: formatStringAnonymousMode()
        case 1: formatStringEnableNerdMode()
        case 2: formatStringAdvancedSettings()
        case 3: formatStringDeveloperSettings()
        default: break
        }
    }
    ////////////////
    // Nerd Mode Settings
    // headers
    func formatStringsNMSettingsHeader(_ ip: Int) {
        ip == 0 ?formatStringGeneral():formatStringQualityOfService()
    }
    // ONT settings
    func formatStringsONTMSettingsHeader(_ ip: Int) {
        switch ip {
        case 0:
            formatStringGeneral()
        default:
            break
        }
    }
    // footers
    func formatStringsNMSettingsFooter(_ ip: Int) {
        if ip == 1 { formatStringQualityOfServiceDesctiption() }
    }
    
    // headers
    fileprivate func formatStringGeneral() { text = L("RMBT-SETTINGS-GENERAL") }
    fileprivate func formatStringQualityOfService() { text = L("RMBT-SETTINGS-QUALITYOFSERVICE") }
    // footers
    fileprivate func formatStringQualityOfServiceDesctiption() { text = L("RMBT-SETTINGS-QUALITYOFSERVICEDESCRIPTION") }
    // cells
    func formatStringsNMSettings(_ ip: Int) {
        switch ip {
        case 0:formatStringIpv4only()
        case 1:formatStringIpv6only()
        case 2:formatStringEnableQosMeasurements()
        case 3:formatStringEnablePublishPersonalData()
        case 4:formatStringEnableSubmitZeroTesting()
        default: break
        }
    }
    
    ////////////////
    // Info
    //
    func formatStringsInfo(_ ip: Int) {
        
        switch ip {
        case 0: formatStringWebSite()
        case 1: formatStringEmail()
        case 2: formatStringPrivacyPolicy()
        case 3: formatStringClientUUID()
        case 4: formatStringTestCount()
        case 5: formatStringVersion()
        case 6: formatStringControlServerVersion()
        case 7: formatStringDevelopedBy()
        case 8: formatStringSourceCode()
        case 9: formatStringLegalNotice()
        case 10: formatStringOnlyPrivacyPolicy()
        case 11: formatStringTermsAndConditions()
        default: break
        }
    }
    
    // Helpers
    fileprivate func formatStringWebSite() { text = L("RMBT-INFO-WEBSITE") }
    fileprivate func formatStringEmail() { text = L("RMBT-INFO-EMAIL") }
    fileprivate func formatStringPrivacyPolicy() { text = L("RMBT-INFO-PRIVACYPOLICY") }
    fileprivate func formatStringOnlyPrivacyPolicy() { text = L("RMBT-INFO-ONLY-PRIVACYPOLICY") }
    fileprivate func formatStringTermsAndConditions() { text = L("RMBT-INFO-TERMS-AND-CONDITIONS") }
    
    fileprivate func formatStringClientUUID() { text = L("RMBT-INFO-CLINETUUID") }
    fileprivate func formatStringTestCount() { text = L("RMBT-INFO-TESTCOUNT") }
    fileprivate func formatStringVersion() { text = L("RMBT-INFO-VERSION") }
    fileprivate func formatStringControlServerVersion() { text = L("RMBT-DEVSETTINGS-SEVERCONTROLVERSION") }
    
    fileprivate func formatStringDevelopedBy() { text = L("RMBT-INFO-DEVELOPEDBY") }
    fileprivate func formatStringSourceCode() { text = L("RMBT-INFO-SOURCECODE") }
    fileprivate func formatStringLegalNotice() { text = L("RMBT-INFO-LEGALNOTICE") }
    
}
