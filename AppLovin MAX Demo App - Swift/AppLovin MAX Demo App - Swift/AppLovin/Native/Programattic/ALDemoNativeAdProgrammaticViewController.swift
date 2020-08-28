//
//  ALDemoNativeAdProgrammaticViewController.swift
//  iOS-SDK-Demo
//
//  Created by Thomas So on 9/25/15.
//  Copyright © 2015 AppLovin. All rights reserved.
//

import UIKit

// Additional documentation - https://applovin.com/integration#iosNative

class ALDemoNativeAdProgrammaticViewController : ALBaseAdViewController
{
    @IBOutlet weak var precacheButton: UIBarButtonItem!
    @IBOutlet weak var showButton: UIBarButtonItem!
    
    @IBOutlet weak var impressionStatusLabel: UILabel!
    
    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rating: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mediaView: ALCarouselMediaView!
    @IBOutlet weak var ctaButton: UIButton!
    
    var nativeAd: ALNativeAd?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        appIcon.layer.masksToBounds = true
        appIcon.layer.cornerRadius = 3
        
        ctaButton.layer.masksToBounds = true
        ctaButton.layer.cornerRadius = 3
        
        setUIElementsHidden(true)
    }
    
    // MARK: Action Methods
    
    @IBAction func loadNativeAd(_ sender: AnyObject!)
    {
        logCallback()

        precacheButton.isEnabled = false
        showButton.isEnabled = false
        
        impressionStatusLabel.text = "No impression to track"
        
        ALSdk.shared()!.nativeAdService.loadNextAdAndNotify(self)
    }
    
    @IBAction func precacheNativeAd(_ sender: AnyObject!)
    {
        // You can use our pre-caching to retrieve assets (app icon, ad image, ad video) locally. OR you can do it with your preferred caching framework.
        // iconURL, imageURL, videoURL needs to be retrieved manually before you can render them
        
        logCallback()

        if let ad = nativeAd
        {
            ALSdk.shared()!.nativeAdService.precacheResources(for: ad, andNotify: self)
        }
    }
    
    @IBAction func showNativeAd(_ sender: AnyObject!)
    {
        logCallback()

        if let ad = nativeAd, let iconURL = ad.iconURL
        {
            if let imageData = try? Data(contentsOf: iconURL)
            {
                appIcon.image = UIImage(data: imageData ) // Local URL
            }
            
            titleLabel.text = ad.title
            descriptionLabel.text = ad.descriptionText
            ctaButton.setTitle(ad.ctaText, for: .normal)
            
            let starFilename = "Star_Sprite_\(String(describing: ad.starRating?.stringValue))"
            rating.image = UIImage(named: starFilename)
            
            // NOTE - Videos have aspect ratio of 1:1.85
            mediaView.renderView(for:  ad)
            
            setUIElementsHidden(false)
            
            //
            // You are responsible for firing all necessary postback URLs
            //
            trackImpression(ad)
            
            view.layoutIfNeeded()
        }
    }
    
    @IBAction func ctaPressed(_ sender: AnyObject!)
    {
        nativeAd?.launchClickTarget()
    }
    
    func trackImpression(_ ad: ALNativeAd!)
    {
        // Callbacks may not happen on main queue
        DispatchQueue.main.async {
            ad.trackImpressionAndNotify(self)
        }
    }
    
    func setUIElementsHidden(_ hidden: Bool)
    {
        appIcon.isHidden = hidden
        titleLabel.isHidden = hidden
        rating.isHidden = hidden
        descriptionLabel.isHidden = hidden
        mediaView.isHidden = hidden
        ctaButton.isHidden = hidden
    }
}

extension ALDemoNativeAdProgrammaticViewController : ALPostbackDelegate
{
    func postbackService(_ postbackService: ALPostbackService, didExecutePostback postbackURL: URL)
    {
        // Callbacks may not happen on main queue
        DispatchQueue.main.async {
            // Impression tracked!
            self.impressionStatusLabel.text = "Impression tracked"
        }
    }
    
    func postbackService(_ postbackService: ALPostbackService, didFailToExecutePostback postbackURL: URL?, errorCode: Int)
    {
        // Callbacks may not happen on main queue
        DispatchQueue.main.async {
            // Impression could not be tracked. Retry the postback later.
            self.impressionStatusLabel.text = "Impression failed to track with error code \(errorCode)"
        }
    }
}

extension ALDemoNativeAdProgrammaticViewController : ALNativeAdLoadDelegate
{
    func nativeAdService(_ service: ALNativeAdService, didLoadAds ads: [Any])
    {
        logCallback()

        // Callbacks may not happen on main queue
        DispatchQueue.main.async {
            self.nativeAd = ads.first as? ALNativeAd
            self.precacheButton.isEnabled = true
        }
    }
    
    func nativeAdService(_ service: ALNativeAdService, didFailToLoadAdsWithError code: Int)
    {
        logCallback()
    }
}

extension ALDemoNativeAdProgrammaticViewController : ALNativeAdPrecacheDelegate
{
    func nativeAdService(_ service: ALNativeAdService, didPrecacheImagesFor ad: ALNativeAd)
    {
        logCallback()
    }
    
    func nativeAdService(_ service: ALNativeAdService, didPrecacheVideoFor ad: ALNativeAd)
    {
        // This delegate method will get called whether an ad actually has a video to precache or not
        logCallback()

        // Callbacks may not happen on main queue
        DispatchQueue.main.async {
            self.showButton.isEnabled = true
            self.precacheButton.isEnabled = false
        }
    }
    
    func nativeAdService(_ service: ALNativeAdService, didFailToPrecacheImagesFor ad: ALNativeAd, withError errorCode: Int)
    {
        logCallback()
    }
    
    func nativeAdService(_ service: ALNativeAdService, didFailToPrecacheVideoFor ad: ALNativeAd, withError errorCode: Int)
    {
        logCallback()
    }
}
