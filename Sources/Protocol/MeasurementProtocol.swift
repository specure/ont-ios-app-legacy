//
//  File.swift
//  RMBT
//
//  Created by Tomas Baculák on 17/03/2017.
//  Copyright © 2017 SPECURE GmbH. All rights reserved.
//

import Foundation
import RMBTClient

protocol ManageMeasurement: AnyObject, RMBTClientDelegate, ManageMeasurementView {
    //
    // allocate with client type - .nkom for NKOM project, .standard for ONT, .original for original solution
    var rmbtClient: RMBTClient { get }
    ///
    var measurementResultUuid: String? { get set }
    ///
    var isQosAvailable: Bool { get set }
    ///
    var wasTestExecuted: Bool { get set }
    ///

    //
    func startMeasurementAction()
    //
    func abortMeasurementAction() -> UIAlertController?
    func abortLoopModeMeasurementAction(abortAction: AlertAction, keepAction: AlertAction) -> UIAlertController?
}

// Default implementation
extension ManageMeasurement {
    //
    func abortMeasurementAction() -> UIAlertController? {
        if rmbtClient.running {
            return UIAlertController.presentAbortAlert(nil, abortAction: ({ [weak self] _ in
                self?.rmbtClient.delegate = nil
                self?.stopMeasurement()
                self?.manageViewControllerAbort()
            }))
        }
        return nil
    }
    
    //
    func abortLoopModeMeasurementAction(abortAction: AlertAction, keepAction: AlertAction) -> UIAlertController? {
        return UIAlertController.presentAbortLoopModeAlert(nil, abortAction: ({ [weak self] action in
            self?.rmbtClient.delegate = nil
            self?.stopMeasurement()
            abortAction?(action)
        }), keepAction: { [weak self] action in
            self?.rmbtClient.delegate = nil
            self?.stopMeasurement()
            keepAction?(action)
        })
    }
    
    //
    func startMeasurementAction() {
        
        RMBTLocationTracker.sharedTracker.startAfterDeterminingAuthorizationStatus { [weak self] in
            guard let strongSelf = self else { return }
            
            //
            self?.rmbtClient.delegate = strongSelf
            //
            self?.rmbtClient.startMeasurement()
            // manage view
            self?.manageViewNewStart()
        }
    }
    
    //
    func startQosMeasurementAction() {
        
        RMBTLocationTracker.sharedTracker.startAfterDeterminingAuthorizationStatus { [weak self] in
            guard let strongSelf = self else { return }
            //
            self?.rmbtClient.delegate = strongSelf
            //
            self?.rmbtClient.startQosMeasurement(inMain: false)
        }
    }
    
// MARK: RMBTClientDelegate
    
    // NKOM DEFAULT 
    func speedMeasurementDidMeasureSpeed(throughputs: [RMBTThroughput], inPhase phase: SpeedMeasurementPhase) {
        if let throughput = throughputs.last { // last?
            let speedString = RMBTSpeedMbpsString(throughput.kilobitsPerSecond(), withMbps: false)
            let speedLogValue = RMBTSpeedLogValue(throughput.kilobitsPerSecond(), gaugeParts: 4, log10Max: log10(1000))
            // manage view
            manageViewProgress(phase: phase, title: speedString, value: speedLogValue)
        }
    }
    //
    func speedMeasurementDidUpdateWith(progress: Float, inPhase phase: SpeedMeasurementPhase) {
        
    }

    func measurementDidComplete(_ client: RMBTClient, withResult result: String) {
        logger.debug("Main Meaasurement - DID COMPLETE")
        
        self.rmbtClient.delegate = nil
        self.wasTestExecuted = true
        self.measurementResultUuid = result
        // manage view
        manageViewFinishMeasurement(uuid: result)
    }
    
    ///
    func measurementDidFail(_ client: RMBTClient, withReason reason: RMBTClientCancelReason) {
        DispatchQueue.main.async {
            logger.debug("MEASUREMENT FAILED: \(reason)")
            
            self.rmbtClient.delegate = nil
            //

            _ = UIAlertController.presentDidFailAlert(reason,
                                                        dismissAction: ({ [weak self] _ in self?.manageViewsAbort()
                                                            self?.manageViewControllerAbort()
                                                        }),
                                                        startAction: ({ [weak self] _ in self?.startMeasurementAction() })
            )
        }
    }
    
    ///
    func speedMeasurementDidStartPhase(_ phase: SpeedMeasurementPhase) {
        manageViewProcess(phase)
    }
    
    ///
    func speedMeasurementDidFinishPhase(_ phase: SpeedMeasurementPhase, withResult result: Double) {
        manageViewFinishPhase(phase, withResult: result)
    }
    
// MARK: QoS
    ///
    func qosMeasurementDidStart(_ client: RMBTClient) {
        //
        self.isQosAvailable = true
        // manage view
        manageViewAfterQosStart()
    }
    ///
    func qosMeasurementDidUpdateProgress(_ client: RMBTClient, progress: Float) {
        let progressPercentValue = Int(progress * 100)
        // manage view
        manageViewAfterQosUpdated(value: progressPercentValue)
    }
    ///  
    func qosMeasurementList(_ client: RMBTClient, list: [QosMeasurementType]) {
        //
        manageViewAfterQosGetList(list: list)
    }
    ///
    func qosMeasurementFinished(_ client: RMBTClient, type: QosMeasurementType) {
        //
        manageViewAfterQosFinishedTest(type: type)
    }
    
// Mark : Helpers
    
    private func stopMeasurement() {
        //
        self.wasTestExecuted = false
        //
        self.rmbtClient.stopMeasurement()
        // manage view
        manageViewsAbort()
    }
}
