//
//  FPSSinglePlatformHelper.m
//  FPSSinglePlatformHelper
//
//  Created by Talia DeVault and Matt Ozer on 12/09/13.
//  Copyright (c) 2013 Frames Per Sound. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "FPSSinglePlatformHelper.h"

#import "GTMStringEncoding.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation FPSSinglePlatformHelper {
    NSString *_clientID;
    NSString *_signingKey;
}

- (id)initWithClientID:(NSString *)clientKey andSigningKey:(NSString *)signingKey;
{
    self = [super init];
    if(self) {
        _clientID = clientKey;
        _signingKey = signingKey;
    }
    return self;
}

#pragma mark - SINGLE PLATFORM API
- (void)menuForPlace:(NSString *)name withAddress:(NSString *)address city:(NSString *)city state:(NSString *)state zip:(NSString *)zip
{
    name = [self getASCIIStringEncodingForString:name];
    address = [self getASCIIStringEncodingForString:address];
    city = [self getASCIIStringEncodingForString:city];
    state = [self getASCIIStringEncodingForString:state];
    zip = [self getASCIIStringEncodingForString:zip];
    
    NSString *addressWithClientID = [@"http://matching-api.singleplatform.com/location-match?client=" stringByAppendingString:_clientID];
    
    NSString *jsonString = [[[[[[[[[@"{\"locations\":[{\"address\":\"" stringByAppendingString:address] stringByAppendingString:@" "] stringByAppendingString:city] stringByAppendingString:@" "] stringByAppendingString:state] stringByAppendingString:zip] stringByAppendingString:@"\",\"name\":\""] stringByAppendingString:name] stringByAppendingString:@"\"}],\"matching_criteria\":\"NAME_ADDRESS\"}"];
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:addressWithClientID]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        NSArray *resultArray = [jsonObj valueForKey:@"response"];
        //NSLog(@"result: %@", resultArray);
        NSString *spv2id = @"";
        for(id all in resultArray) {
            spv2id = [all valueForKey:@"spv2id"];
        }
        
        //if spv2id is not a string class no need to receive the menu
        if([spv2id isKindOfClass:[NSString class]]) {
            NSString *signingString = @"/locations/";
            signingString = [[[signingString stringByAppendingString:spv2id] stringByAppendingString:@"/menu?client="] stringByAppendingString:_clientID];
            
            NSMutableString *URLtoSign = [[NSMutableString alloc]
                                          init];
            [URLtoSign insertString:signingString atIndex:0];
            
            NSMutableString *signingKey = [[NSMutableString alloc] init];
            [signingKey insertString:_signingKey atIndex:0];
            NSString *signature = [self signURL:URLtoSign signingKey:signingKey];
            
            NSString *str = [[[[[@"http://api.singleplatform.co/locations/" stringByAppendingString:spv2id] stringByAppendingString:@"/menu?client="] stringByAppendingString:_clientID] stringByAppendingString:@"&sig="] stringByAppendingString:signature];
            
            NSMutableURLRequest *requestMenu = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:str]];
            [requestMenu setHTTPMethod:@"GET"];
            [requestMenu addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            
            [NSURLConnection sendAsynchronousRequest:requestMenu queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                //if the menu array has items in it
                if([[jsonObj objectForKey:@"menus"] count] != 0) {
                    if([self.delegate respondsToSelector:@selector(JSON:foundPlace:withMenu:)])
                        [self.delegate JSON:jsonObj foundPlace:YES withMenu:YES];
                }
                else {
                    if([self.delegate respondsToSelector:@selector(JSON:foundPlace:withMenu:)])
                        [self.delegate JSON:jsonObj foundPlace:YES withMenu:NO];
                }
            }];
        }
        else {
            if([self.delegate respondsToSelector:@selector(JSON:foundPlace:withMenu:)])
                [self.delegate JSON:nil foundPlace:NO withMenu:NO];
        }
    }];
}

#pragma mark - ASCII ENCODING

/*!
 * Makes sure that strings are ASCII encoded for URL
 * @param NSString string to ASCII encode
 * @returns ASCII encoded string
 */
- (NSString *)getASCIIStringEncodingForString:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *ASCIIString = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
    return ASCIIString;
}

#pragma mark - HMAC-SHA1

/*! 
 * This method returns the signature using HMAC-SHA1
 * @param NSMutableString the string for the url
 * @param NSMutableString the string for the SinglePlatform signing key
 * @returns NSString a string represantation of the signature
*/
- (NSString *)signURL:(NSMutableString *)signURL signingKey:(NSMutableString*)key
{
    NSString *URLString = signURL;
    NSData *urlData = [URLString dataUsingEncoding: NSASCIIStringEncoding];
    
    GTMStringEncoding *strEncoding = [GTMStringEncoding rfc4648Base64WebsafeStringEncoding];
    NSData *data = [strEncoding decode:key];
    
    unsigned char HMACArray[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1,
           [data bytes],
           [data length],
           [urlData bytes],
           [urlData length],
           &HMACArray);
    
    NSData *signatureData = [NSData dataWithBytes:&HMACArray length:CC_SHA1_DIGEST_LENGTH];
    NSMutableString *signatureString = [[NSMutableString alloc] initWithString:[strEncoding encode:signatureData]];
    
    [signatureString replaceOccurrencesOfString:@"=" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [signatureString length])];
    
    return signatureString;
}

@end