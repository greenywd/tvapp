//
//  HomeViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 1/2/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

//view controller used for home tab - show favourite shows, etc

import Foundation
import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var x = Show(titles: ["Arrow"], ids: ["222222"], descriptions: ["Oliver Queen and his father are lost at sea when their luxury yacht sinks. His father doesn't survive. Oliver survives on an uncharted island for five years learning to fight, but also learning about his father's corruption and unscrupulous business dealings. He returns to civilization a changed man, determined to put things right. He disguises himself with the hood of one of his mysterious island mentors, arms himself with a bow and sets about hunting down the men and women who have corrupted his city."])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.separatorStyle = .none
        tableView.rowHeight = 50
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let cellIdentifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        let item = x.title[indexPath.row]
        let detailItem = x.description[indexPath.row]
        cell.textLabel?.text = item
        cell.detailTextLabel?.text = detailItem
        return cell

    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle{
		return .lightContent
	}
}
