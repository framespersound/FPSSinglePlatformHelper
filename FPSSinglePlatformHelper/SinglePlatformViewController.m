//
//  ViewController.m
//  FPSSinglePlatformHelper
//
//  Created by Talia DeVault and Matt Ozer on 12/9/13.
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

#import "SinglePlatformViewController.h"

NSString *const kClientID = @"CLIENT_ID";
NSString *const kSigningKey = @"SIGNING_KEY";

@implementation SinglePlatformViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"SinglePlatform Response";
    
    FPSSinglePlatformHelper *spHelper = [[FPSSinglePlatformHelper alloc] initWithClientID:kClientID andSigningKey:kSigningKey];
    spHelper.delegate = self;
    //(ex: Mint 400 MCAllister Street San Francisco, CA 94103)
    [spHelper menuForPlace:@"Name of the place" withAddress:@"Address" city:@"City" state:@"State" zip:@"Zip"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - FPSSINGLEPLATFORMHELPERDELEGATE

- (void)JSON:(id)jsonObj foundPlace:(BOOL)isFound withMenu:(BOOL)isMenu;
{
    if(isFound) {
        NSLog(@"%@", jsonObj);
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObj options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if(isMenu) {
            [jsonObj objectForKey:@"menus"];
            self.textView.text = jsonString;
        }
        else {
            self.textView.text = @"The place is found with no menu information";
        }
    }
    else {
        self.textView.text = @"Unable to find the place";
    }
}

@end