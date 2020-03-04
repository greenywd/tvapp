//
//  SettingsSupportTableViewController.swift
//  Seasons
//
//  Created by Thomas Greenwood on 4/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//

import Foundation
import UIKit

class SettingsSupportTableViewController : UITableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            print("Updating Shows")
            PersistenceService.updateShows()
        case 1:
            PersistenceService.updateEpisodes()
        case 2:
            let alert = UIAlertController(title: "Are you sure?", message: "This will remove all of your favourite shows. Would you like to continue?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                PersistenceService.dropTable()
            }))

            present(alert, animated: true, completion: nil)
            
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
