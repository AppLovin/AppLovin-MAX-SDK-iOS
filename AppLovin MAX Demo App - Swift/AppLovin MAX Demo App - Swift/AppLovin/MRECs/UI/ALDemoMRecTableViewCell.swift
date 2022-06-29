//
//  ALDemoMRecTableViewCell.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Alan Cao on 6/27/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALDemoMRecTableViewCell: UITableViewCell
{
    private var adView: MAAdView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        // Make sure ads aren't being configured to the wrong cells
        textLabel?.text = nil
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    func configure(with adView: MAAdView)
    {        
        // MREC width and height are 300 and 250 respectively, on iPhone and iPad
        let height: CGFloat = 250
        let width: CGFloat = 300
        adView.frame = CGRect(x: contentView.frame.origin.x, y: contentView.frame.origin.y, width: width, height: height)
        
        // Center the MREC
        adView.center.x = contentView.center.x
    
        // Set background or background color for MREC ads to be fully functional
        adView.backgroundColor = .white
        
        contentView.addSubview(adView)
    }
}
