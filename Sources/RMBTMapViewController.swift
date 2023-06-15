/*****************************************************************************************************
 * Copyright 2013 appscape gmbh
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

import BCGenieEffect
import RMBTClient
import CoreLocation

/// These values are passed to map server and are multiplied by 2x on retina displays to get pixel sizes
let kTileSizePoints: CGFloat = 1024
let kPointDiameterSizePoints: CGFloat = 8

let kCameraLatKey     = "map.camera.lat"
let kCameraLngKey     = "map.camera.lng"
let kCameraZoomKey    = "map.camera.zoom"
let kCameraBearingKey = "map.camera.bearing"
let kCameraAngleKey   = "map.camera.angle"

///
class RMBTMapViewController: TopLevelViewController, RMBTMapSubViewControllerDelegate {

    @IBOutlet private var locateMeButton: UIButton!

    @IBOutlet weak var toastValuesLabel: UILabel!
    @IBOutlet weak var toastKeyLabel: UILabel!
    @IBOutlet weak var openDataTextLabel: UILabel?
    @IBOutlet weak var openDataTitleLabel: UILabel!
    @IBOutlet weak var openDataToastView: UIView!
    
    private var settingsBarButtonItem: UIBarButtonItem!
    private var filterBarButtonItem: UIBarButtonItem!
    private var toastBarButtonItem: UIBarButtonItem!
    
    var mapController: RMBTMapController?

    /// If set, blue pin will be shown at this location and map initially zoomed here. Used to display a test on the map.
    var initialLocation: CLLocation!

    private var mapOptions: RMBTMapOptions? = (UIApplication.shared.delegate as? RMBTAppDelegate)?.mapOptions {
        didSet {
            self.updateToastInfo()
            (UIApplication.shared.delegate as? RMBTAppDelegate)?.mapOptions = mapOptions
        }
    }
    
    ///
    private var tileSize: Int!

    ///
    private var pointDiameterSize: Int!
    
    ///
    var isModal = false
    
    ///
    var theInfoToastInProgress = false

    //
    override var preferredStatusBarStyle: UIStatusBarStyle { return RMBTColorManager.statusBarStyle }
    override var shouldAutorotate: Bool { return true }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .all }
    ///
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tabBarItem.title = L("tabbar.title.map")
        self.tabBarItem.image = UIImage(named: "ic_map_white_25pt")
        self.navigationController?.tabBarItem = self.tabBarItem
    }
    ///
    override func viewDidLoad() {
        if isModal {
            revealControllerEnabled = false
        }
        
        super.viewDidLoad()
        
        self.navigationItem.title = L("RMBT-NI-MAPS")
        
        if isModal { addStandardDoneButton() }
        
        toastBarButtonItem = UIBarButtonItem(image: UIImage(named: "map_info"), style: .plain, target: self, action: #selector(RMBTMapViewController.toggleToast(_:)))
        toastBarButtonItem.isEnabled = false

        settingsBarButtonItem = UIBarButtonItem(image: UIImage(named: "map_options"), style: .plain, target: self, action: #selector(RMBTMapViewController.showMapOptions))
        settingsBarButtonItem.isEnabled = false

        filterBarButtonItem = UIBarButtonItem(image: UIImage(named: "map_filter"), style: .plain, target: self, action: #selector(RMBTMapViewController.showMapFilter))
        filterBarButtonItem.isEnabled = false

        self.updateToastInfo()

        // if initialLocation == nil {
        if RMBT_MAP_SHOW_INFO_POPUP == true {
            navigationItem.rightBarButtonItems = [toastBarButtonItem, settingsBarButtonItem, filterBarButtonItem]
        } else {
            navigationItem.rightBarButtonItems = [settingsBarButtonItem, filterBarButtonItem]
        }
        
        // }
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        
        mapController = RMBTMapController(with: RMBT_MAP_TYPE, rootView: self.view, initialLocation: self.initialLocation, mapOptions: self.mapOptions)
        mapController?.delegate = self
        mapController?.refresh()
    }
    
//    @objc override func backAction() {
//        if let tabBarController = UIApplication.shared.delegate?.window??.rootViewController as? RMBTCustomTabBarController {
//            tabBarController.pop()
//        } else {
//            super.backAction()
//        }
//    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        self.mapController?.refresh()
    }
    
    override func applyColorScheme() {
        let image = self.locateMeButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        self.locateMeButton.setImage(image, for: .normal)
        self.locateMeButton.tintColor = RMBTColorManager.navigationBarTitleColor
        self.locateMeButton.backgroundColor = RMBTColorManager.navigationBarBackground
        self.locateMeButton.layer.cornerRadius = 5
    }
    
    func updateToastInfo() {
        if INFO_SHOW_OPEN_DATA_SOURCES == true {
            self.openDataTitleLabel.text = L("info.title.open_data_sources_notice")
            self.openDataTextLabel?.text = String.formatStringDataSourcesText()
            self.toastKeyLabel.isHidden = true
            self.toastValuesLabel.isHidden = true
            self.openDataTextLabel?.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        self.requestMapOptions()
        self.setupToast()
    }
    ///
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        togglePopGestureRecognizer(false)

        // Note that initializing map view for the first time takes few seconds until all resources are initialized,
        // so to appear more responsive we we do it here (instead of viewDidLoad).
    }

    ///
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        togglePopGestureRecognizer(true)
    }
    
    func setupToast() {
        // Setup toast (overlay) view
        openDataToastView.isHidden = true
        openDataToastView.layer.cornerRadius = 6.0
        
        let openDataTapToastRecognizer = UITapGestureRecognizer(target: self, action: #selector(RMBTMapViewController.toggleToast(_:)))
        openDataToastView.addGestureRecognizer(openDataTapToastRecognizer)
        
        if let m = self.mapController?.mapView {
            view.insertSubview(m, belowSubview: openDataToastView)
        }
    }
    
    func requestMapOptions() {
        // load map options
        MapServer.sharedMapServer.getMapOptions(
            success: { [weak self] response in
            logger.debug("got map options: \(response)")
                
            // TODO: rewrite MapViewController to use new objects
            let mapOptions = RMBTMapOptions(response: response,
                                            isSkipOperators: RMBT_MAP_SKIP_RESPONSE_OPERATORS,
                                            defaultMapViewType: RMBT_MAP_VIEW_TYPE_DEFAULT)
                
            if let existedMapOptions = self?.mapOptions {
                mapOptions.merge(with: existedMapOptions)
            }
            self?.mapOptions = mapOptions
            self?.mapController?.mapOptions = mapOptions
            
            self?.settingsBarButtonItem.isEnabled = true
            self?.filterBarButtonItem.isEnabled = true
            self?.toastBarButtonItem.isEnabled = true
            
            self?.setupMapLayers()
            self?.refresh()
            
            }, error: { error in
                logger.error("Could not load map options")
        })
    }

    ///
    private func setupMapLayers() {
        self.mapController?.setupMapLayers()
    }

    ///
    private func refresh() {
        self.mapController?.refresh()

        if RMBT_MAP_SHOW_INFO_POPUP == true {
            self.updateToastInfo()
            let rect = CGRect(x: view.frame.width - 36, y: 0, width: 10, height: 10) // top right corner
            display(toast: self.openDataToastView, state: true, withGenieEffect: false, rect: rect)
        }
    }

    ///
    private func display(toast: UIView, state: Bool, withGenieEffect genie: Bool, rect: CGRect) {
        if toast.isHidden != state {
            return // already displayed/hidden
        }

        toast.isHidden = false
        self.theInfoToastInProgress = true

        if !genie {
            toast.alpha = (state) ? 0.0 : 1.0
            toast.transform = CGAffineTransform.identity

            UIView.animate(withDuration: 0.5, animations: {
                toast.alpha = (state) ? 1.0 : 0.0
            }, completion: { _ in
                toast.isHidden = !state
            })

            if state {
                // autohide after 3 sec
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                    self.display(toast: toast, state: false, withGenieEffect: true, rect: rect)
                }
            }
        } else {
            let buttonRect = rect

            if state {
                toast.genieOutTransition(withDuration: 0.5, start: buttonRect, start: .bottom, completion: { [weak self] in
                    self?.theInfoToastInProgress = false
                })
            } else {
                toast.genieInTransition(withDuration: 0.5, destinationRect: buttonRect, destinationEdge: .bottom, completion: { [weak self] in
                    toast.isHidden = true
                    self?.theInfoToastInProgress = false
                })
            }
        }
    }

// MARK: Segues

    ///
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_map_options" || segue.identifier == "show_map_filter" {
            let optionsVC = segue.destination as! RMBTMapSubViewController
                optionsVC.delegate = self
                optionsVC.mapOptions = mapOptions
            
        } else if segue.identifier == "show_own_measurement_from_map" {
//            if let measurementResult = segue.destination as? RMBTHistoryResultViewController {
//                measurementResult.isModal = true
//                measurementResult.historyResult =
//            }

// NKOM special
// should be enabled later ???
//            if let measurementResultTableViewController = segue.destination as? MeasurementResultTableViewController {
//                measurementResultTableViewController.measurementUuid = sender as? String
//                measurementResultTableViewController.fromMap = true
//            }
        }
    }

    ///
    // RMBTMapSubViewControllerDelegate
    func mapSubViewController(_ viewController: RMBTMapSubViewController, willDisappearWithChange change: Bool) {
        
        guard let mapOptions = self.mapOptions else { return }
        
        self.mapController?.mapOptions = mapOptions
//        if change {
            logger.debug("Map options changed, refreshing...")
            mapOptions.saveSelection()
//        }
        refresh()

//        switch mapOptions.mapViewType {
//        case .hybrid:       mapView.mapType = .hybrid
//        case .satellite:    mapView.mapType = .satellite
//        default:            mapView.mapType = .normal
//        }
    }

    ///
    private func togglePopGestureRecognizer(_ state: Bool) {
        // Temporary fix for http://code.google.com/p/gmaps-api-issues/issues/detail?id=5772 on iOS7
        navigationController?.interactivePopGestureRecognizer?.isEnabled = state
        self.revealViewController()?.panGestureRecognizer().isEnabled = state
        self.revealViewController()?.edgeGestureRecognizer().isEnabled = state
    }

// MARK: Button actions

    ///
    @objc func showMapOptions() {
        performSegue(withIdentifier: "show_map_options", sender: self)
    }

    ///
    @objc func showMapFilter() {
        performSegue(withIdentifier: "show_map_filter", sender: self)
    }

    ///
    @IBAction func toggleToast(_ sender: AnyObject) {
        if !self.theInfoToastInProgress {
            let rect = CGRect(x: view.frame.width - 36, y: 0, width: 10, height: 10) // top right corner
            display(toast: self.openDataToastView, state: openDataToastView.isHidden, withGenieEffect: true, rect: rect)
        }
    }

    ///
    @IBAction func locateMe(_ sender: AnyObject) {
        if RMBTLocationTracker.sharedTracker.location == nil {
            return
        }
        
        self.mapController?.locateMe()
    }

// MARK: Helpers

    ///

// MARK: state preservation / restoration

    ///
    override func encodeRestorableState(with coder: NSCoder) {
        logger.debug("\(#function)")

        super.encodeRestorableState(with: coder)
    }

    ///
    override func decodeRestorableState(with coder: NSCoder) {
        logger.debug("\(#function)")

        super.decodeRestorableState(with: coder)
    }

    ///
    override func applicationFinishedRestoringState() {
        logger.debug("\(#function)")

        revealViewController().delegate = self
    }
}

extension RMBTMapViewController: RMBTMapControllerDelegate {
    func mapViewOpenTestUrl(_ url: String) {
        self.presentModalBrowserWithURLString(url)
    }
    
    func mapViewShowMeasurementFromMap(_ uuid: String) {
        performSegue(withIdentifier: "show_own_measurement_from_map", sender: uuid)
    }
}

// MARK: SWRevealViewControllerDelegate

///
extension RMBTMapViewController {
    ///
    func revealControllerPanGestureBegan(_ revealController: SWRevealViewController!) {
        self.mapController?.setAllGesturesEnabled(false)
    }
    
    ///
    func revealControllerPanGestureEnded(_ revealController: SWRevealViewController!) {
        self.mapController?.setAllGesturesEnabled(true)
    }
    
    ///
    override func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        super.revealController(revealController, didMoveTo: position)
        
        self.mapController?.setAllGesturesEnabled(position == .left)
    }
}
