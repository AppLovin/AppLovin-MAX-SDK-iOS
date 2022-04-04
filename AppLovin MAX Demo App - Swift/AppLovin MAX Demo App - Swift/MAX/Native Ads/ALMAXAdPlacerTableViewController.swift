//
//  ALMAXAdPlacerTableViewController.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Ritam Sarmah on 4/1/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALMAXAdPlacerTableViewController: UITableViewController
{
    private let data = UIFont.familyNames.sorted()
    
    private var adPlacer: MATableViewAdPlacer!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let settings = MAAdPlacerSettings(adUnitIdentifier: "YOUR_AD_UNIT_ID")
        settings.addFixedPosition(IndexPath(row: 2, section: 0))
        settings.addFixedPosition(IndexPath(row: 8, section: 0))
        settings.repeatingInterval = 10;
        
        // If using custom views, you must also set the `nativeAdViewNib` and `nativeAdViewBinder` properties on the ad placer
        
        adPlacer = MATableViewAdPlacer(tableView: tableView, settings: settings)
        adPlacer.delegate = self;
        adPlacer.loadAds()
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.al_dequeueReusableCell(withIdentifier: "ALMAXAdPlacerTableViewCell", for: indexPath)
        cell.textLabel!.text = data[indexPath.row]
        return cell
    }
}

extension ALMAXAdPlacerTableViewController: MAAdPlacerDelegate
{
    func didLoadAd(at indexPath: IndexPath) {}
    
    func didRemoveAds(at indexPaths: [IndexPath]) {}

    func didClick(_ ad: MAAd) {}
    
    func didPayRevenue(for ad: MAAd) {}
}
