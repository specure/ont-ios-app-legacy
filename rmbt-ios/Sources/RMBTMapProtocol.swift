//
//  RMBTMapProtocol.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 9/24/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit
import CoreLocation

class RMBTMapProtocol: NSObject {
    var mapOptions: RMBTMapOptions?
    var tileParamsDictionary: [String: Any] = [:]
    var initialLocation: CLLocation?
    
    var view: UIView!
    
    var currentMapView: UIView? { return nil }
    
    weak var delegate: RMBTMapControllerDelegate?
    
    func setupMapView() { }
    
    func setupMapLayers() { }
    
    func updateLayerVisibility() { }
    
    func refresh() { }
    
    func locateMe() { }
    
    func setAllGesturesEnabled(_ isEnabled: Bool) { }
}
