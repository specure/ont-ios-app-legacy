//
//  RMBTConfigurationProtocol.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 12/26/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit
import CoreLocation

class RMBTConfigurationProtocol { 
    let RMBT_MAP_VIEW_TYPE_DEFAULT = RMBTMapOptionsMapViewType.standard
    let RMBT_MAP_TYPE = RMBTMapController.MapType.MapBox
    //let RMBT_MAPBOX_LIGHT_STYLE_URL = "mapbox://styles/specure/cjlntyonf43yu2rmhta6m153v"
    //let RMBT_MAPBOX_DARK_STYLE_URL = "mapbox://styles/specure/cjlntyonf43yu2rmhta6m153v"
    let RMBT_MAPBOX_LIGHT_STYLE_URL = "mapbox://styles/specure/cjmcg8jnhikaf2stah6dhxv3r"
    let RMBT_MAPBOX_DARK_STYLE_URL = "mapbox://styles/specure/cjmcg8b5rio3z2spa4g8jd3a1"
    let RMBT_MAPBOX_BASIC_STYLE_URL = "mapbox://styles/specure/cjmcgd7t0imrz2rl60yyrzfqm"
    let RMBT_MAPBOX_STREET_STYLE_URL = "mapbox://styles/specure/cjmcg7dpciewf2snxhxk8bhqk"
    let RMBT_MAPBOX_SATELLITE_STYLE_URL = "mapbox://styles/specure/cjmcg7spdike82rp4xzfcht6o"
    
    let RMBT_IS_USE_DARK_MODE = true
    // MARK: Fixed test parameters
    
    ///
    let RMBT_TEST_CIPHER = SSL_RSA_WITH_RC4_128_MD5
    
    ///
    let RMBT_TEST_SOCKET_TIMEOUT_S = 30.0
    
    let RMBT_TEST_LOOPMODE_ENABLE = true
    /// Maximum number of tests to perform in loop mode
    let RMBT_TEST_LOOPMODE_LIMIT = 100
    
    ///
    let RMBT_TEST_LOOPMODE_WAIT_BETWEEN_RETRIES_S = 5
    
    ///
    let RMBT_TEST_PRETEST_MIN_CHUNKS_FOR_MULTITHREADED_TEST = 4
    
    ///
    let RMBT_TEST_PRETEST_DURATION_S = 2.0
    
    ///
    let RMBT_TEST_PING_COUNT = 10
    
    /// In case of slow upload, we finalize the test even if this many seconds still haven't been received:
    let RMBT_TEST_UPLOAD_MAX_DISCARD_S = 1.0
    
    /// Minimum number of seconds to wait after sending last chunk, before starting to discard.
    let RMBT_TEST_UPLOAD_MIN_WAIT_S    = 0.25
    
    /// Maximum number of seconds to wait for server reports after last chunk has been sent.
    /// After this interval we will close the socket and finish the test on first report received.
    let RMBT_TEST_UPLOAD_MAX_WAIT_S    = 3
    
    /// Measure and submit speed during test in these intervals
    let RMBT_TEST_SAMPLING_RESOLUTION_MS = 250
    
    ///
    var RMBT_CONTROL_SERVER_PATH: String { return "/ControlServer/V2" }
    var RMBT_CONTROL_MEASUREMENT_SERVER_PATH: String { return "/ControlServer/V2" }
    
    ///
    var RMBT_MAP_SERVER_PATH: String { return "/MapServer" }
    
    // MARK: Default control server URLs
    
    var RMBT_CONTROL_MEASUREMENT_SERVER_URL: String {
        return "\(RMBT_URL_HOST)\(RMBT_CONTROL_MEASUREMENT_SERVER_PATH)"
    }
    var RMBT_CONTROL_SERVER_URL: String {
        return "\(RMBT_URL_HOST)\(RMBT_CONTROL_SERVER_PATH)"
    }
    var RMBT_CONTROL_SERVER_IPV4_URL: String {
        return "\(RMBT_IPV4_URL_HOST)\(RMBT_CONTROL_SERVER_PATH)"
    }
    var RMBT_CONTROL_SERVER_IPV6_URL: String {
        return "\(RMBT_IPV6_URL_HOST)\(RMBT_CONTROL_SERVER_PATH)"
    }
    var RMBT_CHECK_IPV4_URL: String {
        return "\(RMBT_IPV4_URL_HOST)\(RMBT_CONTROL_SERVER_PATH)/ip"
    }
    
    // MARK: - Other URLs used in the app
    
    #if DEBUG || TEST
//    var RMBT_URL_HOST: String { return "https://test.nettest.org" }
//    var RMBT_IPV4_URL_HOST: String { return "https://c01ipv4-test.nettest.org" }
//    var RMBT_IPV6_URL_HOST: String { return "https://c01ipv6-test.nettest.org" }
    var RMBT_URL_HOST: String { return "https://nettest.org" }
    var RMBT_IPV4_URL_HOST: String { return "https://c01ipv4.nettest.org" }
    var RMBT_IPV6_URL_HOST: String { return "https://c01ipv6.nettest.org" }

//    var RMBT_MAP_SERVER_URL: String { return "https://test.nettest.org\(RMBT_MAP_SERVER_PATH)" }
    var RMBT_MAP_SERVER_URL: String { return "https://nettest.org\(RMBT_MAP_SERVER_PATH)" }
    #else
    var RMBT_URL_HOST: String { return "https://nettest.org" }
    var RMBT_IPV4_URL_HOST: String { return "https://c01ipv4.nettest.org" }
    var RMBT_IPV6_URL_HOST: String { return "https://c01ipv6.nettest.org" }
    var RMBT_MAP_SERVER_URL: String { return "https://m01opendemo.nettest.org\(RMBT_MAP_SERVER_PATH)" }
    #endif
    
    ///
    let RMBT_VERSION_NEW = false
    
    let RMBT_IS_NEED_BACKGROUND = true
    
    /// Note: $lang will be replaced by the device language (de, en, sl, etc.)
    var RMBT_STATS_URL: String {
        return "\(RMBT_URL_HOST)/$lang/statistics?menu=false"
    }
    var RMBT_HELP_URL: String {
        return "\(RMBT_URL_HOST)/$lang/help?menu=false"
    }
    var RMBT_HELP_RESULT_URL: String {
        return "\(RMBT_URL_HOST)/$lang/help?menu=false"
    }
    
    var RMBT_PRIVACY_TOS_URL: String {
        return "\(RMBT_URL_HOST)/$lang/pp?menu=false"
    }
    
    var RMBT_ABOUT_WEB_URL: String {
        return "\(RMBT_URL_HOST)/$lang/about?menu=false"
    }
    
    var RMBT_TERMS_TOS_URL: String {
        return "\(RMBT_URL_HOST)/$lang/tc?menu=false"
    }
    let RMBT_IS_SHOW_TOS_ON_START = false
    
    //
    
    let RMBT_ABOUT_URL       = "https://nettest.org"
    var RMBT_PROJECT_URL: String {
        return RMBT_ABOUT_URL
    }
    let RMBT_PROJECT_EMAIL   = "feedback@nettest.org"
    
    let RMBT_REPO_URL        = "https://github.com/specure"
    let RMBT_DEVELOPER_URL   = "http://Martes-specure.com"
    
    /// Initial map center coordinates and zoom level
    let RMBT_MAP_INITIAL_LAT: CLLocationDegrees = 48.209209 // Stephansdom, Wien
    let RMBT_MAP_INITIAL_LNG: CLLocationDegrees = 16.371850
    
    let RMBT_MAP_INITIAL_ZOOM: Float = 12.0
    
    /// Zoom level to use when showing a test result location
    let RMBT_MAP_POINT_ZOOM: Float = 12.0
    
    /// In "auto" mode, when zoomed in past this level, map switches to points
    let RMBT_MAP_AUTO_TRESHOLD_ZOOM: Float = 12.0
    
    let RMBT_MAP_SKIP_RESPONSE_OPERATORS = true
    let RMBT_MAP_SHOW_INFO_POPUP = true
    // Google Maps API Key
    
    ///#warning Please supply a valid Google Maps API Key. See https://developers.google.com/maps/documentation/ios/start#the_google_maps_api_key
    let RMBT_GMAPS_API_KEY = "AIzaSyDCoFuxghaMIVOKEeGxeGInAiWo9A0iJL4"
    //let RMBT_ADMOB_API_KEY = "ca-app-pub-5609635504794066~6444425011"
    
    // MARK: Misc
    
    /// Current TOS version. Bump to force displaying TOS to users again.
    let RMBT_TOS_VERSION = 1
    
    ///////////////////
    
    let RMBT_SHOW_PRIVACY_POLICY = true
    let TEST_STORE_ZERO_MEASUREMENT = true
    let IS_SHOW_ADVERTISING = true
    let TEST_IPV6_ONLY = false
    let INFO_SHOW_OPEN_DATA_SOURCES = true
    
    let TEST_USE_PERSONAL_DATA_FUZZING = false
    
    // If set to false: Statistics is not visible, tap on map points doesn't show bubble, ...
    let USE_OPENDATA = false
    
    let SHOW_CITY_AT_POSITION_VIEW = true
    
    let RMBT_MAIN_COMPANY_FOR_DATA_SOURCES = "Specure GmbH"
    let RMBT_COMPANY_FOR_DATA_SOURCES = "Example"
    let RMBT_SITE_FOR_DATA_SOURCES = "Example.org"
    let RMBT_COUNTRY_FOR_DATA_SOURCES = "Example"
    let RMBT_URL_SITE_FOR_DATA_SOURCES = "https://www.example.org"
    let RMBT_TITLE_URL_SITE_FOR_DATA_SOURCES = "Example"
    
    var appName: String {
        return "Example"
    }
    
    let RMBT_IS_USE_BASIC_STREETS_SATELLITE_MAP_TYPE = true
    
    let RMBT_USE_OLD_SERVERS_RESPONSE = false
    
    var RMBT_VERSION: Int { return 2 }
    
    let RMBT_SHOW_PRIVACY_IN_SETTINGS = true
    
    let RMBT_WIZARD_PRIVACY_EMAIL = "gdpr.info@example.org"
    let RMBT_WIZARD_AGE_LIMITATION = "+16"
    let RMBT_IS_NEED_WIZARD = true
    
    var RMBT_SETTINGS_MODE: RMBTConfig.SettingsMode {
        return .remotely
    }
    
    let DEV_CODE = "0000000"
    
    var RMBT_DEFAULT_IS_CURRENT_COUNTRY: Bool {
        return true
    }
    
    var RMBT_USE_MAIN_LANGUAGE: Bool { return false }
    var RMBT_MAIN_LANGUAGE: String { return "en" }
    
    var clientIdentifier: String? { return "nt" }
    
    var RMBT_CMS_BASE_URL: String { return "https://example.org" }
    var RMBT_CMS_ABOUT_URL: String  { return "about" }
    var RMBT_CMS_PRIVACY_URL: String { return "privacy-policy" }
    var RMBT_CMS_TERMS_URL: String { return "terms-of-use" }
}
