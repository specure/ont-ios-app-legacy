//
//  RMBTTextAnimator.swift
//
//  Created by Sergey Glushchenko on 10/2/17.
//  Copyright © 2017 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTTextAnimator: NSObject {

    var values: [String] = []
    var descriptions: [String] = [] //Shold be same count with titles
    var title = ""
    
    var timerShow: Timer?
    var timerHide: Timer?
    var durationShow = 3.0
    var durationHide = 1.0
    var fadeDuration = 0.3
    
    weak var titleLabel: UILabel? {
        didSet {
            titleLabel?.alpha = 0.0
        }
    }
    weak var descriptionLabel: UILabel? {
        didSet {
            descriptionLabel?.alpha = 0.0
        }
    }
    
    private var isShowed = false
    private var index = 0
    private var isStarted = false
    
    func startAnimation() {
        if timerShow?.isValid == true {
            timerShow?.invalidate()
        }
        if timerHide?.isValid == true {
            timerHide?.invalidate()
        }
        timerShow = Timer.scheduledTimer(timeInterval: self.durationShow, target: self, selector: #selector(tick(timer:)), userInfo: nil, repeats: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + (self.durationShow - self.durationHide)) {
            if self.isStarted == true {
                self.timerHide = Timer.scheduledTimer(timeInterval: self.durationShow, target: self, selector: #selector(self.tick(timer:)), userInfo: nil, repeats: true)
                self.tick(timer: self.timerHide)
            }
        }
        
        self.isStarted = true
        self.isShowed = false
        self.index = 0
        self.titleLabel?.alpha = 0.0
        self.descriptionLabel?.alpha = 0.0
        self.tick(timer: timerShow)
    }
    
    func stopAnimation() {
        self.isStarted = false
        self.titleLabel?.alpha = 0.0
        self.descriptionLabel?.alpha = 0.0
        if timerShow?.isValid == true {
            timerShow?.invalidate()
        }
        if timerHide?.isValid == true {
            timerHide?.invalidate()
        }
    }
    
    @objc func tick(timer: Timer?) {
        if isShowed == false {
            isShowed = true
            if self.values.count > self.index {
                let value = self.values[self.index]
                let description = self.descriptions[self.index]
                self.titleLabel?.text = self.title + value
                self.descriptionLabel?.text = description
            }
            self.index += 1
            if self.values.count - 1 < self.index {
                self.index = 0
            }
            UIView.animate(withDuration: self.fadeDuration, animations: {
                self.titleLabel?.alpha = 1.0
                self.descriptionLabel?.alpha = 1.0
            })
        } else {
            isShowed = false
            UIView.animate(withDuration: self.fadeDuration, animations: {
                self.titleLabel?.alpha = 0.0
                self.descriptionLabel?.alpha = 0.0
            })
        }
    }
    
}
