//
//  ALDemoNativeAdFeedTableViewController.swift
//  iOS-SDK-Demo
//
//  Created by Thomas So on 9/25/15.
//  Copyright © 2015 AppLovin. All rights reserved.
//

import UIKit

class ALDemoNativeAdFeedTableViewController : UITableViewController
{
    let kArticleCellIdentifier = "articleCell"
    let kAdCellIdentifier      = "adCell"
    
    let kCellTagTitleLabel       = 2
    let kCellTagSubtitleLabel    = 3
    let kCellTagDescriptionLabel = 4
    
    var articles = [ALDemoArticle]()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        ALDemoRSSFeedRetriever.shared().startParsing(completion: { (error: Error?, articles: [ALDemoArticle]!) in
            
            DispatchQueue.main.async {
                
                guard error == nil && articles.count > 0 else {
                    
                    let alert = UIAlertController(title: "ERROR", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) -> Void in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
                
                self.articles = articles
                self.tableView.reloadData()
            }
        })
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return articles.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return articles[indexPath.row].isAd ? 360 : 280
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell: UITableViewCell!
        let article = articles[indexPath.row]
        
        if article.isAd
        {
            // You can configure carousels in ALCarouselViewSettings.h
            cell = tableView.dequeueReusableCell(withIdentifier: kAdCellIdentifier, for: indexPath)
        }
        else
        {
            cell = tableView.dequeueReusableCell(withIdentifier: kArticleCellIdentifier, for: indexPath)
            (cell.viewWithTag(kCellTagTitleLabel)       as! UILabel).text = article.title
            (cell.viewWithTag(kCellTagSubtitleLabel)    as! UILabel).text = article.creator + " - " + article.pubDate
            (cell.viewWithTag(kCellTagDescriptionLabel) as! UILabel).text = article.articleDescription
        }
        
        return cell
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        UIApplication.shared.openURL(articles[indexPath.row].link)
    }
}
