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
		
		//self.activityIndicator?.hidesWhenStopped = true
		self.activityIndicator?.startAnimating()
		
		DispatchQueue.global().async {

			print("\(self): \(cellTappedForShowID)")
			self.API.getDetailsOfShow(id: cellTappedForShowID, callback: { data, artworkURL, error in
				guard let data = data else {
					print("ERROR: \(error ?? "error not found" as! Error)")
					return
				}
				print("Data: \(data)")
				
				//TODO: add ui stuff here
				self.navigationItem.title = detailsForController["name"] as? String
				self.descriptionOfShow?.text = detailsForController["description"] as? String
				
				print("WAT2HEK: \(artworkURL!)")
				
				//FIXME: throwin nil
				let dataForImage = try? Data(contentsOf: URL(string: artworkURL!)!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
				// THE URL IS BAD (only showing relative url, need to add everything else
				
				DispatchQueue.main.async {
					self.bannerImage?.image = UIImage(data: dataForImage!)
					print("WAT2HEK")
				}
				
				
				self.activityIndicator?.stopAnimating()
			})
		}
        
    }
    
    override func didReceiveMemoryWarning() {
        //do stuff
    }
    
    //override var preferredStatusBarStyle: UIStatusBarStyle {
        //return .lightContent
    //}
}
