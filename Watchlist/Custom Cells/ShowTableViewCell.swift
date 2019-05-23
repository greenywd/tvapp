//
//  DescriptionTableViewCell.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 16/2/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import UIKit

class ShowTableViewCell: UITableViewCell {

    enum CellType : String {
        case Default, Description, Episodes, Actors
    }
    
    @IBOutlet var header: UILabel!
	@IBOutlet var content: UILabel!
    
    public var type: CellType = .Default {
        didSet {
            update()
        }
    }
    public var showDescription: String? {
        didSet {
            update()
        }
    }
    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        self.type = .Default
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }
    
//    required init?(coder aDecoder: NSCoder) {
//        self.type = .Default
//        super.init(coder: aDecoder)
//    }
//
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        header.textColor = .white
        content.textColor = .white
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        self.header.text = type.rawValue
        switch type {
        case .Description:
            content.text = showDescription
            
            if (content.maxNumberOfLines > 7) {
                print(content.maxNumberOfLines)
                content.numberOfLines = 7
                content.lineBreakMode = .byTruncatingTail
                isUserInteractionEnabled = true
                accessoryType = .disclosureIndicator
            }
            
        case .Episodes:
            content.text = nil
            
            isUserInteractionEnabled = true
            accessoryType = .disclosureIndicator
            
        case .Actors:
            break
        default:
            break
            
        }
    }
}
