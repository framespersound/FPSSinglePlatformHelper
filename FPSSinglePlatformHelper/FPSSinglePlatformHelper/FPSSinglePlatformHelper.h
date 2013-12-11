//
//  FPSSinglePlatformHelper.h
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

#import <Foundation/Foundation.h>

@class FPSSinglePlatformHelper;

/*!
 * Act as a JSON receiver for SinglePlatform menu information
 */
@protocol FPSSinglePlatformHelperDelegate <NSObject>
@optional
/*!
 * Delegate method that gets called when a response is received
 * from SinglePlatform.
 * @param id JSON object
 * @param BOOL YES if search has returned a result
 * @param BOOL YES if found place has information for menu
 */
- (void)JSON:(id)jsonObj foundPlace:(BOOL)isFound withMenu:(BOOL)isMenu;
@end

/*!
 * Helper class to get menu information from SinglePlatform
 */
@interface FPSSinglePlatformHelper : NSObject

/*!
 * Delegate object for FPSSinglePlatformHelper
 */
@property (nonatomic, unsafe_unretained) id <FPSSinglePlatformHelperDelegate> delegate;

/*!
 * Initialize with client ID and signing key
 */
- (id)initWithClientID:(NSString *)clientKey andSigningKey:(NSString *)signingKey;

/*!
 * This method received the json response from SinglePlatform
 * @param NSString the string for the name
 * @param NSString the string for the address
 * @param NSString the string for the city
 * @param NSString the string for the state
 * @param NSString the string for the zip
 */
- (void)menuForPlace:(NSString *)name withAddress:(NSString *)address city:(NSString *)city state:(NSString *)state zip:(NSString *)zip;

@end