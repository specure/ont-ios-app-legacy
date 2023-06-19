//
//  RMBTAboutViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11/6/18.
//  Copyright © 2018 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTAboutViewController: UIViewController {

    enum Mode {
        case title
        case sponsor
        case bigSponsor
        case visitUs
    }
    
    class Item {
        var text: String?
        var image: UIImage?
        var subtitle: String?
        var url: String?
        var mode: Mode = .title
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return RMBTColorManager.statusBarStyle
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var items: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let format = NSLocalizedString("RMBT-SETTINGS-ABOUT", comment: "About NettestX")
        self.title = String(format: format, RMBT_COMPANY_FOR_DATA_SOURCES)

        self.collectionView.register(cell: RMBTAboutTitleCell.ID)
        self.collectionView.register(cell: RMBTImageCell.ID)
        self.collectionView.register(cell: RMBTVisitUsCell.ID)
        
        self.prepareItems()
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
        self.collectionView.reloadData()
    }
    
    func prepareItems() {
        var items: [Item] = []
        
        let title = Item()
        let format = L("RMBT-ABOUT-TITLE")
        title.text = String(format: format, RMBT_COMPANY_FOR_DATA_SOURCES)
        items.append(title)
        
        let sponsor1 = Item()
        sponsor1.image = UIImage(named: "example")
        sponsor1.mode = .sponsor
        items.append(sponsor1)
        
        let sponsor2 = Item()
        sponsor2.image = UIImage(named: "example")
        sponsor2.mode = .sponsor
        items.append(sponsor2)
        
        let sponsor3 = Item()
        sponsor3.image = UIImage(named: "example")
        sponsor3.mode = .sponsor
        items.append(sponsor3)
        
        let sponsor4 = Item()
        sponsor4.image = UIImage(named: "example")
        sponsor4.mode = .sponsor
        items.append(sponsor4)
        
        let bigSponsor = Item()
        bigSponsor.image = UIImage(named: "example")
        bigSponsor.mode = .bigSponsor
        items.append(bigSponsor)
        
        let footer = Item()
        footer.text = ""
        footer.subtitle = L("RMBT-ABOUT-FOOTER-TEXT")
        footer.url = ""
        footer.mode = .visitUs
        items.append(footer)
        
        self.items = items
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
        self.updateColorForNavigationBarAndTabBar()
    }
    
    func applyColorScheme() {
        self.view.backgroundColor = UIColor.white
        self.collectionView.backgroundColor = UIColor.white
    }
    
    @objc func visitUs(_ sender: UIButton) {
        if let url = URL(string: "http://moqos.eu") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RMBTAboutViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = self.items[indexPath.row]
        if item.mode == .title {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMBTAboutTitleCell.ID, for: indexPath) as! RMBTAboutTitleCell
            cell.titleLabel.text = item.text
            cell.applyColorScheme()
            return cell
        }
        if item.mode == .sponsor || item.mode == .bigSponsor {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMBTImageCell.ID, for: indexPath) as! RMBTImageCell
            cell.imageView.image = item.image
            return cell
        }
        if item.mode == .visitUs {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMBTVisitUsCell.ID, for: indexPath) as! RMBTVisitUsCell
            cell.button.addTarget(self, action: #selector(visitUs(_:)), for: .touchUpInside)
            cell.subtitleLabel.text = item.subtitle
            cell.applyColorScheme()
            return cell
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: RMBTAboutTitleCell.ID, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = self.items[indexPath.row]
        if item.mode == .title {
            let width = collectionView.bounds.size.width - 60
            let font = UIFont.systemFont(ofSize: 12, weight: .regular)
            let height = item.text?.height(withConstrainedWidth: width, font: font) ?? 0.0
            return CGSize(width: width, height: height)
        }
        if item.mode == .sponsor {
            return CGSize(width: 105, height: 75)
        }
        if item.mode == .bigSponsor {
            let width = collectionView.bounds.size.width - 60
            return CGSize(width: width, height: 75)
        }
        if item.mode == .visitUs {
            let width = collectionView.bounds.size.width - 80
            let font = UIFont.systemFont(ofSize: 12, weight: .regular)
            let height = item.subtitle?.height(withConstrainedWidth: width, font: font) ?? 0.0
            return CGSize(width: width, height: height + 115)
        }
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 30, bottom: 20, right: 30)
    }
}
