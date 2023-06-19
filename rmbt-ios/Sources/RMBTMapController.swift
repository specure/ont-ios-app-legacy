//
//  RMBTMapController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 9/24/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit
import CoreLocation

protocol RMBTMapControllerDelegate: AnyObject {
    func mapViewOpenTestUrl(_ url: String)
    func mapViewShowMeasurementFromMap(_ uuid: String)
}

class RMBTMapController: NSObject {

    enum MapType {
        case Google
        case MapBox
    }
    
    var mapView: UIView! {
        if let mapView = self.currentMap?.currentMapView {
            return mapView
        }
        return UIView()
    }
    
    var initialLocation: CLLocation? {
        didSet {
            self.currentMap?.initialLocation = initialLocation
        }
    }
    
    var currentMap: RMBTMapProtocol?
    
    weak var delegate: RMBTMapControllerDelegate? {
        didSet {
            self.currentMap?.delegate = delegate
        }
    }
    
    private let rootView: UIView
    private let type: MapType
    
    var mapOptions: RMBTMapOptions? {
        didSet {
            currentMap?.mapOptions = mapOptions
        }
    }
    
    init(with type: MapType, rootView: UIView, initialLocation: CLLocation?, mapOptions: RMBTMapOptions?) {
        self.rootView = rootView
        self.type = type
        self.initialLocation = initialLocation
        self.mapOptions = mapOptions
        
        switch type {
        case .Google:
            let googleMap = RMBTGoogleMap()
            googleMap.view = rootView
            googleMap.initialLocation = initialLocation
            googleMap.mapOptions = mapOptions
            googleMap.setupMapView()
            self.currentMap = googleMap
        case .MapBox:
            let mapBox = RMBTMapBox()
            mapBox.view = rootView
            mapBox.initialLocation = initialLocation
            mapBox.mapOptions = mapOptions
            mapBox.setupMapView()
            self.currentMap = mapBox
        }
    }
    
    func setupMapLayers() {
        self.currentMap?.setupMapLayers()
    }
    
    func updateLayerVisibility() {
        self.currentMap?.updateLayerVisibility()
    }
    
    func refresh() {
        self.currentMap?.refresh()
    }
    
    func locateMe() {
        self.currentMap?.locateMe()
    }
    
    func setAllGesturesEnabled(_ isEnabled: Bool) {
        self.currentMap?.setAllGesturesEnabled(isEnabled)
    }
}
