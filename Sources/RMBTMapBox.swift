//
//  RMBTMapBox.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 9/24/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit
//import GoogleMaps
import CoreLocation
import Mapbox

class RMBTMapBox: RMBTMapProtocol {
    
    private var tileSize: Int!
    private var pointDiameterSize: Int!
    
    internal var mapView: MGLMapView!
    
    private var mapMarker: MGLPointAnnotation!
    private var selectedMeasurement: SpeedMeasurementResultResponse?
    
    private var mapLayerHeatmap: MGLRasterStyleLayer?
    private var mapLayerPoints: MGLRasterStyleLayer?
    private var mapLayerRegions: MGLRasterStyleLayer?
    private var mapLayerMunicipality: MGLRasterStyleLayer?
    private var mapLayerSettlements: MGLRasterStyleLayer?
    private var mapLayerWhitespots: MGLRasterStyleLayer?
    
    private var tapGestureRecognizer: UITapGestureRecognizer?
    
    override var mapOptions: RMBTMapOptions? {
        didSet {
            self.setupMapLayers()
            self.updateLayerVisibility()
        }
    }
    
    override func setupMapView() {
        var location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(RMBT_MAP_INITIAL_LAT, RMBT_MAP_INITIAL_LNG)
        // If test coordinates were provided, center map at the coordinates:
        if let initialLocation = self.initialLocation {
            location = initialLocation.coordinate
        } else {
            // Otherwise, see if we have user's location available...
            if let initialLocation = RMBTLocationTracker.sharedTracker.location {
                location = initialLocation.coordinate
            }
        }
        
        let mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(location, zoomLevel: Double(RMBT_MAP_INITIAL_ZOOM), animated: false)
        mapView.showsUserLocation = true

        if #available(iOS 13.0, *) {
            if mapView.traitCollection.userInterfaceStyle == .dark {
                mapView.styleURL = URL(string: RMBT_MAPBOX_DARK_STYLE_URL)!
            } else {
                mapView.styleURL = URL(string: RMBT_MAPBOX_LIGHT_STYLE_URL)!
            }
        } else {
            if RMBTSettings.sharedSettings.isDarkMode == true {
                mapView.styleURL = URL(string: RMBT_MAPBOX_DARK_STYLE_URL)!
            } else {
                mapView.styleURL = URL(string: RMBT_MAPBOX_LIGHT_STYLE_URL)!
            }
        }
        
        mapView.delegate = self
        
        mapView.showsUserLocation = true
        mapView.allowsTilting = false
        mapView.allowsRotating = true
        
        mapView.tintColor = RMBTColorManager.tintColor
        
//        mapView.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleHeight, .flexibleWidth]
        
        mapView.delegate = self
        
        tileSize = 256 * Int(UIScreen.main.scale)
        pointDiameterSize = 4 * Int(UIScreen.main.scale)
        
        // If measurement coordinates were provided, show a blue untappable pin at those coordinates
        if let initialLocation = self.initialLocation {
            // Initialize and add the point annotation.
            let marker = MGLPointAnnotation()
            marker.coordinate = initialLocation.coordinate
            mapView.addAnnotation(marker)
            self.mapMarker = marker
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        mapView.addGestureRecognizer(tapGesture)
        self.tapGestureRecognizer = tapGesture
        
        self.view.addSubview(mapView)
        self.view.sendSubviewToBack(mapView)
        
        self.mapView = mapView
    }
    
    override func setAllGesturesEnabled(_ isEnabled: Bool) {
        mapView.allowsScrolling = isEnabled
    }
    
    func setupMapLayer(with identifier: String) -> MGLStyleLayer? {
        if let layer = self.mapView?.style?.layer(withIdentifier: identifier) {
            self.mapView.style?.removeLayer(layer)
        }
        if let source = self.mapView?.style?.source(withIdentifier: identifier) {
            self.mapView.style?.removeSource(source)
        }

        var params = self.tileParamsDictionary
        var shapeIndentifier = identifier
        
        if identifier == RMBTMapOptionsOverlayRegions.identifier {
            let tileParams = ["shapetype": RMBTMapOptionsOverlayRegions.identifier] as NSMutableDictionary
            tileParams.addEntries(from: self.tileParamsDictionary)
            params = tileParams as? [String: AnyObject] ?? self.tileParamsDictionary
            shapeIndentifier = RMBTMapOptionsOverlayShapes.identifier
        }
        
        if identifier == RMBTMapOptionsOverlayMunicipality.identifier {
            let tileParams = ["shapetype": RMBTMapOptionsOverlayMunicipality.identifier] as NSMutableDictionary
            tileParams.addEntries(from: self.tileParamsDictionary)
            params = tileParams as? [String: AnyObject] ?? self.tileParamsDictionary
            shapeIndentifier = RMBTMapOptionsOverlayShapes.identifier
        }
        
        if identifier == RMBTMapOptionsOverlaySettlements.identifier {
            let tileParams = ["shapetype": RMBTMapOptionsOverlaySettlements.identifier] as NSMutableDictionary
            tileParams.addEntries(from: self.tileParamsDictionary)
            params = tileParams as? [String: AnyObject] ?? self.tileParamsDictionary
            shapeIndentifier = RMBTMapOptionsOverlayShapes.identifier
        }
        
        if identifier == RMBTMapOptionsOverlayWhitespots.identifier {
            let tileParams = ["shapetype": RMBTMapOptionsOverlayWhitespots.identifier] as NSMutableDictionary
            tileParams.addEntries(from: self.tileParamsDictionary)
            params = tileParams as? [String: AnyObject] ?? self.tileParamsDictionary
            shapeIndentifier = RMBTMapOptionsOverlayShapes.identifier
        }
        
        if let url = MapServer.sharedMapServer.getTileUrlForMapBoxOverlayType(shapeIndentifier, params: params) {
            let source = MGLRasterTileSource(identifier: identifier, tileURLTemplates: [url], options: nil)
            let mapLayer = MGLRasterStyleLayer(identifier: identifier, source: source)
            self.mapView?.style?.addSource(source)
            return mapLayer
        }
        
        return nil
    }
    
    override func setupMapLayers() {
        self.mapLayerHeatmap = self.setupMapLayer(with: RMBTMapOptionsOverlayHeatmap.identifier) as? MGLRasterStyleLayer
        
        self.mapLayerPoints = self.setupMapLayer(with: RMBTMapOptionsOverlayPoints.identifier) as? MGLRasterStyleLayer
        
        self.mapLayerRegions = self.setupMapLayer(with: RMBTMapOptionsOverlayRegions.identifier) as? MGLRasterStyleLayer

        self.mapLayerMunicipality = self.setupMapLayer(with: RMBTMapOptionsOverlayMunicipality.identifier) as? MGLRasterStyleLayer

        self.mapLayerSettlements = self.setupMapLayer(with: RMBTMapOptionsOverlaySettlements.identifier) as? MGLRasterStyleLayer

        self.mapLayerWhitespots = self.setupMapLayer(with: RMBTMapOptionsOverlayWhitespots.identifier) as? MGLRasterStyleLayer
    }
    
    private func deselectCurrentMarker() {
        if mapMarker != nil {
            self.mapView?.removeAnnotation(mapMarker)
            mapMarker = nil
            self.selectedMeasurement = nil
//            mapMarker.map = nil
//            mapView.selectedMarker = nil
//            mapMarker = nil
        }
    }
    
    override func refresh() {
        if let tileParamsConvert = mapOptions?.paramsDictionary() {
            tileParamsDictionary = tileParamsConvert
            tileParamsDictionary["size"] = tileSize as AnyObject?
            tileParamsDictionary["point_diameter"] = pointDiameterSize as AnyObject?
        }
        
        if let mapOptions = self.mapOptions {
//            satellite:
//            mapbox://styles/specure/cjmcfobr502di2slj5b64t1xb
//            streat
//            mapbox://styles/specure/cjmcdp6wbii272rp4rjben9s7
//            basic
//            mapbox://styles/specure/cjlntyonf43yu2rmhta6m153v
            switch mapOptions.mapViewType {
            case .hybrid:
                mapView?.styleURL = URL(string: RMBT_MAPBOX_SATELLITE_STYLE_URL)!
            case .satellite:
                mapView?.styleURL = URL(string: RMBT_MAPBOX_STREET_STYLE_URL)!
            default:
                if #available(iOS 13.0, *) {
                    if mapView.traitCollection.userInterfaceStyle == .dark {
                        mapView.styleURL = URL(string: RMBT_MAPBOX_DARK_STYLE_URL)!
                    } else {
                        mapView.styleURL = URL(string: RMBT_MAPBOX_LIGHT_STYLE_URL)!
                    }
                } else {
                    if RMBTSettings.sharedSettings.isDarkMode == true {
                        mapView?.styleURL = URL(string: RMBT_MAPBOX_DARK_STYLE_URL)!
                    } else {
                        mapView?.styleURL = URL(string: RMBT_MAPBOX_LIGHT_STYLE_URL)!
                    }
                }
            }
        }
        
        self.mapView?.reloadStyle(nil)
        setupMapLayers()
        updateLayerVisibility()
    }
    // MARK: Layer visibility
    
    ///
    private func setLayer(_ layer: MGLStyleLayer, hidden: Bool) {
        var firstLabelLayer: MGLStyleLayer? = nil
        for layer in self.mapView?.style?.layers ?? [] {
            if layer.identifier.lowercased().contains("label") {
                firstLabelLayer = layer
                break
            }
            if let l = layer as? MGLSymbolStyleLayer,
                l.sourceLayerIdentifier?.contains("label") ?? false {
                firstLabelLayer = layer
                break
            }
        }
        if hidden {
            if let l = self.mapView?.style?.layer(withIdentifier: layer.identifier) {
                self.mapView?.style?.removeLayer(l)
            }
        } else {
            if self.mapView?.style?.layer(withIdentifier: layer.identifier) == nil {
                if let firstLabelLayer = firstLabelLayer {
                    self.mapView?.style?.insertLayer(layer, below: firstLabelLayer)
                } else {
                    self.mapView?.style?.addLayer(layer)
                }
            }
        }
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
            } else if overlay.overlayIdentifier == RMBTMapOptionsOverlayAuto.identifier {
                if mapOptions?.activeType?.id.rawValue == "browser" {
                    // Shapes
                    //shapesVisible = true
                    //regionsVisible = true // TODO: is this correct?
                } else {
                    heatmapVisible = true
                }
                
                pointsVisible = (Float(mapView?.zoomLevel ?? 0.0) >= RMBT_MAP_AUTO_TRESHOLD_ZOOM)
                
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
        
        if let coord = mapView?.userLocation?.coordinate {
            mapView?.setCenter(coord, animated: true)
        }
    }
    
    @objc func tapHandler(_ sender: UIGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.ended {
            let point = sender.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
//          If we're not showing points, ignore this tap
//            if self.mapView?.style?.layer(withIdentifier: RMBTMapOptionsOverlayPoints.identifier) == nil {
//                return
//            }
            
            guard let mapOptions = self.mapOptions,
                let mapView = self.mapView else { return }
            
            let params = mapOptions.markerParamsDictionary()
            
            MapServer.sharedMapServer.getMeasurementsAtCoordinate(coordinate, zoom: Int(mapView.zoomLevel), params: params, success: { [weak self] measurements in
                logger.debug("\(measurements)")
    
                guard let strongSelf = self else { return }
                strongSelf.deselectCurrentMarker()

                if let m = measurements.first {
                    if let lat = m.latitude, let lon = m.longitude {
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)

                        var centerCoordinate = coordinate
                        if let mapView = strongSelf.mapView {
                            var point = mapView.convert(coordinate, toPointTo: strongSelf.mapView)
                            point.y -= (mapView.frame.height * 0.8) / 2
                            centerCoordinate = mapView.convert(point, toCoordinateFrom: mapView)
                        }

                        strongSelf.mapView.setCenter(centerCoordinate, animated: true)

                        let marker = MGLPointAnnotation()
                        marker.title = "Hi"
                        marker.coordinate = coordinate
                        strongSelf.mapView?.addAnnotation(marker)
                        strongSelf.mapMarker = marker
                        strongSelf.selectedMeasurement = m
                        strongSelf.mapView?.selectAnnotation(marker, animated: true, completionHandler: nil)
                    } else {
                        var centerCoordinate = coordinate
                        if let mapView = strongSelf.mapView {
                            var point = mapView.convert(coordinate, toPointTo: strongSelf.mapView)
                            point.y -= (mapView.frame.height * 0.8) / 2
                            centerCoordinate = mapView.convert(point, toCoordinateFrom: mapView)
                        }
                        
                        strongSelf.mapView.setCenter(centerCoordinate, animated: true)
                        
                        let marker = MGLPointAnnotation()
                        marker.title = "Hi"
                        marker.coordinate = coordinate
                        strongSelf.mapView?.addAnnotation(marker)
                        strongSelf.mapMarker = marker
                        strongSelf.selectedMeasurement = m
                        strongSelf.mapView?.selectAnnotation(marker, animated: true, completionHandler: nil)
                    }
                }
                }, error: { error in
                    logger.error("Error getting measurements at coordinate")
            })
        }
    }
}

extension RMBTMapBox: MGLMapViewDelegate {
    
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        updateLayerVisibility()
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        setupMapLayers()
        updateLayerVisibility()
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        // Try to reuse the existing ‘pisa’ annotation image, if it exists.
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "marker")
        
        if annotationImage == nil,
            let markerImage = UIImage(named: "marker") {
            // Leaning Tower of Pisa by Stefan Spieler from the Noun Project.
            var image = markerImage.withRenderingMode(.alwaysTemplate)
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height / 2, right: 0))
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "marker")
        }
        
        return annotationImage
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }
    
    func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) -> MGLCalloutView? {
        if let markerObj = self.selectedMeasurement {
            return CustomCalloutView(annotation: annotation, measurement: markerObj, delegate: self)
        }

        return nil
    }
}

extension RMBTMapBox: RMBTMapCalloutViewDelegate {
    func mapCalloutView(_ sender: RMBTMapCalloutView, didShowDetails measurement: SpeedMeasurementResultResponse) {
        // if measurementUuid is there  -> show measurement in app (allow only on global map -> initialLocation == nil)
        if let measurementUuid = measurement.measurementUuid, /*markerData.highlight &&*/ initialLocation == nil { // highlight is a filter -> see MapServer...
            
            self.delegate?.mapViewShowMeasurementFromMap(measurementUuid)
            //TODO: Move outside
            //                performSegue(withIdentifier: "show_own_measurement_from_map", sender: measurementUuid)
            
        } else if let openTestUuid = measurement.openTestUuid { // else show open test result
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

class CustomCalloutView: UIView, MGLCalloutView {
    
    var measurement: SpeedMeasurementResultResponse
    var representedObject: MGLAnnotation
    // Required views but unused for now, they can just relax
    lazy var leftAccessoryView = UIView()
    lazy var rightAccessoryView = UIView()
    
    weak var delegate: MGLCalloutViewDelegate?
    weak var calloutDelegate: RMBTMapCalloutViewDelegate?
    
    required init(annotation: MGLAnnotation, measurement: SpeedMeasurementResultResponse, delegate: RMBTMapCalloutViewDelegate? = nil) {
        
        self.representedObject = annotation
        self.measurement = measurement
        self.calloutDelegate = delegate
        // init with 75% of width and 120px tall
        super.init(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: UIScreen.main.bounds.width * 0.75, height: 120.0)))
        
        setup()
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        // setup this view's properties
        self.backgroundColor = UIColor.clear
    }
    
    func presentCallout(from rect: CGRect, in view: UIView, constrainedTo constrainedRect: CGRect, animated: Bool) {
        let callout = RMBTMapCalloutView.calloutViewWithMeasurement(self.measurement)
        let calloutHeight = callout.height
        let constrainedHeight = constrainedRect.height * 0.8 - 10
        callout.delegate = self.calloutDelegate
        var y: CGFloat = 0.0
        if calloutHeight > constrainedHeight {
            callout.frame.size.height = constrainedHeight
        } else {
            callout.frame.size.height = calloutHeight
            y = (constrainedHeight - calloutHeight) / 2
        }
        
        self.frame = callout.bounds
        
        self.center = view.center.applying(CGAffineTransform(translationX: 0, y: y - 5))
        
        self.addSubview(callout)
        view.addSubview(self)
    }
    
    func dismissCallout(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 0.0
            }, completion: { (_) in
                self.removeFromSuperview()
            })
        } else {
            removeFromSuperview()
        }
        
    }
}
