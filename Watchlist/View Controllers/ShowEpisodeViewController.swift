//
//  ShowEpisodeViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 18/2/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import UIKit

class ShowEpisodeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var id: Int32?
    var episodes: [API_Episodes.Data]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TVDBAPI.getEpisodes(show: id!) {
            if let episodes = $0 {
                self.episodes = episodes

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 90
        tableView.layoutMargins = .zero
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        tableView.reloadData()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let episodes = self.episodes {
            return episodes.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SearchTableViewCell
        
        // TODO: Ensure episodes are in order (Season > Episode?, i.e. 1x01, 1x02, etc)
        if let episode = self.episodes {
//            cell.titleLabel.text = episode[indexPath.row].episodeName ?? "Unknown Episode Name"
//            cell.detailLabel.text = episode[indexPath.row].overview ?? "Unknown Episode Overview"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
