//
//  ALHomeViewController.swift
//  DemoApp-Swift
//
//  Created by Andrew Tian on 9/20/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALHomeViewController: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.setToolbarHidden(self.hidesBottomBarWhenPushed, animated: true)
        addFooterLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        self.navigationController?.setToolbarHidden(true, animated: false)
        super.viewWillDisappear(animated)
    }

    func addFooterLabel()
    {
        let footer = UILabel()
        footer.font = UIFont.systemFont(ofSize: 14)
        footer.numberOfLines = 0
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let sdkVersion = ALSdk.version()
        let systemVersion = UIDevice.current.systemVersion
        let text = "App Version: \(appVersion)\nSDK Version: \(sdkVersion)\niOS Version: \(systemVersion)\n\nLanguage: Swift"
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.minimumLineHeight = 20
        footer.attributedText = NSAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle : style])
        
        var frame = footer.frame
        frame.size.height = footer.sizeThatFits(CGSize(width: footer.frame.width, height: CGFloat.greatestFiniteMagnitude)).height + 60
        footer.frame = frame
        tableView.tableFooterView = footer
    }
    
    @IBAction func showMediationDebugger(_ sender: UIBarButtonItem!)
    {
        ALSdk.shared()!.showMediationDebugger()
    }
}

