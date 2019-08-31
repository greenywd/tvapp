//
//  SwiftUIHelpers.swift
//  Seasons
//
//  Created by Thomas Greenwood on 31/8/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import UIKit
import SwiftUI

class SwiftUIHelpers : UIViewController {
    @IBSegueAction func showSettingsView(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: SettingsView())
    }
}
