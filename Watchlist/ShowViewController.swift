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

class ShowViewController: UIViewController {
    
    //@IBOutlet var showScrollView: UIScrollView?
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    @IBOutlet var bannerImage: UIImageView?
    @IBOutlet var descriptionOfShow: UILabel?
    
    //let API = TVDBAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //API.getShow(id: "281662")
        
        self.activityIndicator?.hidesWhenStopped = true
        self.activityIndicator?.startAnimating()

        let title = seriesName?.rawString()
        print(title!)
        
        self.descriptionOfShow?.text = "Matt Murdock, with his other senses superhumanly enhanced, fights crime as a blind lawyer by day, and vigilante by night."
        
        let url = URL(string: "https://thetvdb.com/banners/fanart/original/281662-7.jpg")
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                self.bannerImage?.image = UIImage(data: data!)
                self.activityIndicator?.stopAnimating()
            }
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        //do stuff
    }
}
