//
//  ALEventTypes.h
//  AppLovinSDK
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//


#ifndef ALEventTypes_h
#define ALEventTypes_h

NS_ASSUME_NONNULL_BEGIN

/**
 * @name Authentication Events
 * @file ALEventTypes.h
 */

/** 
 * Signifies that the user logged in to an existing account.
 *
 * Suggested parameters: {@link kALEventParameterUserAccountIdentifierKey}.
 *
 * AppLovin recommends that you pass these key-value pairs to {@link ALEventService::trackEvent:parameters:}.
 */
extern NSString *const kALEventTypeUserLoggedIn;

/**
 * Signifies that the finished a registration flow and created a new account.
 *
 * Suggested parameters: {@link kALEventParameterUserAccountIdentifierKey}.
 *
 * AppLovin recommends that you pass these key-value pairs to {@link ALEventService::trackEvent:parameters:}.
 */
extern NSString *const kALEventTypeUserCreatedAccount;

/**
 * @name Content Events
 */

/**
 * Signifies that the user viewed a specific piece of content.
 *
 * For views of saleable products, pass {@link kALEventTypeUserViewedProduct} instead.
 *
 * Suggested parameters: {@link kALEventParameterContentIdentifierKey}.
 *
 * AppLovin recommends that you pass these key-value pairs to {@link ALEventService::trackEvent:parameters:}.
 */
extern NSString *const kALEventTypeUserViewedContent;

/**
 * Signifies that the user executed a search query.
 *
 * Suggested parameters: {@link kALEventParameterSearchQueryKey}.
 *
 * AppLovin recommends that you pass these key-value pairs to {@link ALEventService::trackEvent:parameters:}.
 */
extern NSString *const kALEventTypeUserExecutedSearch;

/**
 * @name Gaming Events
 */

/**
 * Signifies that the user completed a tutorial or introduction sequence.
 *
 * Suggested parameters: None.
 */
extern NSString *const kALEventTypeUserCompletedTutorial;

/**
 * Signifies that the user completed a given level or game sequence.
 *
 * Suggested parameters: {@link kALEventParameterCompletedLevelKey}.
 *
 * AppLovin recommends that you pass these key-value pairs to {@link ALEventService::trackEvent:parameters:}.
 */
extern NSString *const kALEventTypeUserCompletedLevel;

/**
 * Signifies that the user completed (or “unlocked”) a particular achievement.
 *
 * Suggested parameters: {@link kALEventParameterCompletedAchievementKey}.
 *
 * AppLovin recommends that you pass these key-value pairs to {@link ALEventService::trackEvent:parameters:}.
 */
extern NSString *const kALEventTypeUserCompletedAchievement;

/**
 * Signifies that the user spent virtual currency on an in-game purchase.
 *
 * Suggested parameters: {@link kALEventParameterVirtualCurrencyAmountKey}.
 *
 * AppLovin recommends that you pass these key-value pairs to {@link ALEventService::trackEvent:parameters:}.
 */
extern NSString *const kALEventTypeUserSpentVirtualCurrency;

/**
 * @name Commerce Events
 */

/**
 * Signifies that the user viewed a specific piece of content.
 *
 * For general content (non-saleable products) use {@link kALEventTypeUserViewedContent} instead.
 *
 * Suggested parameters: {@link kALEventParameterProductIdentifierKey}.
 *
 * AppLovin recommends that you pass these key-value pairs to {@link ALEventService::trackEvent:parameters:}.
 */
extern NSString *const kALEventTypeUserViewedProduct;

/**
 * Signifies that the user added a product/item to their shopping cart.
 *
 * Suggested parameters: {@link kALEventParameterProductIdentifierKey}.
 *
 * AppLovin recommends that you pass these key-value pairs to {@link ALEventService::trackEvent:parameters:}.
 */
extern NSString *const kALEventTypeUserAddedItemToCart;

/**
 * Signifies that the user added a product/item to their wishlist.
 *
 * Suggested parameters: {@link kALEventParameterProductIdentifierKey}.
 *
 * AppLovin recommends that you pass these key-value pairs to {@link ALEventService::trackEvent:parameters:}.
 */
extern NSString *const kALEventTypeUserAddedItemToWishlist;

/**
 * Signifies that the user provided payment information, such as a credit card number.
 *
 * Suggested parameters: None.
 *
 * @warning Please <em>do not</em> pass AppLovin any personally identifiable information (PII) or financial/payment information.
 */
extern NSString *const kALEventTypeUserProvidedPaymentInformation;

/**
 * Signifies that the user began a check-out / purchase process.
 *
 * Suggested parameters: {@link kALEventParameterProductIdentifierKey}, {@link kALEventParameterRevenueAmountKey}, and
 * {@link kALEventParameterRevenueCurrencyKey}.
 *
 * AppLovin recommends that you pass these key-value pairs to {@link ALEventService::trackEvent:parameters:}.
 */
extern NSString *const kALEventTypeUserBeganCheckOut;

/**
 * Signifies that the user completed a check-out / purchase.
 *
 * Suggested parameters: {@link kALEventParameterCheckoutTransactionIdentifierKey}, {@link kALEventParameterProductIdentifierKey},
 * {@link kALEventParameterRevenueAmountKey}, and {@link kALEventParameterRevenueCurrencyKey}.
 *
 * AppLovin recommends that you pass these key-value pairs to {@link ALEventService::trackEvent:parameters:}.
 */
extern NSString *const kALEventTypeUserCompletedCheckOut;

/**
 * Signifies that the user completed an iTunes in-app purchase using StoreKit.
 *
 * Note that this event implies an in-app content purchase; for purchases of general products completed using Apple Pay, use
 * {@link kALEventTypeUserCompletedCheckOut} instead.
 *
 * Suggested parameters: {@link kALEventParameterProductIdentifierKey}, {@link kALEventParameterStoreKitTransactionIdentifierKey},
 * {@link kALEventParameterStoreKitReceiptKey}, {@link kALEventParameterRevenueAmountKey}, and {@link kALEventParameterRevenueCurrencyKey}.
 *
 * AppLovin recommends that you pass these key-value pairs to {@link ALEventService::trackEvent:parameters:}.
 */
extern NSString *const kALEventTypeUserCompletedInAppPurchase;

/**
 * Signifies that the user has created a reservation or other date-specific event.
 *
 * Suggested parameters: {@link kALEventParameterProductIdentifierKey}, {@link kALEventParameterReservationStartDateKey}, and
 * {@link kALEventParameterReservationEndDateKey}.
 *
 * AppLovin recommends that you pass these key-value pairs to {@link ALEventService::trackEvent:parameters:}.
 */
extern NSString *const kALEventTypeUserCreatedReservation;

/**
 * @name Social Events
 */

/**
 * Signifies that the user sent an invitation to use your app to a friend.
 *
 * Suggested parameters: None.
 */
extern NSString *const kALEventTypeUserSentInvitation;

/**
 * Signifies that the user shared a link or deep-link to some content within your app.
 *
 * Suggested parameters: None.
 */
extern NSString *const kALEventTypeUserSharedLink;

/**
 * @name Event Parameters
 */

/**
 * The dictionary key for {@link ALEventService::trackEvent:parameters:} that represents the username or account ID of the user. Expects a corresponding value
 * of type `NSString`.
 */
extern NSString *const kALEventParameterUserAccountIdentifierKey;

/**
 * The dictionary key for {@link ALEventService::trackEvent:parameters:} that identifies a particular piece of content viewed by the user. Expects a
 * corresponding value of type `NSString`.
 *
 * This could be something like a section title, or even a name of a view controller.
 * For views of particular products, it is preferred you pass an SKU under {@link kALEventParameterProductIdentifierKey}.
 */
extern NSString *const kALEventParameterContentIdentifierKey;

/**
 * The dictionary key for {@link ALEventService::trackEvent:parameters:} that represents a search query executed by the user. Expects a corresponding value of
 * type `NSString`.
 *
 * In most cases the text that the user enters into a `UISearchBar` is what you want to provide as the value.
 */
extern NSString *const kALEventParameterSearchQueryKey;

/**
 * The dictionary key for {@link ALEventService::trackEvent:parameters:} that identifies the level the user has just completed. Expects a corresponding value of
 * type `NSString`.
 */
extern NSString *const kALEventParameterCompletedLevelKey;

/**
 * The dictionary key for {@link ALEventService::trackEvent:parameters:} that identifies the achievement the user has just completed/unlocked. Expects a
 * corresponding value of type `NSString`.
 */
extern NSString *const kALEventParameterCompletedAchievementKey;

/**
 * The dictionary key for {@link ALEventService::trackEvent:parameters:} that represents the amount of virtual currency that a user spent on an in-game
 * purchase. Expects a corresponding value of type `NSNumber`.
 */
extern NSString *const kALEventParameterVirtualCurrencyAmountKey;

/**
 * The dictionary key for {@link ALEventService::trackEvent:parameters:} that represents the name of the virtual currency that a user spent on an in-game
 * purchase. Expects a corresponding value of type `NSString`.
 */
extern NSString *const kALEventParameterVirtualCurrencyNameKey;

/**
 * The dictionary key for {@link ALEventService::trackEvent:parameters:} that identifies a particular product. Expects a corresponding value of type `NSString`.
 *
 * This could be something like a product name, SKU, or inventory ID. For non-product content, for example to track uses of particular view controllers, pass
 * {@link kALEventParameterContentIdentifierKey} instead.
 */
extern NSString *const kALEventParameterProductIdentifierKey;

/**
 * The dictionary key for {@link ALEventService::trackEvent:parameters:} that represents the amount of revenue generated by a purchase event. Expects a
 * corresponding value of type `NSNumber`.
 */
extern NSString *const kALEventParameterRevenueAmountKey;

/**
 * The dictionary key for {@link ALEventService::trackEvent:parameters:} that represents the currency of the revenue event. Expects a corresponding value of
 * type `NSString`.
 *
 * Ideally this should be an ISO 4217 three-letter currency code (for instance, `USD`, `EUR`, `GBP`, and so forth).
 *
 * @see https://en.wikipedia.org/wiki/ISO_4217
 */
extern NSString *const kALEventParameterRevenueCurrencyKey;

/**
 * The dictionary key for {@link ALEventService::trackEvent:parameters:} that represents a unique identifier for the current checkout transaction. Expects a
 * corresponding value of type `NSString`.
 */
extern NSString *const kALEventParameterCheckoutTransactionIdentifierKey;

/**
 * The dictionary key for {@link ALEventService::trackEvent:parameters:} that represents the StoreKit transaction ID associated with the revenue keys. Expects
 * a corresponding value of type `NSString`.
 *
 * This identifier should match the value of {@link SKPaymentTransaction::transactionIdentifier}.
 */
extern NSString *const kALEventParameterStoreKitTransactionIdentifierKey;

/**
 * The dictionary key for {@link ALEventService::trackEvent:parameters:} that represents the StoreKit receipt associated with the revenue keys. Expects a
 * corresponding value of type `NSData`.
 *
 * The receipt can be collected in this way:
 * {@code NSData* receipt = [NSData dataWithContentsOfURL: [[NSBundle mainBundle] appStoreReceiptURL]];}
 */
extern NSString *const kALEventParameterStoreKitReceiptKey;

/**
 * The dictionary key for {@link ALEventService::trackEvent:parameters:} that represents the start date of a reservation. Expects a corresponding value of type
 * `NSDate`.
 *
 * If a reservation does not span multiple days, you can submit only `kALEventParameterReservationStartDateKey` and ignore the corresponding
 * {@link kALEventParameterReservationEndDateKey} parameter.
 */
extern NSString *const kALEventParameterReservationStartDateKey;

/**
 * The dictionary key for {@link ALEventService::trackEvent:parameters:} that represents the end date of a reservation. Expects a corresponding value of type
 * `NSDate`.
 *
 * If a reservation does not span multiple days, you can submit only {@link kALEventParameterReservationStartDateKey} and ignore this parameter.
 */
extern NSString *const kALEventParameterReservationEndDateKey;

#endif

NS_ASSUME_NONNULL_END
