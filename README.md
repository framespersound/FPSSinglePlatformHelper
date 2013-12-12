FPSSinglePlatformHelper
=======================

Helper class to receive JSON object from SinglePlatform.

## Usage

Add the files to your project in folder FPSSinglePlatformHelper (FPSSinglePlatformHelper.h, FPSSinglePlatformHelper.m, GTMDefines.h, GTMStringEncoding.h, GTMStringEncoding.m) and import the header (FPSSinglePlatformHelper.h) in the file where you'll be using it. Then, you need to conform your class to the FPSSinglePlatformHelperDelegate protocol. like so:

    #import "FPSSinglePlatformHelper.h"
    @interface SinglePlatformViewController : UIViewController <FPSSinglePlatformHelperDelegate>
    
After that, here's how you request the JSON:

    FPSSinglePlatformHelper *spHelper = [[FPSSinglePlatformHelper alloc] initWithClientID:kClientID andSigningKey:kSigningKey];
    spHelper.delegate = self;
    //(ex: Mint 400 MCAllister Street San Francisco, CA 94103)
    [spHelper menuForPlace:@"Name of the place" withAddress:@"Address" city:@"City" state:@"State" zip:@"Zip"];
    
Implement the delegate method in order to receive the JSON:
    

    - (void)JSON:(id)jsonObj foundPlace:(BOOL)isFound withMenu:(BOOL)isMenu;
    {
        if(isFound && isMenu) {
          NSLog(@"%@", jsonObj);
        }
    }
    
