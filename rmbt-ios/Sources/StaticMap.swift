/*****************************************************************************************************
 * Copyright 2014-2016 SPECURE GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *****************************************************************************************************/

import Foundation

///
class StaticMap {

    ///
    private static let staticMapsBaseUrl = "http://maps.googleapis.com/maps/api/staticmap?sensor=false"

    ///
    class func requestStaticMapImage(_ lat: Double, lon: Double, width: Int, height: Int, zoom: Int, completionHandler: @escaping (_ image: UIImage?) -> Void ) {
        if let url = URL(string: "\(staticMapsBaseUrl)&center=\(lat)+\(lon)&zoom=\(zoom)&size=\(width)x\(height)") {
            let dataTask = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: url) { (data, _, _) in
                if let data = data {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        completionHandler(image)
                    }
                } else {
                    DispatchQueue.main.async {
                        completionHandler(nil)
                    }
                }
            }
            dataTask.resume()
        } else {
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }

    ///
    class func getStaticMapImageWithCenteredMarker(_ lat: Double, lon: Double, width: Int, height: Int, zoom: Int, markerLabel: String, completionHandler: @escaping (_ image: UIImage?) -> Void ) {
        if let url = URL(string: "\(staticMapsBaseUrl)&center=\(lat)+\(lon)&zoom=\(zoom)&size=\(width)x\(height)&markers=color:blue%7Clabel:\(markerLabel)%7C\(lat)+\(lon)") {
            let dataTask = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: url) { (data, _, _) in
                if let data = data {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        completionHandler(image)
                    }
                } else {
                    DispatchQueue.main.async {
                        completionHandler(nil)
                    }
                }
            }
            dataTask.resume()
        } else {
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
}
