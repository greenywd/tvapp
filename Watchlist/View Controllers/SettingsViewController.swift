//
//  SettingsViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 26/2/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
	
	@IBOutlet weak var resetButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		resetButton.addTarget(self, action: #selector(resetPrefs), for: .touchUpInside)
		
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
    @objc func resetPrefs() {
		print("removing favourite shows...")
		userDefaults.removeObject(forKey: "favouriteShows")
	}
}
