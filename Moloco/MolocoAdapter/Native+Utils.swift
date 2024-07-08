//
//  Native+Utils.swift
//  MolocoAdapter
//
//  Created by Alan Cao on 3/1/24.
//  Copyright © 2024 AppLovin. All rights reserved.
//

import AppLovinSDK
import MolocoSDK

@available(iOS 13.0, *)
final class MAMolocoNativeAd: MANativeAd
{
    private unowned let adapter: MolocoAdapter
    private let adFormat: MAAdFormat
    
    private var clickGestures: [UIGestureRecognizer] = []
        
    init(adapter: MolocoAdapter, adFormat: MAAdFormat, builder: (MANativeAdBuilder) -> ())
    {
        self.adapter = adapter
        self.adFormat = adFormat
        super.init(format: adFormat, builderBlock: builder)
    }
    
    deinit
    {
        clickGestures.forEach { $0.view?.removeGestureRecognizer($0) }
    }
    
    @discardableResult
    override func prepare(forInteractionClickableViews clickableViews: [UIView], withContainer container: UIView) -> Bool
    {
        guard adapter.nativeAd != nil else
        {
            adapter.log(adEvent: .registerAdViewsFailed(description: "Native ad is nil"), adFormat: adFormat)
            return false
        }
        
        adapter.log(adEvent: .preparingViewsForInteraction(views: clickableViews, container: container), adFormat: adFormat)

        clickableViews.forEach { view in
            let clickGesture = UITapGestureRecognizer(target: self, action: #selector(clickNativeView))
            view.addGestureRecognizer(clickGesture)
            clickGestures.append(clickGesture)
        }

        return true
    }
    
    @objc
    private func clickNativeView()
    {
        adapter.nativeAd?.handleClick()
    }
}

extension MANativeAdView
{
    var clickableViews: [UIView]
    {
        [titleLabel,
         advertiserLabel,
         bodyLabel,
         callToActionButton,
         iconImageView].compactMap { $0 }
    }
}
