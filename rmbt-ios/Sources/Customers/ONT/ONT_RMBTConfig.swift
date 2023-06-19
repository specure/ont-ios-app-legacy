//
//  RMBTConfig.swift
//  RMBT
//
//  Created by Tomáš Baculák on 14/01/15.
//  Copyright © 2015 SPECURE GmbH. All rights reserved.
//

// MARK: Fixed test parameters

import CoreLocation

let RMBT_MAP_VIEW_TYPE_DEFAULT = RMBTMapOptionsMapViewType.standard
let RMBT_MAP_TYPE = RMBTMapController.MapType.MapBox

let RMBT_MAPBOX_LIGHT_STYLE_URL = "mapbox://styles/specure/example"
let RMBT_MAPBOX_DARK_STYLE_URL = "mapbox://styles/specure/example"
let RMBT_MAPBOX_BASIC_STYLE_URL = "mapbox://styles/specure/example"
let RMBT_MAPBOX_STREET_STYLE_URL = "mapbox://styles/specure/example"
let RMBT_MAPBOX_SATELLITE_STYLE_URL = "mapbox://styles/specure/example"

let RMBT_IS_USE_DARK_MODE = false
///
let RMBT_TEST_CIPHER = SSL_RSA_WITH_RC4_128_MD5

///
let RMBT_TEST_SOCKET_TIMEOUT_S = 30.0

/// Maximum number of tests to perform in loop mode
let RMBT_TEST_LOOPMODE_LIMIT = 100

let RMBT_TEST_LOOPMODE_ENABLE = false
///
let RMBT_TEST_LOOPMODE_WAIT_BETWEEN_RETRIES_S = 5
let RMBT_TEST_LOOPMODE_WAIT_DISTANCE_RETRIES_S = 10.0

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

// MARK: Default control server URLs

#if DEBUG || TEST

let RMBT_CONTROL_SERVER_PATH = "/ControlServer/V2"
let RMBT_CONTROL_MEASUREMENT_SERVER_PATH = "/ControlServer/V2"
///
let RMBT_MAP_SERVER_PATH = "/MapServer"
///
let RMBT_URL_HOST = "https://customers.example.org"
let RMBT_CONTROL_SERVER_URL        = "https://customers.example.org\(RMBT_CONTROL_SERVER_PATH)"
let RMBT_CONTROL_SERVER_IPV4_URL   = "https://customers.example.org\(RMBT_CONTROL_SERVER_PATH)"
let RMBT_CONTROL_SERVER_IPV6_URL   = "https://customers.example.org\(RMBT_CONTROL_SERVER_PATH)"
let RMBT_CONTROL_MEASUREMENT_SERVER_URL        = "https://customers.example.org\(RMBT_CONTROL_MEASUREMENT_SERVER_PATH)"
let RMBT_MAP_SERVER_URL = "https://customers.example.org\(RMBT_MAP_SERVER_PATH)"
let RMBT_CHECK_IPV4_URL = "https://customers.example.org\(RMBT_CONTROL_SERVER_PATH)/ip"

#else
let RMBT_CONTROL_SERVER_PATH = "/ControlServer/V2"
let RMBT_CONTROL_MEASUREMENT_SERVER_PATH = "/ControlServer/V2"
///
let RMBT_MAP_SERVER_PATH = "/MapServer"
///
let RMBT_URL_HOST = "https://customers.example.org"
let RMBT_CONTROL_SERVER_URL        = "https://customers.example.org\(RMBT_CONTROL_SERVER_PATH)"
let RMBT_CONTROL_SERVER_IPV4_URL   = "https://customers.example.org\(RMBT_CONTROL_SERVER_PATH)"
let RMBT_CONTROL_SERVER_IPV6_URL   = "https://customers.example.org\(RMBT_CONTROL_SERVER_PATH)"
let RMBT_CONTROL_MEASUREMENT_SERVER_URL        = "https://customers.example.org\(RMBT_CONTROL_MEASUREMENT_SERVER_PATH)"
let RMBT_MAP_SERVER_URL = "https://customers.example.org\(RMBT_MAP_SERVER_PATH)"
let RMBT_CHECK_IPV4_URL = "https://customers.example.org\(RMBT_CONTROL_SERVER_PATH)/ip"
#endif

///
let RMBT_VERSION_NEW = false

let RMBT_IS_NEED_BACKGROUND = true

let RMBT_MAP_SHOW_INFO_POPUP = false
// MARK: - Other URLs used in the app

/// Note: $lang will be replaced by the device language (de, en, sl, etc.)
let RMBT_STATS_URL       = "\(RMBT_URL_HOST)/$lang/statistics?menu=false"
let RMBT_HELP_URL        = "\(RMBT_URL_HOST)/$lang/help?menu=false"
let RMBT_HELP_RESULT_URL = "\(RMBT_URL_HOST)/$lang/help?menu=false"

let RMBT_PRIVACY_TOS_URL = "\(RMBT_URL_HOST)/$lang/pp?menu=false"
let RMBT_TERMS_TOS_URL = "\(RMBT_URL_HOST)/$lang/tc?menu=false"
let RMBT_IS_SHOW_TOS_ON_START = true

let RMBT_ABOUT_URL       = "https://www.customers.example.org"
let RMBT_PROJECT_URL     = RMBT_URL_HOST
let RMBT_PROJECT_EMAIL   = "example@example.org"

let RMBT_REPO_URL        = "https://github.com/specure"
let RMBT_DEVELOPER_URL   = "https://specure.com"

// MARK: Map options

/// Initial map center coordinates and zoom level
let RMBT_MAP_INITIAL_LAT: CLLocationDegrees = 46.049053 // Slovenska cesta 15, 1000 Ljubljana, Slovenia
let RMBT_MAP_INITIAL_LNG: CLLocationDegrees = 14.501973

let RMBT_MAP_INITIAL_ZOOM: Float = 12.0

/// Zoom level to use when showing a test result location
let RMBT_MAP_POINT_ZOOM: Float = 12.0

/// In "auto" mode, when zoomed in past this level, map switches to points
let RMBT_MAP_AUTO_TRESHOLD_ZOOM: Float = 12.0

let RMBT_MAP_SKIP_RESPONSE_OPERATORS = false
// Google Maps API Key

///#warning Please supply a valid Google Maps API Key. See https://developers.google.com/maps/documentation/ios/start#the_google_maps_api_key
let RMBT_GMAPS_API_KEY = "EXAMPLE_KEY"

// MARK: Misc

/// Current TOS version. Bump to force displaying TOS to users again.
let RMBT_TOS_VERSION = 1

///////////////////
let RMBT_SHOW_PRIVACY_POLICY = true

let TEST_STORE_ZERO_MEASUREMENT = true
let IS_SHOW_ADVERTISING = false
let TEST_IPV6_ONLY = false
let INFO_SHOW_OPEN_DATA_SOURCES = false

let TEST_USE_PERSONAL_DATA_FUZZING = true

// If set to false: Statistics is not visible, tap on map points doesn't show bubble, ...
let USE_OPENDATA = true

let RMBT_USE_OLD_SERVERS_RESPONSE = false
let SHOW_CITY_AT_POSITION_VIEW = true

let RMBT_MAIN_COMPANY_FOR_DATA_SOURCES = "Specure GmbH"
let RMBT_COMPANY_FOR_DATA_SOURCES = "Example"
let RMBT_SITE_FOR_DATA_SOURCES = "example.org"
let RMBT_COUNTRY_FOR_DATA_SOURCES = "Example"
let RMBT_URL_SITE_FOR_DATA_SOURCES = "https://www.example.org"
let RMBT_TITLE_URL_SITE_FOR_DATA_SOURCES = "Example"

let RMBT_IS_USE_BASIC_STREETS_SATELLITE_MAP_TYPE = false

let RMBT_VERSION = 2

let RMBT_SHOW_PRIVACY_IN_SETTINGS = true

let RMBT_WIZARD_PRIVACY_EMAIL = "gdpr.info@example.org"
let RMBT_WIZARD_AGE_LIMITATION = "+16"
let RMBT_IS_NEED_WIZARD = false

let RMBT_SETTINGS_MODE = RMBTConfig.SettingsMode.urlsLocally

let DEV_CODE = "00000000"
