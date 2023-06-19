//
//  RMBTGoogleMap.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 9/24/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class RMBTGoogleMap: RMBTMapProtocol {
    
    private var tileSize: Int!
    private var pointDiameterSize: Int!
    
    internal var mapView: GMSMapView!
    
    private var mapMarker: GMSMarker!
    
    private var mapLayerHeatmap: GMSTileLayer!
    private var mapLayerPoints: GMSTileLayer?
    private var mapLayerRegions: GMSTileLayer!
    private var mapLayerMunicipality: GMSTileLayer!
    private var mapLayerSettlements: GMSTileLayer!
    private var mapLayerWhitespots: GMSTileLayer!
    
    override func setupMapView() {
        var cam = GMSCameraPosition.camera(withLatitude: RMBT_MAP_INITIAL_LAT,
                                           longitude: RMBT_MAP_INITIAL_LNG,
                                           zoom: RMBT_MAP_INITIAL_ZOOM)
        
        // If test coordinates were provided, center map at the coordinates:
        if let initialLocation = self.initialLocation {
            cam = GMSCameraPosition.camera(withLatitude: initialLocation.coordinate.latitude,
                                           longitude: initialLocation.coordinate.longitude,
                                           zoom: RMBT_MAP_POINT_ZOOM)
        } else {
            // Otherwise, see if we have user's location available...
            if let location = RMBTLocationTracker.sharedTracker.location {
                // and if yes, then show it on the map
                cam = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                               longitude: location.coordinate.longitude,
                                               zoom: RMBT_MAP_INITIAL_ZOOM)
            }
        }
        
        mapView = GMSMapView.map(withFrame: view.bounds, camera: cam)
        if RMBTSettings.sharedSettings.isDarkMode == true,
            let mapStyleJsonUrl = Bundle.main.url(forResource: "DarkModeGoogleMap", withExtension: "json") {
            mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: mapStyleJsonUrl)
        }
        mapView.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleHeight, .flexibleWidth]
        
        mapView.isMyLocationEnabled = true
        
        mapView.settings.myLocationButton = false
        mapView.settings.compassButton = true
        mapView.settings.rotateGestures = true
        mapView.settings.tiltGestures = false
        mapView.settings.consumesGesturesInView = false
        
        mapView.delegate = self
        
        tileSize = Int(kTileSizePoints)
        pointDiameterSize = Int(kPointDiameterSizePoints)
        
//        self.requestMapOptions()
//        self.setupToast()
        
        // If measurement coordinates were provided, show a blue untappable pin at those coordinates
        if let initialLocation = self.initialLocation {
            let marker = GMSMarker(position: initialLocation.coordinate)
            // Approx. HUE_AZURE color from Android
            marker.icon = GMSMarker.markerImage(with: MAP_MARKER_ICON_COLOR)
            marker.isTappable = false
            marker.map = mapView
        }
        
        self.view.addSubview(mapView)
        self.view.sendSubviewToBack(mapView)
    }
    
    override func setAllGesturesEnabled(_ isEnabled: Bool) {
        mapView?.settings.setAllGesturesEnabled(isEnabled)
    }
    
    override func setupMapLayers() {
        mapLayerHeatmap?.map = nil
        mapLayerHeatmap = GMSURLTileLayer { [weak self] (x: UInt, y: UInt, zoom: UInt) -> URL? in
            return MapServer.sharedMapServer.getTileUrlForMapOverlayType(RMBTMapOptionsOverlayHeatmap.identifier, x: x, y: y, zoom: zoom, params: self?.tileParamsDictionary)
        }
        
        mapLayerHeatmap.tileSize = tileSize
        mapLayerHeatmap.map = mapView
        mapLayerHeatmap.zIndex = 101
        
        //
        mapLayerPoints?.map = nil
        mapLayerPoints = GMSURLTileLayer { [weak self] (x: UInt, y: UInt, zoom: UInt) -> URL? in
            return MapServer.sharedMapServer.getTileUrlForMapOverlayType(RMBTMapOptionsOverlayPoints.identifier, x: x, y: y, zoom: zoom, params: self?.tileParamsDictionary)
        }
        
        mapLayerPoints?.tileSize = tileSize
        mapLayerPoints?.map = mapView
        mapLayerPoints?.zIndex = 102
        
        mapLayerRegions?.map = nil
        mapLayerRegions = GMSURLTileLayer { [weak self] (x: UInt, y: UInt, zoom: UInt) -> URL? in
            let tileParams = ["shapetype": RMBTMapOptionsOverlayRegions.identifier] as NSMutableDictionary
            if let params = self?.tileParamsDictionary {
                tileParams.addEntries(from: params)
            }
            
            return MapServer.sharedMapServer.getTileUrlForMapOverlayType(RMBTMapOptionsOverlayShapes.identifier, x: x, y: y, zoom: zoom, params: tileParams as? [String: Any])
        }
        
        mapLayerRegions.tileSize = tileSize
        mapLayerRegions.map = mapView
        mapLayerRegions.zIndex = 103
        
        mapLayerMunicipality?.map = nil
        mapLayerMunicipality = GMSURLTileLayer { [weak self] (x: UInt, y: UInt, zoom: UInt) -> URL? in
            let tileParams = ["shapetype": RMBTMapOptionsOverlayMunicipality.identifier] as NSMutableDictionary
            if let params = self?.tileParamsDictionary {
                tileParams.addEntries(from: params)
            }
            
            return MapServer.sharedMapServer.getTileUrlForMapOverlayType(RMBTMapOptionsOverlayShapes.identifier, x: x, y: y, zoom: zoom, params: tileParams as? [String: Any])
        }
        
        mapLayerMunicipality.tileSize = tileSize
        mapLayerMunicipality.map = mapView
        mapLayerMunicipality.zIndex = 104
        
        //
        mapLayerSettlements?.map = nil
        mapLayerSettlements = GMSURLTileLayer { [weak self] (x: UInt, y: UInt, zoom: UInt) -> URL? in
            let tileParams = ["shapetype": RMBTMapOptionsOverlaySettlements.identifier] as NSMutableDictionary
            if let params = self?.tileParamsDictionary {
                tileParams.addEntries(from: params)
            }
            
            return MapServer.sharedMapServer.getTileUrlForMapOverlayType(RMBTMapOptionsOverlayShapes.identifier, x: x, y: y, zoom: zoom, params: tileParams as? [String: Any])
        }
        
        mapLayerSettlements.tileSize = tileSize
        mapLayerSettlements.map = mapView
        mapLayerSettlements.zIndex = 105
        
        //
        mapLayerWhitespots?.map = nil
        mapLayerWhitespots = GMSURLTileLayer { [weak self] (x: UInt, y: UInt, zoom: UInt) -> URL? in
            let tileParams = ["shapetype": RMBTMapOptionsOverlayWhitespots.identifier] as NSMutableDictionary
            if let params = self?.tileParamsDictionary {
                tileParams.addEntries(from: params)
            }
            
            return MapServer.sharedMapServer.getTileUrlForMapOverlayType(RMBTMapOptionsOverlayShapes.identifier, x: x, y: y, zoom: zoom, params: tileParams as? [String: Any])
        }
        
        mapLayerWhitespots.tileSize = tileSize
        mapLayerWhitespots.map = mapView
        mapLayerWhitespots.zIndex = 106
    }
    
    private func deselectCurrentMarker() {
        if mapMarker != nil {
            mapMarker.map = nil
            mapView.selectedMarker = nil
            mapMarker = nil
        }
    }
    
    override func refresh() {
        if let tileParamsConvert = mapOptions?.paramsDictionary() {
            tileParamsDictionary = tileParamsConvert
            tileParamsDictionary["size"] = tileSize as AnyObject?
            tileParamsDictionary["point_diameter"] = pointDiameterSize as AnyObject?
        }
        
        updateLayerVisibility()
        
        mapLayerPoints?.clearTileCache()
        mapLayerHeatmap?.clearTileCache()
        mapLayerRegions?.clearTileCache()
        mapLayerMunicipality?.clearTileCache()
        mapLayerSettlements?.clearTileCache()
        mapLayerWhitespots?.clearTileCache()
        mapLayerHeatmap.clearTileCache()
        
        if let mapOptions = self.mapOptions {
            switch mapOptions.mapViewType {
            case .hybrid:       mapView.mapType = .hybrid
            case .satellite:    mapView.mapType = .satellite
            default:            mapView.mapType = .normal
            }
        }
    }
    // MARK: Layer visibility
    
    ///
    private func setLayer(_ layer: GMSTileLayer, hidden: Bool) {
        let state = (layer.map == nil)
        if state == hidden {
            return
        }
        
        layer.map = (hidden) ? nil : mapView
    }
    
    ///
    override func updateLayerVisibility() {
        if let overlay = mapOptions?.activeOverlay { // prevents EXC_BAD_INSTRUCTION happening sometimes because mapOptions are nil
            
            var heatmapVisible = false
            var pointsVisible = false
            
            var regionsVisible = false
            var municipalityVisible = false
            var settlementsVisible = false
            var whitespotsVisible = false
            
            if overlay.overlayIdentifier == RMBTMapOptionsOverlayPoints.identifier {
                pointsVisible = true
            } else if overlay.overlayIdentifier == RMBTMapOptionsOverlayHeatmap.identifier {
                heatmapVisible = true
            } else if overlay === RMBTMapOptionsOverlayAuto {
                if mapOptions?.activeType?.id.rawValue == "browser" {
                    // Shapes
                    //shapesVisible = true
                    //regionsVisible = true // TODO: is this correct?
                } else {
                    heatmapVisible = true
                }
                
                pointsVisible = (mapView.camera.zoom >= RMBT_MAP_AUTO_TRESHOLD_ZOOM)
                
            } else if overlay.overlayIdentifier == RMBTMapOptionsOverlayRegions.identifier {
                regionsVisible = true
            } else if overlay.overlayIdentifier == RMBTMapOptionsOverlayMunicipality.identifier {
                municipalityVisible = true
            } else if overlay.overlayIdentifier == RMBTMapOptionsOverlaySettlements.identifier {
                settlementsVisible = true
            } else if overlay.overlayIdentifier == RMBTMapOptionsOverlayWhitespots.identifier {
                whitespotsVisible = true
            } else {
                //NSParameterAssert(NO); // does not work when commented in, probably because of new google maps framework
                logger.debug("\(overlay)") // TODO: possible bug because overlay is now null
            }
            
            if let mapLayerHeatmap = mapLayerHeatmap {
                setLayer(mapLayerHeatmap, hidden: !heatmapVisible)
            }
            if let layerPoints = mapLayerPoints {
                setLayer(layerPoints, hidden: !pointsVisible)
            }
            
            if let layerRegions = mapLayerRegions {
                setLayer(layerRegions, hidden: !regionsVisible)
            }
            
            if let layerMunicipality = mapLayerMunicipality {
                setLayer(layerMunicipality, hidden: !municipalityVisible)
            }
            
            if let layerSettlements = mapLayerSettlements {
                setLayer(layerSettlements, hidden: !settlementsVisible)
            }
            
            if let layerWhitespots = mapLayerWhitespots {
                setLayer(layerWhitespots, hidden: !whitespotsVisible)
            }
        }
    }
    
    override func locateMe() {
        if RMBTLocationTracker.sharedTracker.location == nil {
            return
        }
        
        if let coord = mapView.myLocation?.coordinate {
            let camera = GMSCameraUpdate.setTarget(coord)
            mapView.animate(with: camera)
        }
    }
}

extension RMBTGoogleMap: GMSMapViewDelegate {
    // MARK: MapView delegate methods
    
    ///
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        // disabled, not sure why this logic is here
        //        if !USE_OPENDATA { // Tap on map point must not work if not using opendata
        //            return
        //        }
        
        // If we're not showing points, ignore this tap
        if mapLayerPoints?.map == nil {
            return
        }
        
        guard let mapOptions = self.mapOptions else { return }
        
        let params = mapOptions.markerParamsDictionary()
        MapServer.sharedMapServer.getMeasurementsAtCoordinate(coordinate, zoom: Int(mapView.camera.zoom), params: params, success: { [weak self] measurements in
            logger.debug("\(measurements)")
            
            guard let strongSelf = self else { return }
            strongSelf.deselectCurrentMarker()
            
            if let m = measurements.first {
                if let lat = m.latitude, let lon = m.longitude {
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    
                    var point = strongSelf.mapView.projection.point(for: coordinate)
                    point.y -= 180
                    
                    let camera = GMSCameraUpdate.setTarget(strongSelf.mapView.projection.coordinate(for: point))
                    strongSelf.mapView.animate(with: camera)
                    
                    strongSelf.mapMarker = GMSMarker(position: coordinate)
                    strongSelf.mapMarker.icon = UIImage.emptyMarkerImage()
                    strongSelf.mapMarker.userData = m
                    strongSelf.mapMarker.appearAnimation = .pop
                    strongSelf.mapMarker.map = strongSelf.mapView
                    strongSelf.mapView.selectedMarker = strongSelf.mapMarker
                } else {
                    
                    var point = strongSelf.mapView.projection.point(for: coordinate)
                    point.y -= 180
                    
                    let camera = GMSCameraUpdate.setTarget(strongSelf.mapView.projection.coordinate(for: point))
                    strongSelf.mapView.animate(with: camera)
                    
                    strongSelf.mapMarker = GMSMarker(position: coordinate)
                    strongSelf.mapMarker.icon = UIImage.emptyMarkerImage()
                    strongSelf.mapMarker.userData = m
                    strongSelf.mapMarker.appearAnimation = .pop
                    strongSelf.mapMarker.map = strongSelf.mapView
                    strongSelf.mapView.selectedMarker = strongSelf.mapMarker
                }
            }
            }, error: { error in
                logger.error("Error getting measurements at coordinate")
        })
    }
    
    ///
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if let markerObj = marker.userData as? SpeedMeasurementResultResponse {
            return RMBTMapCalloutView.calloutViewWithMeasurement(markerObj)
        }
        
        return nil
    }
    
    ///
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if let markerData = marker.userData as? SpeedMeasurementResultResponse {
            //logger.debug("\(markerData)")
            
            // if measurementUuid is there  -> show measurement in app (allow only on global map -> initialLocation == nil)
            if let measurementUuid = markerData.measurementUuid, /*markerData.highlight &&*/ initialLocation == nil { // highlight is a filter -> see MapServer...
                
                self.delegate?.mapViewShowMeasurementFromMap(measurementUuid)
                //TODO: Move outside
//                performSegue(withIdentifier: "show_own_measurement_from_map", sender: measurementUuid)
                
            } else if let openTestUuid = (marker.userData as? SpeedMeasurementResultResponse)?.openTestUuid { // else show open test result
                MapServer.sharedMapServer.getOpenTestUrl(openTestUuid, success: { [weak self] response in
                    logger.debug("url: \(String(describing: response))")
                    
                    if let url = response {
                        self?.delegate?.mapViewOpenTestUrl(url)
                        //TODO: Move outside
//                        self?.presentModalBrowserWithURLString(url)
                        
                    } else {
                        logger.debug("map open test uuid url is nil")
                    }
                })
            }
        }
    }
    
    ///
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        updateLayerVisibility() // TODO: this is sometimes triggered too fast, leading to EXC_BAD_INSTRUCTION inside of
        // updateLayerVisibility. mostly occurs on slow internet connections
    }
}
