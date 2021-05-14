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
 * Suggested parameters: @c kALEventParameterUserAccountIdentifierKey.
 *
 * AppLovin recommends that you pass these key-value pairs to @code -[ALEventService trackEvent:parameters:] @endcode.
 */
extern NSString *const kALEventTypeUserLoggedIn;

/**
 * Signifies that the finished a registration flow and created a new account.
 *
 * Suggested parameters: @c kALEventParameterUserAccountIdentifierKey.
 *
 * AppLovin recommends that you pass these key-value pairs to @code -[ALEventService trackEvent:parameters:] @endcode.
 */
extern NSString *const kALEventTypeUserCreatedAccount;

/**
 * @name Content Events
 */

/**
 * Signifies that the user viewed a specific piece of content.
 *
 * For views of saleable products, pass @c kALEventTypeUserViewedProduct instead.
 *
 * Suggested parameters: @c kALEventParameterContentIdentifierKey.
 *
 * AppLovin recommends that you pass these key-value pairs to @code -[ALEventService trackEvent:parameters:] @endcode.
 */
extern NSString *const kALEventTypeUserViewedContent;

/**
 * Signifies that the user executed a search query.
 *
 * Suggested parameters: @c kALEventParameterSearchQueryKey.
 *
 * AppLovin recommends that you pass these key-value pairs to @code -[ALEventService trackEvent:parameters:] @endcode.
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
 * Suggested parameters: @c kALEventParameterCompletedLevelKey.
 *
 * AppLovin recommends that you pass these key-value pairs to @code -[ALEventService trackEvent:parameters:] @endcode.
 */
extern NSString *const kALEventTypeUserCompletedLevel;

/**
 * Signifies that the user completed (or “unlocked”) a particular achievement.
 *
 * Suggested parameters: @c kALEventParameterCompletedAchievementKey.
 *
 * AppLovin recommends that you pass these key-value pairs to @code -[ALEventService trackEvent:parameters:] @endcode.
 */
extern NSString *const kALEventTypeUserCompletedAchievement;

/**
 * Signifies that the user spent virtual currency on an in-game purchase.
 *
 * Suggested parameters: @c kALEventParameterVirtualCurrencyAmountKey.
 *
 * AppLovin recommends that you pass these key-value pairs to @code -[ALEventService trackEvent:parameters:] @endcode.
 */
extern NSString *const kALEventTypeUserSpentVirtualCurrency;

/**
 * @name Commerce Events
 */

/**
 * Signifies that the user viewed a specific piece of content.
 *
 * For general content (non-saleable products) use @c kALEventTypeUserViewedContent instead.
 *
 * Suggested parameters: @c kALEventParameterProductIdentifierKey.
 *
 * AppLovin recommends that you pass these key-value pairs to @code -[ALEventService trackEvent:parameters:] @endcode.
 */
extern NSString *const kALEventTypeUserViewedProduct;

/**
 * Signifies that the user added a product/item to their shopping cart.
 *
 * Suggested parameters: @c kALEventParameterProductIdentifierKey.
 *
 * AppLovin recommends that you pass these key-value pairs to @code -[ALEventService trackEvent:parameters:] @endcode.
 */
extern NSString *const kALEventTypeUserAddedItemToCart;

/**
 * Signifies that the user added a product/item to their wishlist.
 *
 * Suggested parameters: @c kALEventParameterProductIdentifierKey.
 *
 * AppLovin recommends that you pass these key-value pairs to @code -[ALEventService trackEvent:parameters:] @endcode.
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
 * Suggested parameters: @c kALEventParameterProductIdentifierKey, @c kALEventParameterRevenueAmountKey, and @c kALEventParameterRevenueCurrencyKey.
 *
 * AppLovin recommends that you pass these key-value pairs to @code -[ALEventService trackEvent:parameters:] @endcode.
 */
extern NSString *const kALEventTypeUserBeganCheckOut;

/**
 * Signifies that the user completed a check-out / purchase.
 *
 * Suggested parameters: @c kALEventParameterCheckoutTransactionIdentifierKey, @c kALEventParameterProductIdentifierKey, @c kALEventParameterRevenueAmountKey,
 * and @c kALEventParameterRevenueCurrencyKey.
 *
 * AppLovin recommends that you pass these key-value pairs to @code -[ALEventService trackEvent:parameters:] @endcode.
 */
extern NSString *const kALEventTypeUserCompletedCheckOut;

/**
 * Signifies that the user completed an iTunes in-app purchase using StoreKit.
 *
 * Note that this event implies an in-app content purchase; for purchases of general products completed using Apple Pay, use
 * @c kALEventTypeUserCompletedCheckOut instead.
 *
 * Suggested parameters: @c kALEventParameterProductIdentifierKey, @c kALEventParameterStoreKitTransactionIdentifierKey, @c kALEventParameterStoreKitReceiptKey,
 * @c kALEventParameterRevenueAmountKey, and @c kALEventParameterRevenueCurrencyKey.
 *
 * AppLovin recommends that you pass these key-value pairs to @code -[ALEventService trackEvent:parameters:] @endcode.
 */
extern NSString *const kALEventTypeUserCompletedInAppPurchase;

/**
 * Signifies that the user has created a reservation or other date-specific event.
 *
 * Suggested parameters: @c kALEventParameterProductIdentifierKey, @c kALEventParameterReservationStartDateKey, and @c kALEventParameterReservationEndDateKey.
 *
 * AppLovin recommends that you pass these key-value pairs to @code -[ALEventService trackEvent:parameters:] @endcode.
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
 * The dictionary key for @code -[ALEventService trackEvent:parameters:] @endcode that represents the username or account ID of the user. Expects a
 * corresponding value of type @c NSString.
 */
extern NSString *const kALEventParameterUserAccountIdentifierKey;

/**
 * The dictionary key for @code -[ALEventService trackEvent:parameters:] @endcode that identifies a particular piece of content viewed by the user. Expects a
 * corresponding value of type @c NSString.
 *
 * This could be something like a section title, or even a name of a view controller.
 * For views of particular products, it is preferred you pass an SKU under @c kALEventParameterProductIdentifierKey.
 */
extern NSString *const kALEventParameterContentIdentifierKey;

/**
 * The dictionary key for @code -[ALEventService trackEvent:parameters:] @endcode that represents a search query executed by the user. Expects a corresponding
 * value of type @c NSString.
 *
 * In most cases the text that the user enters into a @c UISearchBar is what you want to provide as the value.
 */
extern NSString *const kALEventParameterSearchQueryKey;

/**
 * The dictionary key for @code -[ALEventService trackEvent:parameters:] @endcode that identifies the level the user has just completed. Expects a corresponding
 * value of type @c NSString.
 */
extern NSString *const kALEventParameterCompletedLevelKey;

/**
 * The dictionary key for @code -[ALEventService trackEvent:parameters:] @endcode that identifies the achievement the user has just completed/unlocked. Expects
 * a corresponding value of type @c NSString.
 */
extern NSString *const kALEventParameterCompletedAchievementKey;

/**
 * The dictionary key for @code -[ALEventService trackEvent:parameters:] @endcode that represents the amount of virtual currency that a user spent on an in-game
 * purchase. Expects a corresponding value of type @c NSNumber.
 */
extern NSString *const kALEventParameterVirtualCurrencyAmountKey;

/**
 * The dictionary key for @code -[ALEventService trackEvent:parameters:] @endcode that represents the name of the virtual currency that a user spent on an
 * in-game purchase. Expects a corresponding value of type @c NSString.
 */
extern NSString *const kALEventParameterVirtualCurrencyNameKey;

/**
 * The dictionary key for @code -[ALEventService trackEvent:parameters:] @endcode that identifies a particular product. Expects a corresponding value of type
 * @c NSString.
 *
 * This could be something like a product name, SKU, or inventory ID. For non-product content, for example to track uses of particular view controllers, pass
 * @c kALEventParameterContentIdentifierKey instead.
 */
extern NSString *const kALEventParameterProductIdentifierKey;

/**
 * The dictionary key for @code -[ALEventService trackEvent:parameters:] @endcode that represents the amount of revenue generated by a purchase event. Expects a
 * corresponding value of type @c NSNumber.
 */
extern NSString *const kALEventParameterRevenueAmountKey;

/**
 * The dictionary key for @code -[ALEventService trackEvent:parameters:] @endcode that represents the currency of the revenue event. Expects a corresponding
 * value of type @c NSString.
 *
 * Ideally this should be an ISO 4217 three-letter currency code (for instance, @c "USD", @c "EUR", @c "GBP", and so forth).
 *
 * @see https://en.wikipedia.org/wiki/ISO_4217
 */
extern NSString *const kALEventParameterRevenueCurrencyKey;

/**
 * The dictionary key for @code -[ALEventService trackEvent:parameters:] @endcode that represents a unique identifier for the current checkout transaction.
 * Expects a corresponding value of type @c NSString.
 */
extern NSString *const kALEventParameterCheckoutTransactionIdentifierKey;

/**
 * The dictionary key for @code -[ALEventService trackEvent:parameters:] @endcode that represents the StoreKit transaction ID associated with the revenue keys.
 * Expects a corresponding value of type @c NSString.
 *
 * This identifier should match the value of @code [SKPaymentTransaction transactionIdentifier] @endcode.
 */
extern NSString *const kALEventParameterStoreKitTransactionIdentifierKey;

/**
 * The dictionary key for @code -[ALEventService trackEvent:parameters:] @endcode that represents the StoreKit receipt associated with the revenue keys. Expects
 * a corresponding value of type @c NSData.
 *
 * The receipt can be collected in this way:
 * @code NSData* receipt = [NSData dataWithContentsOfURL: [[NSBundle mainBundle] appStoreReceiptURL]]; @endcode
 */
extern NSString *const kALEventParameterStoreKitReceiptKey;

/**
 * The dictionary key for @code -[ALEventService trackEvent:parameters:] @endcode that represents the start date of a reservation. Expects a corresponding value
 * of type @c NSDate.
 *
 * If a reservation does not span multiple days, you can submit only @c kALEventParameterReservationStartDateKey and ignore the corresponding
 * @c kALEventParameterReservationEndDateKey parameter.
 */
extern NSString *const kALEventParameterReservationStartDateKey;

/**
 * The dictionary key for @code -[ALEventService trackEvent:parameters:] @endcode that represents the end date of a reservation. Expects a corresponding value
 * of type @c NSDate.
 *
 * If a reservation does not span multiple days, you can submit only @c kALEventParameterReservationStartDateKey and ignore this parameter.
 */
extern NSString *const kALEventParameterReservationEndDateKey;

#endif

NS_ASSUME_NONNULL_END
