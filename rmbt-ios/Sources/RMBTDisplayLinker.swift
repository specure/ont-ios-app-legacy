//
//  RMBTDisplayLinker.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 9/23/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

protocol RMBTDisplayLinkerDelegate: AnyObject {
    func updateDisplay(with duration: CGFloat)
}

class RMBTDisplayLinker: NSObject {
    static let shared = RMBTDisplayLinker()
    
    var displayLink: CADisplayLink? {
        didSet {
            oldValue?.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
            oldValue?.invalidate()
        }
    }
    
    private var delegates: [RMBTWeakObserver] = []
    
    override init() {
        super.init()
        let backgroundNotification = UIApplication.didEnterBackgroundNotification
        let foregroundNotification = UIApplication.willEnterForegroundNotification
        NotificationCenter.default.addObserver(self, selector: #selector(startUpdate(_:)), name: foregroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopUpdate(_:)), name: backgroundNotification, object: nil)
        self.startUpdate(nil)
    }
    
    @objc func startUpdate(_ notification: Notification?) {
        displayLink = CADisplayLink(target: self, selector: #selector(updateDisplay(_:)))
        displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    }
    
    @objc func stopUpdate(_ notification: Notification) {
        displayLink = nil
    }
    
    @objc func updateDisplay(_ sender: Any) {
        for delegate in delegates {
            if let d = delegate.delegate as? RMBTDisplayLinkerDelegate {
                var duration: CGFloat = 0
                if let sender = sender as? CADisplayLink {
                    duration = CGFloat(sender.duration)
                }
                d.updateDisplay(with: duration)
            }
        }
    }
    
    func addObserver(_ observer: NSObject) {
        let weakObserver = RMBTWeakObserver(observer)
        self.delegates.append(weakObserver)
        
        self.clearObservers()
    }
    
    func removeObserver(_ object: NSObject) {
        let observers = self.delegates
        for observer in observers where observer.delegate == object {
            if let index = delegates.firstIndex(of: observer) {
                self.delegates.remove(at: index)
            }
        }
        
        self.clearObservers()
    }
    
    private func clearObservers() {
        let observers = self.delegates
        for observer in observers where observer.delegate == nil {
            if let index = delegates.firstIndex(of: observer) {
                self.delegates.remove(at: index)
            }
        }
    }
}
