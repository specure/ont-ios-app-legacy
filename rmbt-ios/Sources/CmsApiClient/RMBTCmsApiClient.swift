//
//  RMBTCmsApiClient.swift
//  RMBT
//
//  Created by Polina on 11.06.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import Foundation

class RMBTCmsApiClient {
    
    let config = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)

    func getPage(route: String, completion: @escaping (RMBTCmsPageProtocol) -> Void ) {
        let url = URL(string: "\(config.RMBT_CMS_BASE_URL)/pages?_limit=1&menu_item.route=\(route)")
        var request = URLRequest(url: url!)
        request.setCMSHeaders()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let page = try JSONDecoder().decode(RMBTCmsPage.self, from: data)
                    if let translation = page.translations.first(where: { t in
                        return t.language == Locale.current.languageCode
                    }) {
                        completion(translation)
                    } else {
                        completion(page)
                    }
                } catch let parsingError {
                    print("Parsing error: \(parsingError)")
                }
            } else if let error = error {
                print("HTTP Request Failed \(error)")
            }
        }
        task.resume()
    }
}

extension URLRequest {
    mutating func setCMSHeaders() {
        let config = RMBTConfigFabric.config(with: RMBTConfigurationIdentifier)
        self.setValue("application/json", forHTTPHeaderField: "Content-Type")
        self.setValue(config.clientIdentifier, forHTTPHeaderField: "X-Nettest-Client")
    }
}
