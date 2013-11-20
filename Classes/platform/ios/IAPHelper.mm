#import "IAPHelper.h"
#import "support/user_default/CCUserDefault.h"
#import "support/CCNotificationCenter.h"

@implementation IAPHelper

// Under @implementation
@synthesize productIds = _productIds;
@synthesize products = _products;
@synthesize request = _request;

static IAPHelper * _sharedHelper;
 
+ (IAPHelper *) sharedHelper {
 
    if (_sharedHelper != nil) {
        return _sharedHelper;
    }
    _sharedHelper = [[IAPHelper alloc] init];
    return _sharedHelper;
}

// In dealloc
- (void)dealloc
{
    self.productIds = nil;
    self.products = nil;
    self.request = nil;
    [super dealloc];
}
 
- (id)init {
    
    if ((self = [super init])) {                
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
 
}

- (void)requestProducts:(NSSet *)productIdentifiers{
    self.productIds = productIdentifiers;
    self.request = [[[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers] autorelease];
    _request.delegate = self;
    [_request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
     self.products = response.products;
     self.request = nil;
    //NSString *res = @"";
     for(int i=0;i<self.products.count;i++){
        SKProduct *product = [self.products objectAtIndex:i];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:product.priceLocale];
        NSString *formattedString = [numberFormatter stringFromNumber:product.price];
        // res = [NSString stringWithFormat:@"%@ %@ %@", res, product.price, product.productIdentifier];
        cocos2d::CCUserDefault::sharedUserDefault()->setStringForKey([product.productIdentifier UTF8String], [formattedString UTF8String]);
     }
    
    /*
    NSString *str = [NSString stringWithFormat:@"count=%d product %@", self.products.count, res];
      NSString* requestString = [NSString stringWithFormat:@"%slogError", "http://caesarsgame.com:9190/"];
    
    NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]] autorelease];
    NSString *postStr = [NSString stringWithFormat:@"uid=%d&log=%@", 123, str];
    NSData* postData = [postStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    [req setHTTPMethod:@"post"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [req setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:postData];
    NSError* error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:&error];
    if(error==nil){
        NSString* returnString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        NSLog(@"%@", returnString);
        //return [@"success" isEqualToString:returnString];
    }
     */
    
     //[[NSNotificationCenter defaultCenter] postNotificationName:kProductsLoadedNotification object:_products];
}

//- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    //try again
//    requestProducts(self.productIds);
//}

- (void)recordTransaction:(SKPaymentTransaction *)transaction {    
    // Optional: Record the transaction on the server side...    
}
 
- (void)provideContent:(NSString *)productIdentifier {
    //[[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchasedNotification object:productIdentifier];
    cocos2d::CCNotificationCenter::sharedNotificationCenter()->postNotification("EVENT_BUY_SUCCESS");
}
 
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    if([self verifyOnServer:transaction])
    {
        [self recordTransaction: transaction];
        [self provideContent: transaction.payment.productIdentifier];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
 
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    if([self verifyOnServer:transaction])
    {
        [self recordTransaction: transaction];
        [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (BOOL)verifyOnServer:(SKPaymentTransaction *)transaction{
    NSString* requestString = [NSString stringWithFormat:@"%sverify", cocos2d::CCUserDefault::sharedUserDefault()->getStringForKey("baseUrl").c_str()];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]] autorelease];
    NSString *postStr = [NSString stringWithFormat:@"receipt=%@",[self base64Encode:transaction.transactionReceipt]];
    NSData* postData = [postStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    [request setHTTPMethod:@"post"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    NSError* error = nil;
    int retry = 0;
    while (retry<2){
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        if(error==nil){
            NSString* returnString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
            return [@"success" isEqualToString:returnString];
        }
        else{
            retry ++;
        }
    }
    return NO;
}

- (NSString*)base64Encode:(NSData *)data
{
    static char base64EncodingTable[64] = {
         'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
         'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
         'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
         'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
     };
     int length = [data length];
     unsigned long ixtext, lentext;
     long ctremaining;
     unsigned char input[3], output[4];
     short i, charsonline = 0, ctcopy;
     const unsigned char *raw;
     NSMutableString *result;
  
     lentext = [data length]; 
     if (lentext < 1)
         return @"";
     result = [NSMutableString stringWithCapacity: lentext];
     raw = (unsigned char*)[data bytes];
     ixtext = 0; 
  
     while (true) {
         ctremaining = lentext - ixtext;
         if (ctremaining <= 0) 
             break;        
         for (i = 0; i < 3; i++) { 
             unsigned long ix = ixtext + i;
             if (ix < lentext)
                 input[i] = raw[ix];
             else
                 input[i] = 0;
         }
         output[0] = (input[0] & 0xFC) >> 2;
         output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
         output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
         output[3] = input[2] & 0x3F;
         ctcopy = 4;
         switch (ctremaining) {
             case 1: 
                 ctcopy = 2; 
                 break;
             case 2: 
                 ctcopy = 3; 
                 break;
         }
  
         for (i = 0; i < ctcopy; i++)
             [result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
  
         for (i = ctcopy; i < 4; i++)
             [result appendString: @"="];
  
         ixtext += 3;
         charsonline += 4;
  
         if ((length > 0) && (charsonline >= length))
             charsonline = 0;
     }     
     return result;
}
 
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
 
    //[[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchaseFailedNotification object:transaction];
    cocos2d::CCNotificationCenter::sharedNotificationCenter()->postNotification("EVENT_BUY_FAIL");
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
 
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}
 
- (void)buyProductIdentifier:(NSString *)productIdentifier {
    for (int i=0; i<self.products.count; i++) {
        SKProduct *product = [self.products objectAtIndex:i];
        if([product.productIdentifier compare:productIdentifier]==NSOrderedSame){
            SKPayment *payment = [SKPayment paymentWithProduct:product];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
    }
}

@end