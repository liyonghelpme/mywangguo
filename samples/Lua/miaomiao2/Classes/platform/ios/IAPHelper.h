//
// IAPHeper.h
// nozomi
//
// Created by stc on 13-6-21.
//
//

#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"
 
//#define kProductsLoadedNotification @"ProductsLoaded"
 
@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    NSSet * _productIds;
    NSArray * _products;
    SKProductsRequest * _request;
}

@property (retain) NSSet * productIds;
@property (retain) NSArray * products;
@property (retain) SKProductsRequest *request;
 
- (void)requestProducts:(NSSet *)productIdentifiers;
- (id)init;
- (void)buyProductIdentifier:(NSString *)productIdentifier;
- (BOOL)verifyOnServer:(SKPaymentTransaction *)transaction;
- (NSString*)base64Encode:(NSData*)data;

+ (IAPHelper *) sharedHelper;
@end