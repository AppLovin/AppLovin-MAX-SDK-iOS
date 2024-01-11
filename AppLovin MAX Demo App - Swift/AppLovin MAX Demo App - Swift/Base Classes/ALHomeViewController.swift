//
//  ALHomeViewController.swift
//  DemoApp-Swift
//
//  Created by Andrew Tian on 9/20/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

import AppLovinSDK
import MessageUI
import SafariServices
import UIKit

class ALHomeViewController: UITableViewController
{
    static let kSupportLink = "https://support.applovin.com/hc/en-us"
    
    @IBOutlet var muteToggle: UIBarButtonItem!
    @IBOutlet weak var mediationDebuggerCell: UITableViewCell!
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        .lightContent
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationController?.setToolbarHidden(hidesBottomBarWhenPushed, animated: true)
        addFooterLabel()
        muteToggle.image = muteIconForCurrentSdkMuteSetting()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        navigationController?.setToolbarHidden(true, animated: false)
        super.viewWillDisappear(animated)
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView.cellForRow(at: indexPath) == mediationDebuggerCell
        {
            ALSdk.shared()!.showMediationDebugger()
        }
        
        if indexPath.section == 1
        {
            if indexPath.row == 0
            {
                openSupportSite()
            }
        }
    }
    
    func addFooterLabel()
    {
        let footer = UILabel()
        footer.font = UIFont.systemFont(ofSize: 14)
        footer.numberOfLines = 0
        
        let sdkVersion = ALSdk.version()
        let systemVersion = UIDevice.current.systemVersion
        let text = "SDK Version: \(sdkVersion)\niOS Version: \(systemVersion)\n\nLanguage: Swift"
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.minimumLineHeight = 20
        footer.attributedText = NSAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle: style])
        
        var frame = footer.frame
        frame.size.height = footer.sizeThatFits(CGSize(width: footer.frame.width, height: CGFloat.greatestFiniteMagnitude)).height + 60
        footer.frame = frame
        tableView.tableFooterView = footer
    }
    
    // MARK: Sound Toggling
    
    @IBAction func toggleMute(_ sender: UIBarButtonItem!)
    {
        /**
         * Toggling the sdk mute setting will affect whether your video ads begin in a muted state or not.
         */
        let sdk = ALSdk.shared()
        sdk?.settings.isMuted = !(sdk?.settings.isMuted)!
        sender.image = muteIconForCurrentSdkMuteSetting()
    }
    
    func muteIconForCurrentSdkMuteSetting() -> UIImage!
    {
        ALSdk.shared()!.settings.isMuted ? UIImage(named: "mute") : UIImage(named: "unmute")
    }
    
    // MARK: Table View Actions
    
    func openSupportSite()
    {
        guard let supportURL = URL(string: Self.kSupportLink) else { return }
        
        if #available(iOS 9.0, *)
        {
            let safariController = SFSafariViewController(url: supportURL, entersReaderIfAvailable: true)
            present(safariController, animated: true)
        }
        else
        {
            UIApplication.shared.openURL(supportURL)
        }
    }
    
}
