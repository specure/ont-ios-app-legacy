//
//  RMBTLoopModeResult.swift
//  RMBT_ONT
//
//  Created by Sergey Glushchenko on 8/18/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTLoopModeResult {
    
    enum FinishedStatus {
        case started
        case cancelled
        case finished
    }
    
    var ping: String?
    var jitter: String?
    var packetLoss: String?
    var up: String?
    var down: String?
    var qosPassed: Int?
    var qosFailed: Int?
    var qosPerformed: Int?
    
    var finishedStatus: FinishedStatus = .started
    
    var isFinished: Bool {
        get {
            return finishedStatus == .finished
        }
        set {
            finishedStatus = newValue ? .finished : .started
        }
    }
    
    func convertToStates(for items: [RMBTLoopModeViewController.RMBTLoopModeState]) -> [RMBTLoopModeViewController.RMBTLoopModeState] {
        return items.map { (item) -> RMBTLoopModeViewController.RMBTLoopModeState in
            guard let identifier = item.identifier,
                let state = RMBTLoopModeViewController.State(rawValue: identifier)
            else { return RMBTLoopModeViewController.RMBTLoopModeState() }
            
            switch state {
            case .download:
                item.currentValue = self.down
                return item
            case .upload:
                item.currentValue = self.up
                return item
            case .Init:
                return item
            case .ping:
                item.currentValue = self.ping
                return item
            case .qos:
                item.currentValue = "\(self.qosPassed ?? 0)/\(self.qosPerformed ?? 0)"
                return item
            case .packetLose:
                item.currentValue = self.packetLoss
                return item
            case .jitter:
                item.currentValue = self.jitter
                return item
            }
        }
    }
}
