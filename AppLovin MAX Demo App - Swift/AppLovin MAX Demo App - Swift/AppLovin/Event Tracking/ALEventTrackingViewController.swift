//
//  ALEventTrackingViewController.swift
//  iOS-SDK-Demo-Swift
//
//  Created by Monica Ong on 6/5/17.
//  Copyright © 2017 AppLovin. All rights reserved.
//

import UIKit
import StoreKit
import AppLovinSDK

struct ALDemoEvent
{
    var name: String
    var purpose: String
}

class ALEventTrackingViewController : UITableViewController
{
    private let events = [ALDemoEvent(name: "Began Checkout Event", purpose: "Track when user begins checkout procedure"),
                          ALDemoEvent(name: "Cart Event", purpose: "Track when user adds an item to cart"),
                          ALDemoEvent(name: "Completed Achievement Event", purpose: "Track when user completed an achievement"),
                          ALDemoEvent(name: "Completed Checkout Event", purpose: "Track when user completed checkout"),
                          ALDemoEvent(name: "Completed Level Event", purpose: "Track when user completed level"),
                          ALDemoEvent(name: "Created Reservation Event", purpose: "Track when user created a reservation"),
                          ALDemoEvent(name: "In-App Purchase Event", purpose: "Track when user makes an in-app purchase"),
                          ALDemoEvent(name: "Login Event", purpose: "Track when user logs in"),
                          ALDemoEvent(name: "Payment Info Event", purpose: "Tracks when user inputs their payment information"),
                          ALDemoEvent(name: "Registration Event", purpose: "Track when user registers"),
                          ALDemoEvent(name: "Search Event", purpose: "Track when user makes a search"),
                          ALDemoEvent(name: "Sent Invitation Event", purpose: "Track when user sends invitation"),
                          ALDemoEvent(name: "Shared Link Event", purpose: "Track when user shares a link"),
                          ALDemoEvent(name: "Spent Virtual Currency Event", purpose: "Track when users spends virtual currency"),
                          ALDemoEvent(name: "Tutorial Event", purpose: "Track when users does a tutorial"),
                          ALDemoEvent(name: "Viewed Content Event", purpose: "Track when user views content"),
                          ALDemoEvent(name: "Viewed Product Event", purpose: "Track when user views product"),
                          ALDemoEvent(name: "Wishlist Event", purpose: "Track when user adds an item to their wishlist")]
    
    // MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rootPrototype", for: indexPath)
        cell.textLabel!.text = events[indexPath.row].name
        cell.detailTextLabel?.text = events[indexPath.row].purpose
        
        return cell
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let eventService = ALSdk.shared()!.eventService
        
        switch indexPath.row
        {
        case 0:
            eventService.trackEvent(kALEventTypeUserBeganCheckOut,
                                    parameters: [kALEventParameterProductIdentifierKey : "PRODUCT SKU OR ID",
                                                 kALEventParameterRevenueAmountKey     : "PRICE OF ITEM",
                                                 kALEventParameterRevenueCurrencyKey   : "3-LETTER CURRENCY CODE"])
        case 1:
            eventService.trackEvent(kALEventTypeUserAddedItemToCart,
                                    parameters: [kALEventParameterProductIdentifierKey : "PRODUCT SKU OR ID"])
            
        case 2:
            eventService.trackEvent(kALEventTypeUserCompletedAchievement,
                                    parameters: [kALEventParameterCompletedAchievementKey : "ACHIEVEMENT NAME OR ID"])
            
        case 3:
            eventService.trackEvent(kALEventTypeUserCompletedCheckOut,
                                    parameters: [kALEventParameterCheckoutTransactionIdentifierKey : "UNIQUE TRANSACTION ID",
                                                 kALEventParameterProductIdentifierKey             : "PRODUCT SKU OR ID",
                                                 kALEventParameterRevenueAmountKey                 : "AMOUNT OF MONEY SPENT",
                                                 kALEventParameterRevenueCurrencyKey               : "3-LETTER CURRENCY CODE"])
        case 4:
            eventService.trackEvent(kALEventTypeUserCompletedLevel,
                                    parameters: [kALEventParameterCompletedLevelKey : "LEVEL NAME OR NUMBER"])
        case 5:
            eventService.trackEvent(kALEventTypeUserCreatedReservation,
                                    parameters: [kALEventParameterProductIdentifierKey    : "PRODUCT SKU OR ID",
                                                 kALEventParameterReservationStartDateKey : "START NSDATE",
                                                 kALEventParameterReservationEndDateKey   : "END NSDATE"])
        case 6:
            //In-App Purchases
            // let transaction: SKPaymentTransaction = ... // from paymentQueue:updatedTransactions:
            //let product: SKProduct = ... // Appropriate product (matching productIdentifier property to SKPaymentTransaction)
            eventService.trackInAppPurchase(withTransactionIdentifier: "transaction.transactionIdentifier",
                                            parameters: [kALEventParameterRevenueAmountKey     : "AMOUNT OF MONEY SPENT",
                                                         kALEventParameterRevenueCurrencyKey   : "3-LETTER CURRENCY CODE",
                                                         kALEventParameterProductIdentifierKey : "product.productIdentifier"]) //product.productIdentifier
        case 7:
            eventService.trackEvent(kALEventTypeUserLoggedIn,
                                    parameters: [kALEventParameterUserAccountIdentifierKey : "USERNAME"])
        case 8:
            eventService.trackEvent(kALEventTypeUserProvidedPaymentInformation)
            
        case 9:
            eventService.trackEvent(kALEventTypeUserCreatedAccount,
                                    parameters: [kALEventParameterUserAccountIdentifierKey : "USERNAME"])
            
        case 10:
            eventService.trackEvent(kALEventTypeUserExecutedSearch,
                                    parameters: [kALEventParameterSearchQueryKey : "USER'S SEARCH STRING"])
        case 11:
            eventService.trackEvent(kALEventTypeUserSentInvitation)
        case 12:
            eventService.trackEvent(kALEventTypeUserSharedLink)
        case 13:
            eventService.trackEvent(kALEventTypeUserSpentVirtualCurrency,
                                    parameters: [kALEventParameterVirtualCurrencyAmountKey : "NUMBER OF COINS SPENT",
                                                 kALEventParameterVirtualCurrencyNameKey   : "CURRENCY NAME"])
        case 14:
            eventService.trackEvent(kALEventTypeUserCompletedTutorial)
        case 15:
            eventService.trackEvent(kALEventTypeUserViewedContent,
                                    parameters: [kALEventParameterContentIdentifierKey : "SOME ID DESCRIBING CONTENT"])
        case 16:
            eventService.trackEvent(kALEventTypeUserViewedProduct,
                                    parameters: [kALEventParameterProductIdentifierKey : "PRODUCT SKU OR ID"])
        case 17:
            eventService.trackEvent(kALEventTypeUserAddedItemToWishlist,
                                    parameters: [kALEventParameterProductIdentifierKey : "PRODUCT SKU OR ID"])
        default:
            title = "Default event tracking initiated"
        }
    }
}
