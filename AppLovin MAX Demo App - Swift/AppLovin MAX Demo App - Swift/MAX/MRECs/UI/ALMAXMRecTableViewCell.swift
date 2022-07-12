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
    private var adView: MAAdView!
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        adView?.removeFromSuperview()
        adView = nil
    }
    
    func configure(with adView: MAAdView)
    {
        self.adView = adView
        self.adView.backgroundColor = .black
        self.adView.translatesAutoresizingMaskIntoConstraints = false
        self.adView.startAutoRefresh()
        
        contentView.addSubview(self.adView)
        NSLayoutConstraint.activate([
            self.adView.widthAnchor.constraint(equalToConstant: 300),
            self.adView.heightAnchor.constraint(equalToConstant: 250),
            self.adView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            self.adView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            self.adView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }
    
    func stopAutoRefresh()
    {
        adView?.setExtraParameterForKey("allow_pause_auto_refresh_immediately", value: "true")
        adView?.stopAutoRefresh()
    }
}
