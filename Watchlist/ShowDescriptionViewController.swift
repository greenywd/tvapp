//
//  ShowDescriptionViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 14/5/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation
import UIKit

class ShowDescriptionViewController : UIViewController {
    var showDescriptionString: String!
    @IBOutlet var showDescription: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.bottomAnchor.constraint(equalTo: showDescription.bottomAnchor).isActive = true
        
        // showDescription.preferredMaxLayoutWidth = view.bounds.width
        showDescription.text = showDescriptionString
        //showDescription.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum porta nulla eget gravida interdum. Nullam finibus sodales velit nec consequat. Duis elementum aliquam nibh, et bibendum elit. Praesent fermentum viverra metus vitae elementum. Sed at aliquam massa. Nulla tempor diam sit amet mauris pulvinar, sed ullamcorper nunc ullamcorper. Praesent a tortor ornare, congue velit sit amet, vulputate felis. In dolor tortor, tempor vitae laoreet ac, tristique tristique nunc. Nullam molestie iaculis tempor. Sed scelerisque pretium cursus. Donec mattis posuere nulla, eget ullamcorper nulla ornare dignissim. Etiam ut pharetra nunc. Etiam consequat aliquam justo ac tincidunt. Sed consectetur iaculis diam vel eleifend. Sed ac velit dolor. Quisque libero orci, porttitor sit amet sapien eget, faucibus convallis purus. Sed ipsum urna, malesuada et rhoncus ac, tempor non sapien. Morbi non urna et mi accumsan porta id id dolor. Nulla porttitor interdum orci nec commodo. Aenean semper ultrices nulla, vitae aliquet felis posuere vel. Cras faucibus nulla nec risus porttitor, et feugiat nulla porta. Aenean ornare turpis quis dapibus luctus. Donec efficitur dapibus aliquet. Curabitur volutpat mauris gravida nibh elementum facilisis. Morbi vitae quam lacus. Praesent facilisis blandit augue ut volutpat. Vestibulum dignissim pellentesque cursus. Curabitur commodo mollis ligula, eget tincidunt urna blandit eget. Duis augue leo, laoreet quis pharetra in, tempor ut nisi. Integer in tortor et erat rutrum luctus vitae a metus. Integer malesuada, ligula ut volutpat aliquam, justo diam efficitur massa, id efficitur dolor sapien quis neque. In lobortis lacus eget vehicula porta. Sed sodales diam sed mattis bibendum. Donec vestibulum metus at posuere fringilla. Nulla facilisi. Morbi ex eros, vehicula nec justo at, hendrerit venenatis eros. Ut elit odio, finibus et mi vitae, consequat euismod dui. Pellentesque vehicula quam maximus iaculis euismod. Nullam ut eros at arcu eleifend fermentum eu non quam. Sed aliquam porttitor pulvinar. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Sed tempus eleifend bibendum. Nam laoreet tempor ante, at commodo leo imperdiet vitae. Donec ullamcorper fermentum leo, vitae venenatis justo tincidunt vitae. Pellentesque nec semper elit. Fusce fringilla ipsum enim, eget tincidunt nunc convallis eu. Etiam ut elit consectetur, ultricies diam vel, blandit nisl. Etiam et leo lorem. Donec scelerisque vestibulum nisi et imperdiet. Donec congue feugiat purus. Nunc pharetra tellus justo, vel posuere mauris vulputate ut. Quisque condimentum malesuada mattis. Duis rhoncus lorem eget justo laoreet laoreet. Nulla eget sodales neque. Fusce vitae ullamcorper justo, nec convallis diam. Aenean sed urna vitae nisi ullamcorper cursus. Sed nisi nisl, aliquet at sollicitudin eu, vulputate nec lorem. Proin a euismod sapien, suscipit iaculis nunc. Cras sapien neque, dapibus eu mollis vel, eleifend sed erat. Maecenas vitae lectus sed ex semper placerat nec ac massa. Nam dignissim metus et nisi eleifend, molestie rhoncus arcu hendrerit. Duis suscipit nibh a dictum dictum. Pellentesque nec velit nec nulla mollis auctor. Nunc quis turpis ante. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. In a dapibus urna, sit amet blandit enim. In porta augue est, nec tincidunt ipsum tristique nec. Aenean et tincidunt massa. Aliquam porta sagittis ligula sit amet tempor."
    }
}
