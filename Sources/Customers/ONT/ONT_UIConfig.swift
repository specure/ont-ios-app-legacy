//
//  UIConfig.swift
//  RMBT
//
//  Created by Benjamin Pucher on 05.10.15.
//  Copyright © 2015 SPECURE GmbH. All rights reserved.
//

import Foundation

///////////////////////////////
// MARK: Colors
///////////////////////////////

let RMBT_DARK_COLOR     = UIColor.white
let RMBT_TINT_COLOR     = UIColor(rgb: 0x00ABE7)

///
let RMBT_BAR_STATUS_TINT_COLOR = UIStatusBarStyle.default

/// initial view background (incl. gradient)
let INITIAL_VIEW_BACKGROUND_COLOR           = UIColor.white
let INITIAL_BOTTOM_VIEW_BACKGROUND_COLOR    = UIColor.white

let INITIAL_VIEW_USE_GRADIENT = true

let INITIAL_VIEW_GRADIENT_TOP_COLOR     = UIColor(rgb: 0x2F4867)
let INITIAL_VIEW_GRADIENT_BOTTOM_COLOR  = UIColor(rgb: 0x6D829D)

let INITIAL_VIEW_FEATURE_VIEWS_BACKGROUND_COLOR = UIColor.clear

let INITIAL_VIEW_TRAFFIC_LOW_COLOR = UIColor.lightGray
let INITIAL_VIEW_TRAFFIC_HIGH_COLOR = RMBT_TINT_COLOR

let INITIAL_BACKGROUND_IMAGE = UIImage(named: "app_bckg")
//

let INITIAL_SCREEN_TEXT_COLOR = RMBT_TINT_COLOR

let PROGRESS_INDICATOR_FILL_COLOR = UIColor.black

/// start button
let TEST_START_BUTTON_TEXT_COLOR                = UIColor(rgb: 0x2F4867)
let TEST_START_BUTTON_BACKGROUND_COLOR          = UIColor(rgb: 0xAAC0E9)
let TEST_START_BUTTON_DISABLED_BACKGROUND_COLOR = UIColor(rgb: 0x555555)
let TEST_START_BUTTON_HIGHLIGHTED_BACKGROUND_COLOR = UIColor(rgb: 0x78A29B)

let TEST_BACKGROUND_STYLE_LIGHT = false

let TEST_GAUGE_TINT_COLOR: UIColor? = RMBT_TINT_COLOR
//
let TEST_GAUGE_TINT_COLOR_PROGRESS: UIColor? = RMBT_TINT_COLOR
//
let MAP_MARKER_ICON_COLOR =  RMBT_TINT_COLOR // UIColor(red: 0.510, green: 0.745, blue: 0.984, alpha: 1)
let TEST_RESULTS_BUTTON_TEXT_COLOR          = UIColor.white
//

let NAVIGATION_SELECTED_BACKGROUND_VIEW_COLOR: UIColor? = UIColor(rgb: 0x22242C)
let NAVIGATION_BACKGROUND_COLOR = RMBT_TINT_COLOR // UIColor(rgb: 0x0F1012)
let NAVIGATION_TEXT_COLOR = UIColor.white // UIColor(rgb: 0x45484E)

let NAVIGATION_USE_TINT_COLOR = true

let TEST_BACKGROUND_COLOR = UIColor(rgb: 0x22242C)
let TEST_TABLE_BACKGROUND_COLOR = UIColor.clear //UIColor(rgb: 0x0C0A22)

let NAVIGATION_BAR_TEXT_COLOR    = RMBT_TINT_COLOR
let TEXT_MEDIUM_COLOR   = UIColor(rgb: 0xB6B6B6)
let FRAMES_LINES_COLOR  = UIColor(rgb: 0xABADB0)

let RMBT_RESULT_TEXT_COLOR   = UIColor(rgb: 0x1E368C)
let RMBT_CHECK_CORRECT_COLOR   = UIColor(rgb: 0x183285)
let RMBT_CHECK_MEDIOCRE_COLOR  = UIColor(rgb: 0xFECB1D)
let RMBT_CHECK_UPLOAD_MEDIOCRE_COLOR  = UIColor(rgb: 0x4354C4)
let RMBT_CHECK_DOWNLOAD_MEDIOCRE_COLOR  = UIColor(rgb: 0x4BF876)
let RMBT_CHECK_INCORRECT_COLOR = UIColor(rgb: 0xAE0E0E)

let COLOR_GRAY          = UIColor(rgb: 0x555555)
let COLOR_GRAY_HISTORY  = UIColor(rgb: 0x555555) // ?
let COLOR_HEADER_HISTORY  = UIColor.white
let COLOR_SUBHEADER_HISTORY = UIColor(white: 0.98, alpha: 1.0)
let COLOR_OTHER_BACKGROUNDS_HISTORY = UIColor(white: 0.96, alpha: 1.0)
let COLOR_OTHER_TEXT_HISTORY = UIColor(white: 0.13, alpha: 1.0)

let PROGRESS_COLOR      = UIColor(rgb: 0xAAC0E9)

///////////////////////////////
// MARK: Font options
///////////////////////////////

let MAIN_FONT = "LaoSangamMN"

let RMBTConfigurationIdentifier: RMBTConfigFabric.Idenitifier = .ont
