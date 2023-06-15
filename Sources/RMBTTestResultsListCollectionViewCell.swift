//
//  RMBTTestResultsListCollectionViewCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11/28/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTTestResultsListCollectionViewCell: UICollectionViewCell {

    static let ID = "RMBTTestResultsListCollectionViewCell"
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var items: [RMBTTestViewController.RMBTTestState] = [] {
        didSet {
            if self.items.count > 3 {
                self.widthConstraint.constant = 475
                let rows = ceil(Double(self.items.count) / 3.0)
                self.heightConstraint.constant = CGFloat(rows * 155)
            } else {
                self.widthConstraint.constant = CGFloat(self.items.count) * (155 + 2.5)
                self.heightConstraint.constant = 155
            }
        }
    }
    var testResult: RMBTLoopModeResult = RMBTLoopModeResult()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.register(cell: RMBTTestResultsCollectionViewCell.ID)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
    }
    
    func applyColorScheme() {
        self.backgroundColor = RMBTColorManager.background
        self.collectionView.backgroundColor = RMBTColorManager.background
    }
}

extension RMBTTestResultsListCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = self.items[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMBTTestResultsCollectionViewCell.ID, for: indexPath) as! RMBTTestResultsCollectionViewCell

        var align: NSTextAlignment = (indexPath.row % 2 == 0) ? .right : .left
        if UIDevice.isDeviceTablet() {
            let a = self.items.count % 3
            if indexPath.row < self.items.count - a {
                if indexPath.row % 3 == 0 {
                    align = .right
                } else if indexPath.row % 3 == 1 {
                    align = .justified
                } else if indexPath.row % 3 == 2 {
                    align = .left
                }
            } else {
                if self.items.count % 3 == 2 {
                    if indexPath.row % 3 == 0 {
                        align = .right
                    } else if indexPath.row % 3 == 1 {
                        align = .left
                    }
                } else if self.items.count % 3 == 1 {
                    align = .justified
                }
            }
        } else {
            if self.items.count % 2 != 0 {
                if indexPath.row == self.items.count - 1 {
                    align = .justified
                }
            }
        }
        cell.modelView = RMBTTestResultsCollectionViewCell.RMBTTestResultsModelView(item: item, testResult: self.testResult, align: align)
        cell.applyColorScheme()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.isDeviceTablet() {
            let sideCellSize = (collectionView.bounds.size.width - 155 - 10) / 2
            let a = self.items.count % 3
            if indexPath.row < self.items.count - a {
                if indexPath.row % 3 == 0 {
                    return CGSize(width: sideCellSize, height: 155)
                } else if indexPath.row % 3 == 1 {
                    return CGSize(width: 155, height: 155)
                } else if indexPath.row % 3 == 2 {
                    return CGSize(width: sideCellSize, height: 155)
                }
            } else {
                if self.items.count % 3 == 2 {
                    let sideCellSize = (collectionView.bounds.size.width - 5) / 2
                    if indexPath.row % 3 == 0 {
                        return CGSize(width: sideCellSize, height: 155)
                    } else if indexPath.row % 3 == 1 {
                        return CGSize(width: sideCellSize, height: 155)
                    }
                } else if self.items.count % 3 == 1 {
                    let sideCellSize = collectionView.bounds.size.width / 2
                    return CGSize(width: sideCellSize, height: 155)
                }
            }
            return CGSize(width: 155, height: 155)
        } else {
            if self.items.count % 2 == 0 {
                return CGSize(width: collectionView.bounds.size.width / 2 - 2.5, height: 155)
            } else {
                if indexPath.row == self.items.count - 1 {
                    return CGSize(width: collectionView.bounds.size.width, height: 155)
                } else {
                    return CGSize(width: collectionView.bounds.size.width / 2 - 2.5, height: 155)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets()
    }
}
