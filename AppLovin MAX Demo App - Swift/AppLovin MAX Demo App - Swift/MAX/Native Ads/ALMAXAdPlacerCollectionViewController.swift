//
//  ALMAXAdPlacerCollectionViewController.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Ritam Sarmah on 4/1/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALMAXAdPlacerCollectionViewController: UICollectionViewController, MAAdPlacerDelegate
{
    private let data = UIFont.familyNames.sorted()
    
    private var adPlacer: MACollectionViewAdPlacer!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let settings = MAAdPlacerSettings(adUnitIdentifier: "YOUR_AD_UNIT_ID")
        settings.addFixedPosition(IndexPath(item: 2, section: 0))
        settings.addFixedPosition(IndexPath(item: 8, section: 0))
        settings.repeatingInterval = 5
        
        adPlacer = MACollectionViewAdPlacer(collectionView: collectionView, settings: settings)
        adPlacer.delegate = self
        adPlacer.loadAds()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return data.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.al_dequeueReusableCell(withReuseIdentifier: "ALMAXAdPlacerCollectionViewCell", for: indexPath) as! ALTextCollectionViewCell
        cell.textLabel.text = data[indexPath.row]
        return cell
    }
}
