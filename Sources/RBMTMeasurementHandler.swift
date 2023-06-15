//
//  RBMTMeasurementHandler.swift
//  RMBT
//
//  Created by Tomas Baculák on 25/04/2017.
//  Copyright © 2017 SPECURE GmbH. All rights reserved.
//

import Foundation
import RMBTClient
import Fabric

/////
//
extension RMBTTesterViewController {
    
    ///
    func measurementDidStart(client: RMBTClient) {
        
    }
    
    //
    func manageViewNewStart() {
        UIView.animate(withDuration: 0.5, animations: {
            
            // reset view
            self.resetView()
            
            self.finishedPercentage = 0
            self.displayPercentage(0)
            
            self.speedGraphView?.clear()
            self.progressGaugeView.value = 0
            self.speedGaugeView.value = 0
            self.targetSpeed = 0.0
            self.rotationArrow(to: CGFloat.pi)
            
            self.qosLabel.isHidden = true
            
            let defaultValue = "-"
            
            self.upResultLabel?.text = defaultValue
            self.downResultLabel?.text = defaultValue
            self.pingResultLabel?.text = defaultValue
            self.jitterLabel?.text = defaultValue
            self.packetLossLabel?.text = defaultValue
            
            self.downloadBackgrounView?.graphView?.clear()
            self.uploadBackgrounView?.graphView?.clear()
            
            // make visible
            self.speedGraphView?.alpha = 1.0
            
            self.qtMode = false
            self.swapViews()
            self.resultsTable.reloadData()
        
        }, completion: { _ in
        
        })
    }
    //
    
    ///
    func measurementDidCompleteVoip(_ client: RMBTClient, withResult: [String: Any]) {
        // compute mean jitter as outcome
        if let inJiter = withResult["voip_result_out_mean_jitter"] as? NSNumber,
            let outJiter = withResult["voip_result_in_mean_jitter"] as? NSNumber {
            var j = String(format: "%.2f", (inJiter.doubleValue + outJiter.doubleValue) / 2_000_000)
            // assign value
            self.jitterLabel?.text = j.addMsString()
        }
        
        // compute packet loss (both directions) as outcome
        if let inPL = withResult["voip_result_in_num_packets"] as? NSNumber,
            let outPL = withResult["voip_result_out_num_packets"] as? NSNumber,
            let objDelay = withResult["voip_objective_delay"] as? NSNumber,
            let objCallDuration = withResult["voip_objective_call_duration"] as? NSNumber,
            objDelay != 0,
            objCallDuration != 0 {
            
            let total = objCallDuration.doubleValue / objDelay.doubleValue
            
            let packetLossUp = (total - outPL.doubleValue) / total
            let packetLossDown = (total - inPL.doubleValue) / total
            
            var packetLoss = String(format: "%0.1f", ((packetLossUp + packetLossDown) / 2) * 100)
            
            self.packetLossLabel?.text = packetLoss.addPercentageString()
        }
    }
    
    //
    internal func manageViewsAbort() {
        
        DispatchQueue.main.async {
            // modal solution
            // self.dismiss(animated: true, completion: nil)
            //
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //
    internal func manageViewProgress(phase: SpeedMeasurementPhase, title: String , value: Double) {

        let phasePercentage = Float(percentageForPhase(phase)) * Float(value)
        let totalPercentage = Float(finishedPercentage) + phasePercentage
        assert(totalPercentage <= 100, "Invalid percentage")

        displayPercentage(Int(totalPercentage))
        
        logger.debug(totalPercentage)
        
    }
    
    //
    internal func manageViewFinishMeasurement(uuid: String) {
        RMBTSettings.sharedSettings.countMeasurements += 1
        // go directly to next loop if should skip qos
        if loopMode && loopSkipQOS {
            logger.debug("skipping qos test in loop mode")
            restartTestAfterCountdown(interval: loopMinDelay)
            return
        }
        
        // Load from DB the fresh record !!!
        MeasurementHistory.sharedMeasurementHistory.getHistoryWithFilters(filters: nil, length: 1, offset: 0, success: { [weak self] response in
            var results = [RMBTHistoryResult]()
            
            for r in response.records {
                results.append(RMBTHistoryResult(response: r as HistoryItem))
            }
            
            let defaultValue = "-"

            if results.first?.jitterMsString != defaultValue {
                self?.jitterLabel?.text = results.first?.jitterMsString.addMsString() ?? defaultValue
                if results.first?.packetLossPercentageString != defaultValue {
                    self?.packetLossLabel?.text = results.first?.packetLossPercentageString.addPercentageString() ?? defaultValue
                } else {
                    self?.packetLossLabel?.text = defaultValue
                }
            } else {
                self?.jitterLabel?.text = defaultValue
                self?.packetLossLabel?.text = defaultValue
            }
 
        }, error: { error in
            
            _ = UIAlertController.presentErrorAlert(error as NSError, dismissAction: nil)
            
        })
        
        if rmbtClient.isQOSEnabled || self.isManualQosLaunched {
            MeasurementHistory.sharedMeasurementHistory.getQOSHistoryOld(uuid: uuid, success: { [weak self] (response) in
                let qosResults = response

                self?.qosView?.isHidden = false
                self?.passedView?.isHidden = false
                self?.performedView?.isHidden = false
                self?.failedView?.isHidden = false
                self?.passedValueLabel.text = String(format: "%d", qosResults.calculateQosSuccess())
                self?.failedValueLabel.text = String(format: "%d", qosResults.calculateQosFailed())
                self?.performedValueLabel.text = String(format: "%d", qosResults.testResultDetail?.count ?? 0)
                self?.qosValueLabel.text = String(format: "%0.0f%%", qosResults.calculateQosSuccessPercentage())
                
                //If 4S then don't show qos label
                if (self?.view.frameHeight ?? 0.0) < CGFloat(500.0) {
                    self?.qosView?.isHidden = true
                }
                
            }, error: { _ in
            })
        }
        
        self.uploadSpeedGraphView?.isHidden = true
        self.speedGraphView?.isHidden = true
        self.testUI(isHidden: true)
        self.textAnimator.stopAnimation()
        self.serversView.isShouldUserInterectionEnabled = true
        if self.isManualQosLaunched == true {
            self.qosBackgroundView.isHidden = true
        } else if rmbtClient.isQOSEnabled == false {
            self.progressLabel.isHidden = false
            self.startDefaultView?.isHidden = true
            self.progressGaugeView.isHidden = false
            self.qosBackgroundView.isHidden = false
            self.serversView.isShouldUserInterectionEnabled = false
            self.unusedTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(unusedTimerHandler(timer:)), userInfo: nil, repeats: false)
        }
        
        self.abortAlert?.dismiss(animated: true, completion: nil)
        
        RMBTSettings.sharedSettings.previousNetworkName = self.networkNameLabel?.text
        
        let duration: Double = 60 * 60 * 24 * 7 // 1 week
        RMBTRateManager.manager.tick(with: "count_successful_measurements", maxCount: 5, duration: duration)
        
        if RMBTSettings.sharedSettings.isAdsRemoved == false && RMBTClient.advertisingIsActive {
            self.isNeedReloadBanner = true
        }
        
        if RMBTClient.surveyIsActiveService == true {
            if RMBTSettings.sharedSettings.lastSurveyTimestamp < RMBTClient.surveyTimestamp ?? 0.0 {
                checkSurvey(success: { (response) in
                    if response.survey?.isFilledUp == false {
                        _ = UIAlertController.presentSurveyAlert({ (_) in
                            if let surveyUrl = response.survey?.surveyUrl,
                                let uuid = RMBTClient.uuid,
                                let url = URL(string: surveyUrl + "?client_uuid=" + uuid) {
                                UIApplication.shared.open(url, completionHandler: nil)
                                RMBTSettings.sharedSettings.lastSurveyTimestamp = RMBTClient.surveyTimestamp ?? 0.0
                                AnalyticsHelper.logCustomEvent(withName: "Survey: Open Clicked", attributes: nil)
                            } else {
                                var parameters = ["Reason": "Bad Url"]
                                parameters["url"] = response.survey?.surveyUrl ?? "Empty"
                                parameters["uuid"] = RMBTClient.uuid ?? "Empty"
                                AnalyticsHelper.logCustomEvent(withName: "Survey: Don't showed", attributes: parameters)
                            }
                        }, neverAction: { (_) in
                            RMBTSettings.sharedSettings.lastSurveyTimestamp = RMBTClient.surveyTimestamp ?? 0.0
                            AnalyticsHelper.logCustomEvent(withName: "Survey: Never Clicked", attributes: nil)
                        }, remindAction: { (_) in
                            AnalyticsHelper.logCustomEvent(withName: "Survey: Remind Clicked", attributes: nil)
                        })
                    } else if response.survey?.isFilledUp == true {
                        RMBTSettings.sharedSettings.lastSurveyTimestamp = RMBTClient.surveyTimestamp ?? 0.0
                    }
                }, error: { (_) in
                    
                })
            }
        }
        
        (self.tabBarController as? RMBTTabBarViewController)?.updateHistory()
    }
    
    //
    internal func manageViewProcess(_ phase: SpeedMeasurementPhase) {
        
        switch phase {
        case .Init, .wait:
            var serverValues: [String] = []
            if let name = self.rmbtClient.testRunner?.testParams.measurementServer?.name,
                let ip = self.rmbtClient.testRunner?.testParams.clientRemoteIp {
                serverValues = [name, ip]
            }
            self.serverValues = serverValues
            self.resultsTable.reloadData()
        default:  break
        }
        
        if phase == .Init {
            updateStatusWithValue(text: "", phase: .Init, final: true)
        }
    }
    
    internal func manageViewFinishPhase(_ phase: SpeedMeasurementPhase, withResult result: Double) {

        if phase == .latency {
            updateStatusWithValue(text: RMBTMillisecondsStringWithNanos(UInt64(result)), phase: phase, final: true)
            pingResultLabel?.text = RMBTMillisecondsStringWithNanos(UInt64(result))
        } else if phase == .down {
            speedGaugeView.value = 0
            self.arrowImageView.layer.removeAllAnimations()
            self.targetSpeed = 0.0
            self.rotationArrow(to: CGFloat.pi)
            self.downResultLabel?.text = RMBTSpeedMbpsString(result, withMbps: false)
            updateStatusWithValue(text: RMBTSpeedMbpsString(result), phase: phase, final: true)
        } else if phase == .up {
            self.upResultLabel?.text = RMBTSpeedMbpsString(result, withMbps: false)
            updateStatusWithValue(text: RMBTSpeedMbpsString(result), phase: phase, final: true)
        }

        finishedPercentage = percentageAfterPhase(phase: phase)
        displayPercentage(finishedPercentage)

        assert(finishedPercentage <= 100, "Invalid percentage")
    }
    
    ///
    internal func speedMeasurementDidUpdateWith(progress: Float, inPhase phase: SpeedMeasurementPhase) {
        let phasePercentage = Float(percentageForPhase(phase)) * progress
        let totalPercentage = Float(finishedPercentage) + phasePercentage
        assert(totalPercentage <= 100, "Invalid percentage")

        displayPercentage(Int(totalPercentage))
        
        logger.debug(totalPercentage)
    }
    
    open func rotationArrow(to backStartAngle: CGFloat) {
//        let previousAngle = self.previousBackStartAngle
//        self.arrowImageView.layer.removeAllAnimations()
        self.targetStartAngle = backStartAngle
//        self.previousBackStartAngle = backStartAngle
//        let duration: Double = 1.0
//        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: .beginFromCurrentState, animations: {
//            let countSteps: Double = 4.0
//            let durationOneStep = duration / countSteps
//            let angleStep = Double(abs(backStartAngle - previousAngle)) / countSteps
//            for i in 0..<4 {
//                let startTime: Double = durationOneStep * Double(i)
//                let relativeDuration = Double(durationOneStep)
//                UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: relativeDuration, animations: {
//                    self.arrowImageView.transform = CGAffineTransform(rotationAngle: previousAngle + CGFloat(angleStep * Double(i)))
//                })
//            }
//        }, completion: nil)
    }
    //
    internal func speedMeasurementDidMeasureSpeed(throughputs: [RMBTThroughput], inPhase phase: SpeedMeasurementPhase) {
        
        var kbps: Double = 0
        var l: Double    = 0

        //logger.debug("THROUGHPUTS COUNT: \(throughputs.count)")

        for i in 0 ..< throughputs.count {
            let t = throughputs[i]
            kbps = t.kilobitsPerSecond()

            //
            l = RMBTSpeedLogValue(min(kbps, /*RMBT_Test_MAX_CHART_KBPS*/200_000))
            
            if i == 0 {
            
                // Use last values for momentary display (gauge and label)
//                speedGaugeView.value = Float(l)
                self.targetSpeed = l
                updateStatusWithValue(text: RMBTSpeedMbpsString(kbps), phase: phase, final: false)
                
                let angle: CGFloat = 0 + (310 - 0) * CGFloat(l) - 8
                var backStartAngle = angle * CGFloat.pi / CGFloat(180.0)
                backStartAngle -= CGFloat.pi
                
                if backStartAngle < CGFloat.pi {
                    backStartAngle += 2 * CGFloat.pi
                }

                self.rotationArrow(to: backStartAngle)
                
                switch phase {
                case .down:
                    self.arrowImageView.isHidden = false
                    self.downResultLabel?.text = RMBTSpeedMbpsString(kbps, withMbps: false)
                    self.downloadBackgrounView?.graphView?.addValue(l, atTimeInterval: Double(t.endNanos) / Double(NSEC_PER_SEC))
                    speedGraphView?.addValue(l, atTimeInterval: Double(t.endNanos) / Double(NSEC_PER_SEC))
                case .up:
                    self.arrowImageView.isHidden = false
                    self.upResultLabel?.text = RMBTSpeedMbpsString(kbps, withMbps: false)
                    self.uploadBackgrounView?.graphView?.addValue(l, atTimeInterval: Double(t.endNanos) / Double(NSEC_PER_SEC))
                    uploadSpeedGraphView?.addValue(l, atTimeInterval: Double(t.endNanos) / Double(NSEC_PER_SEC))
                default:
                    self.arrowImageView.isHidden = true
                }
            }
        }

    }
    
    /// QOS
    //
    //
    internal func manageViewAfterQosStart() {
        
        qtMode = true
        swapViews()
        qualityGaugeView.value = 0
    }
    //
    internal func manageViewAfterQosUpdated(value: Int) {

        qualityGaugeView.value = Float(value)/100
        displayPercentage(finishedPercentage + value)
    }
    //
    internal func manageViewAfterQosGetList(list: [QosMeasurementType]) {
        
        // Init
        for i in 0 ..< list.count {
            let initStruct = QosTestStatus(testType: list[i], status: false)
            q_tableTitles.append(initStruct)
        }

        DispatchQueue.main.async {
            // reset frame (this would be too early in swapViews() because no qos titles would be present)
            
            self.resultsTable.frame = self.resultsTableQOSFrame
            
            self.resultsTable.reloadData()
            
            // scroll back to top
            self.resultsTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: false)
        }
    }
    //
    internal func manageViewAfterQosFinishedTest(type: QosMeasurementType) {
        //
        // Find the index
        for i in 0 ..< self.q_tableTitles.count {

            let item = self.q_tableTitles[i]

            if item.testType == type && !item.status {

                self.q_tableTitles[i].status = true

                //logger.debug("FINISHED: %@", item.testType.description)
                
                let cellIndex = IndexPath(item: i, section: 0)
                
                if let cell = self.resultsTable.cellForRow(at: cellIndex) as? RMBTTestTableViewCellQ {
                    
                    cell.aTestDidFinish()
                    
                    let theLastIndex = IndexPath(item: self.q_tableTitles.count - 1, section: 0)
                    
                    DispatchQueue.main.async {
                        // data
                        self.q_tableTitles.append(self.q_tableTitles.remove(at: i))
                        // visual
                        self.resultsTable.moveRow(at: cellIndex, to: theLastIndex) // reorder
                        
                    }
                }

            }
        }
    }
    
    ///
    internal func resetView () {
        self.testUI(isHidden: false)
        
        var myIP: IndexPath!
        
        for i in 0 ..< m_tableTitles.count {
            
            myIP = IndexPath(item: i, section: 1)
            
            var item = m_tableTitles[i]
            item.status = false
            item.value = ""
            
            m_tableTitles[i] = item
            
            if let cell = self.resultsTable.cellForRow(at: myIP) as? RMBTTestTableViewCellM {
                cell.resetSubviews()
            }
        }
    }
    
    ///
    internal func swapViews() {
        if qtMode { // prepare for qos tests
            self.textAnimator.startAnimation()
            self.qualityGaugeView?.removeFromSuperview()
            
            let qualityGaugeView = RMBTGaugeView(frame: speedGaugeView.frame, name: "test", startAngle: 0, endAngle: 310, ovalRect: speedGaugeView.bounds)
            view.addSubview(qualityGaugeView)
            
            qualityGaugeView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addConstraint(NSLayoutConstraint(item: qualityGaugeView, attribute: .centerX, relatedBy: .equal, toItem: mapButton, attribute: .centerX, multiplier: 1, constant: 0))

            self.view.addConstraint(NSLayoutConstraint(item: qualityGaugeView, attribute: .centerY, relatedBy: .equal, toItem: mapButton, attribute: .centerY, multiplier: 1, constant: 0))
            self.view.addConstraint(NSLayoutConstraint(item: mapButton, attribute: .width, relatedBy: .equal, toItem: qualityGaugeView, attribute: .width, multiplier: 1, constant: -30))
            self.view.addConstraint(NSLayoutConstraint(item: mapButton, attribute: .height, relatedBy: .equal, toItem: qualityGaugeView, attribute: .height, multiplier: 1, constant: -30))
            
            qualityGaugeView.clockWiseOrientation = false
            self.qualityGaugeView = qualityGaugeView
            
            speedGaugeView.isHidden = true
            speedLabel?.isHidden = true
            qosLabel.isHidden = false
//            if self.view.frameHeight > CGFloat(500.0) {
//                resultsTable.isHidden = false
//            }
            uploadSpeedGraphView?.isHidden = true
            speedGraphView?.isHidden = true
            arrowImageView.isHidden = true
            
            //self.speedGaugeView = nil // release the previous view view
        } else { // prepare for normal speed test // TODO: reset more views
            self.textAnimator.stopAnimation()
            if qualityGaugeView != nil {
                qualityGaugeView.isHidden = true
            }
            
            speedGaugeView.isHidden = false
            speedLabel?.isHidden = false
            qosLabel.isHidden = true
//            resultsTable.isHidden = true
            if self.view.frameHeight > CGFloat(500.0) {
                uploadSpeedGraphView?.isHidden = false
                speedGraphView?.isHidden = false
            }

            //
            resultsTable.frame = resultsTableSpeedtestFrame
            //
        }
    }
    
    ///
    private func percentageForPhase(_ phase: SpeedMeasurementPhase) -> Int {
        switch phase {
        case .Init:    return 14
        case .latency: return 10
        case .jitter:  return 10
        case .down:    return 30
        case .up:      return 36
        default:       return 0
        }
    }
    
    private func percentageAfterPhase(phase: SpeedMeasurementPhase) -> Int {
        switch phase {
        case .none:                 return 0
        //case .FetchingTestParams:
        case .wait:                 return 6
        case .Init:                 return 14
        case .latency:              return 24
        case .jitter:               return 34
        case .packLoss:             return 34
        case .down:                 return 64
        case .initUp:               return 64 // no visualization for init up
        case .up:                   return 100
        //
        case .submittingTestResult: return 100 // also no visualization for submission
        default:
            return 0
        }
    }
    
}
