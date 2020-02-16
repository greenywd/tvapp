//
//  SettingsRootViewController.swift
//  Seasons
//
//  Created by Thomas Greenwood on 15/2/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//

import Foundation
import UIKit

class SettingsRootViewController : UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44
    }
}
