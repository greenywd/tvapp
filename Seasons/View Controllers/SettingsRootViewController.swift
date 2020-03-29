//
//  SettingsRootViewController.swift
//  Seasons
//
//  Created by Thomas Greenwood on 15/2/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class SettingsRootViewController : UITableViewController, SFSafariViewControllerDelegate {
    @IBOutlet weak var themeSegmentedControl: UISegmentedControl!
    @IBAction func themeSegmentedControlAction(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "theme")
        for window in UIApplication.shared.windows {
            window.overrideUserInterfaceStyle = UIUserInterfaceStyle.init(rawValue: sender.selectedSegmentIndex)!
        }
    }
    @IBAction func resolutionSegmentedControlAction(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(Bool(truncating: NSNumber(value: sender.selectedSegmentIndex)), forKey: "preferFullHD")
    }
    @IBOutlet weak var resolutionSegmentedControl: UISegmentedControl!
    @IBOutlet var episodeAirSwitch: UISwitch!
    @IBAction func episodeAirAction(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "sendEpisodeNotifications")
    }
    @IBAction func doneBarButtonItemAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var wasPresentedViaModel = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (wasPresentedViaModel == false) {
            self.navigationController?.navigationBar.items = nil
        }
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44
     
        self.themeSegmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "theme")
        self.resolutionSegmentedControl.selectedSegmentIndex = Int(truncating: UserDefaults.standard.bool(forKey: "preferFullHD") as NSNumber)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 2 && indexPath.row == 0) {
            let sfvc = SFSafariViewController(url: URL(string: "https://www.github.com/greenywd/tvapp/issues")!)
            sfvc.delegate = self
            present(sfvc, animated: true, completion: nil)
        }
    }
}
