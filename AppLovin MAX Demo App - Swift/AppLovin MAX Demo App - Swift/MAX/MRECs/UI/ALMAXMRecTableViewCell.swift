//
//  ALMAXMRecTableViewCell.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Alan Cao on 6/27/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALMAXMRecTableViewCell: UITableViewCell
{
    var adView: MAAdView!
    
    private var isAdViewRemovedFromSubview = false
    
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
        (contentView.subviews.first as? MAAdView)?.removeFromSuperview()
        isAdViewRemovedFromSubview = true
    }
    
    func configure()
    {
        // MREC width and height are 300 and 250 respectively, on iPhone and iPad
        let height: CGFloat = 250
        let width: CGFloat = 300
        adView.frame = CGRect(x: contentView.frame.origin.x, y: contentView.frame.origin.y, width: width, height: height)
        
        // Center the MREC
        adView.center.x = contentView.center.x
        adView.center.y = contentView.center.y
    
        // Set background or background color for MREC ads to be fully functional
        adView.backgroundColor = .white
        
        // Avoid table view scrolling lag if adView hasn't been removed
        if isAdViewRemovedFromSubview
        {
            contentView.addSubview(adView)
        }
    }
}
