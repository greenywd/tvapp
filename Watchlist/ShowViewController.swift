//
//  ShowViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 13/1/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

//view controller used to display details of shows

import Foundation
import UIKit

var detailsForController = detailsOfShow

class ShowViewController: UIViewController {
	
	//MARK: Properties
	
    //@IBOutlet var showScrollView: UIScrollView?
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    @IBOutlet var bannerImage: UIImageView?
    @IBOutlet var descriptionOfShow: UILabel?
    @IBOutlet var descriptionLabel: UILabel?
    @IBOutlet weak var barItem: UITabBar!
    
    let API = TVDBAPI()
	
	
	
	//MARK: Methods
	
    override func viewDidLoad() {
        super.viewDidLoad()

		
		DispatchQueue.global().async {

			print("\(self): \(cellTappedForShowID)")
			self.API.getDetailsOfShow(id: cellTappedForShowID)
			
			DispatchQueue.main.sync {

				print(detailsForController["name"] as? String!)
				self.navigationItem.title = detailsForController["name"] as? String
			}
		}
		
		//print(cellTappedForShowID)
        //API.getDetailsOfShow(id: cellTappedForShowID)
        
        self.activityIndicator?.hidesWhenStopped = true
        self.activityIndicator?.startAnimating()
		//print(detailsForController["name"])
		self.navigationItem.title = "test"
        _ = seriesName?.rawString()
        
        self.descriptionOfShow?.text = "Matt Murdock, with his other senses superhumanly enhanced, fights crime as a blind lawyer by day, and vigilante by night."
        //self.descriptionOfShow?.textColor = UIColor.white
        //self.descriptionLabel?.textColor = UIColor.white
		
		
        //self.navigationController?.isNavigationBarHidden = false
        
    }
    
    override func didReceiveMemoryWarning() {
        //do stuff
    }
    
    //override var preferredStatusBarStyle: UIStatusBarStyle {
        //return .lightContent
    //}
}
