//
//  RMBTStaticPage.swift
//  RMBT
//
//  Created by Polina on 11.06.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import Foundation

protocol RMBTCmsPageProtocol {
    var id: String { get }
    var name: String { get }
    var content: String { get }
}

struct RMBTCmsPageTranslation : Codable, RMBTCmsPageProtocol {
    let id: String
    let name: String
    let content: String
    let language: String
}

struct RMBTCmsPage : Codable, RMBTCmsPageProtocol {
    let id: String
    let name: String
    let content: String
    
    var translations: [RMBTCmsPageTranslation] = []
}
