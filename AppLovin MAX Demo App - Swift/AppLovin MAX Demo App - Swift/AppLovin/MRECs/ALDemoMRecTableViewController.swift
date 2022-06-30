//
//  ALDemoMRecTableViewController.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Alan Cao on 6/27/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALDemoMRecTableViewController : UIViewController
{
    private var adViewQueue: [MAAdView] = []
    private var sampleData = Array("ABCDEFGHIJKL").map { String($0) }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
 
        // Configure table view
        tableView.al_delegate = self
        tableView.al_dataSource = self
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = 250
        
        configureAdViews(count: 5)
    }
    
    private func configureAdViews(count: Int)
    {
        for _ in 0 ..< count
        {
            let adView = MAAdView(adUnitIdentifier: "YOUR_AD_UNIT_ID", adFormat: .mrec)
            adView.delegate = self
            
            // Set this extra parameter to work around SDK bug that ignores calls to stopAutoRefresh()
            adView.setExtraParameterForKey("allow_pause_auto_refresh_immediately", value: "true")
            adView.stopAutoRefresh()
            
            // Load the ad
            adView.loadAd()
            adViewQueue.append(adView)
        }
    }
}

extension ALDemoMRecTableViewController : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return sampleData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ALDemoMRecTableViewCell", for: indexPath) as! ALDemoMRecTableViewCell
        
        if indexPath.section % 4 == 0, !adViewQueue.isEmpty
        {
            let adView = adViewQueue.removeFirst()
            adView.startAutoRefresh()
            cell.adView = adView
            cell.configure() // Configure cell with an ad
            adViewQueue.append(adView)
        }
        else
        {
            cell.textLabel!.text = sampleData[indexPath.section] // Configure custom cells
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        guard let cell = cell as? ALDemoMRecTableViewCell, cell.adView != nil else { return }
        
        // Set this extra parameter to work around SDK bug that ignores calls to stopAutoRefresh()
        cell.adView.setExtraParameterForKey("allow_pause_auto_refresh_immediately", value: "true")
        cell.adView.stopAutoRefresh()
    }
}

extension ALDemoMRecTableViewController : MAAdViewAdDelegate
{
    func didLoad(_ ad: MAAd)
    {
        tableView.al_reloadData()
    }

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {}

    func didClick(_ ad: MAAd) {}

    func didFail(toDisplay ad: MAAd, withError error: MAError) {}

    // MARK: MAAdViewAdDelegate Protocol

    func didExpand(_ ad: MAAd) {}

    func didCollapse(_ ad: MAAd) {}

    // MARK: Deprecated Callbacks

    func didDisplay(_ ad: MAAd) { /* DO NOT USE - THIS IS RESERVED FOR FULLSCREEN ADS ONLY AND WILL BE REMOVED IN A FUTURE SDK RELEASE */ }
    func didHide(_ ad: MAAd) { /* DO NOT USE - THIS IS RESERVED FOR FULLSCREEN ADS ONLY AND WILL BE REMOVED IN A FUTURE SDK RELEASE */ }
}
