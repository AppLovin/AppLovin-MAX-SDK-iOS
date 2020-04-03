//
//  ALHomeViewController.swift
//  DemoApp-Swift
//
//  Created by Andrew Tian on 9/20/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK
import MessageUI
import SafariServices

class ALHomeViewController: UITableViewController, MFMailComposeViewControllerDelegate
{
    let kSupportEmail = "support@applovin.com"
    let kSupportLink = "https://support.applovin.com/support/home"

    let kRowIndexToHideForPhones = 3;
    
    @IBOutlet var muteToggle: UIBarButtonItem!
    @IBOutlet weak var mediationDebuggerCell: UITableViewCell!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.setToolbarHidden(self.hidesBottomBarWhenPushed, animated: true)
        addFooterLabel()
        muteToggle.image = muteIconForCurrentSdkMuteSetting()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        self.navigationController?.setToolbarHidden(true, animated: false)
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
        
        if indexPath.section == 2
        {
            if indexPath.row == 0
            {
                openSupportSite()
            }
            else if indexPath.row == 1
            {
                attemptSendEmail()
            }
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if UIDevice.current.userInterfaceIdiom == .phone && indexPath.section == 0 && indexPath.row  == kRowIndexToHideForPhones
        {
            cell.isHidden = true;
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if UIDevice.current.userInterfaceIdiom == .phone && indexPath.section == 0 && indexPath.row  == kRowIndexToHideForPhones
        {
            return 0;
        }

        return super.tableView(tableView, heightForRowAt: indexPath)
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
    
    // MARK: Sound Toggling

    @IBAction func toggleMute(_ sender: UIBarButtonItem!)
    {
        /**
         * Toggling the sdk mute setting will affect whether your video ads begin in a muted state or not.
         */
        let sdk = ALSdk.shared()
        sdk?.settings.muted = !(sdk?.settings.muted)!
        sender.image = muteIconForCurrentSdkMuteSetting()
    }
    
    func muteIconForCurrentSdkMuteSetting() -> UIImage!
    {
        return ALSdk.shared()!.settings.muted ? UIImage(named: "mute") : UIImage(named: "unmute")
    }
    
    // MARK: Table View Actions
    
    func openSupportSite()
    {
        guard let supportURL = URL(string: kSupportLink) else { return }
        
        if #available(iOS 9.0, *)
        {
            let safariController = SFSafariViewController(url: supportURL, entersReaderIfAvailable: true)
            present(safariController, animated: true, completion: {
                UIApplication.shared.statusBarStyle = .default
            })
        }
        else
        {
            UIApplication.shared.openURL(supportURL)
        }
    }
    
    func attemptSendEmail()
    {
        if MFMailComposeViewController.canSendMail()
        {
            let mailController = MFMailComposeViewController()
            mailController.mailComposeDelegate = self
            mailController.setSubject("iOS SDK Support")
            mailController.setToRecipients([kSupportEmail])
            mailController.setMessageBody("\n\n---\nSDK Version: \(ALSdk.version())", isHTML: false)
            mailController.navigationBar.tintColor = UIColor.white
            
            present(mailController, animated: true, completion: {
                UIApplication.shared.statusBarStyle = .lightContent
            })
        }
        else
        {
            let message = "Your device is not configured for sending emails.\n\nPlease send emails to \(kSupportEmail)"
            let alertVC = UIAlertController(title: "Email Unavailable", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel)
            alertVC.addAction(okAction)
            present(alertVC, animated: true)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        switch ( result.rawValue )
        {
        case ( MFMailComposeResult.sent.rawValue ):
            let alertVC = UIAlertController(title: "Email Sent", message: "Thank you for your email, we will process it as soon as possible.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel)
            alertVC.addAction(okAction)
            present(alertVC, animated: true)
        default:
            break
        }
        
        dismiss(animated: true, completion: nil)
    }
}

