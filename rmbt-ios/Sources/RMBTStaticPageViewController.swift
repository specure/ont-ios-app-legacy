//
//  RMBTStaticPageViewController.swift
//  RMBT
//
//  Created by Polina Gurina on 10.06.2021.
//  Copyright © 2021 SPECURE GmbH. All rights reserved.
//

import UIKit
import MarkdownView

class RMBTStaticPageViewController: UIViewController {
    @IBOutlet weak var contentView:MarkdownView!
    @IBOutlet weak var spinnerView:UIActivityIndicatorView!

    let client = RMBTCmsApiClient()
    
    var route = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentView.backgroundColor = RMBTColorManager.tableViewBackground
        spinnerView.hidesWhenStopped = true
        spinnerView.startAnimating()
        contentView.setOnTouchLink(self)
        client.getPage(route: route, completion: { [weak self] page in
            DispatchQueue.main.async {
                self?.contentView.load(markdown: page.content)
                self?.navigationItem.title = page.name
                self?.spinnerView.stopAnimating()
            }
        })
    }
}
