//
//  RMBTSelectListItemsViewController.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 12/1/17.
//  Copyright © 2017 SPECURE GmbH. All rights reserved.
//

import UIKit

class RMBTSelectListItemsViewController: UIViewController {
    var items: [[String: Any]] = []
    var selectedItem: Any?
    var onDidSelectHandler: (_ value: Any?) -> Void = { _ in }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return RMBTColorManager.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RMBTSelectListItemsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        self.onDidSelectHandler(item.values.first)
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = self.items[indexPath.row]
        cell.textLabel?.text = item.keys.first
        cell.tintColor = RMBTColorManager.tintColor
        cell.textLabel?.textColor = RMBTColorManager.tintColor
        cell.backgroundColor = RMBTColorManager.cellBackground
        
        tableView.backgroundColor = RMBTColorManager.tableViewBackground
        tableView.separatorColor = RMBTColorManager.tableViewSeparator
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        if let value = item.values.first as? NSObject,
            let selectedItem = self.selectedItem as? NSObject,
            selectedItem == value {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}
