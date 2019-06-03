//
//  ShowEpisodeViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 18/2/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import UIKit

class ShowEpisodeViewController: UITableViewController {
    
    var id: Int32?
    var episodes: [Episode]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if episodes == nil {
        TVDBAPI.getEpisodes(show: id!) {
            if let episodes = $0 {
                self.episodes = episodes

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        }
        
        dump(episodes!)
        
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let episodes = self.episodes {
            return episodes.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // TODO: Ensure episodes are in order (Season > Episode?, i.e. 1x01, 1x02, etc)
        if let episodes = self.episodes {
            cell.textLabel!.text = episodes[indexPath.row].episodeName ?? "Unknown Episode Name"
            cell.detailTextLabel!.text = episodes[indexPath.row].overview ?? "Unknown Episode Overview"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
