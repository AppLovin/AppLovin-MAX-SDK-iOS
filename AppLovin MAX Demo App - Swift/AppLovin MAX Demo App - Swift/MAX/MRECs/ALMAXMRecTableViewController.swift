//
//  ALMAXMRecTableViewController.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Alan Cao on 6/27/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALMAXMRecTableViewController: UIViewController
{
    private let kAdViewCount = 5
    private let kAdInterval = 10
    private var adViews: [MAAdView] = []
    private var sampleData: [String] = UIFont.familyNames
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Configure table view
        tableView.delegate = self
        tableView.dataSource = self
        
        configureAdViews(count: kAdViewCount)
    }
    
    private func configureAdViews(count: Int)
    {
        tableView.beginUpdates()
        
        for i in stride(from: 0, to: sampleData.count, by: kAdInterval)
        {
            sampleData.insert("", at: i)
            tableView.insertRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
        }
        
        tableView.endUpdates()
        
        for _ in 0 ..< count
        {
            let adView = MAAdView(adUnitIdentifier: "YOUR_AD_UNIT_ID", adFormat: .mrec)
            adView.delegate = self
            
            // Set this extra parameter to work around SDK bug that ignores calls to stopAutoRefresh()
            adView.setExtraParameterForKey("allow_pause_auto_refresh_immediately", value: "true")
            adView.stopAutoRefresh()
            
            // Load the ad
            adView.loadAd()
            adViews.append(adView)
        }
    }
}

// MARK: UITableView

extension ALMAXMRecTableViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return sampleData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        if indexPath.row % kAdInterval == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ALMAXMRecTableViewCell", for: indexPath) as! ALMAXMRecTableViewCell
            
            // Select an ad view to display
            let adView = adViews[(indexPath.row / kAdInterval) % kAdViewCount]
            
            // Configure cell with an ad
            cell.configure(with: adView)
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
            cell.textLabel!.text = sampleData[indexPath.row]
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if let cell = cell as? ALMAXMRecTableViewCell
        {
            cell.stopAutoRefresh()
        }
    }
}

// MARK: MAAdViewAdDelegate Protocol

extension ALMAXMRecTableViewController: MAAdViewAdDelegate
{
    func didLoad(_ ad: MAAd) {}
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {}
    
    func didClick(_ ad: MAAd) {}
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {}
    
    func didExpand(_ ad: MAAd) {}
    
    func didCollapse(_ ad: MAAd) {}
    
    // MARK: Deprecated Callbacks
    
    func didDisplay(_ ad: MAAd) { /* DO NOT USE - THIS IS RESERVED FOR FULLSCREEN ADS ONLY AND WILL BE REMOVED IN A FUTURE SDK RELEASE */ }
    func didHide(_ ad: MAAd) { /* DO NOT USE - THIS IS RESERVED FOR FULLSCREEN ADS ONLY AND WILL BE REMOVED IN A FUTURE SDK RELEASE */ }
}
