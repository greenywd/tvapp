//
//  SettingsViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 26/2/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import UIKit
import SwiftUI

class SettingsViewController: UIViewController {
    @IBSegueAction func showSettingsView(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: SettingsView())
    }
}
