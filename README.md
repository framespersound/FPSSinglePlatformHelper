FPSSinglePlatformHelper
=======================

Helper class to receive JSON object from SinglePlatform.

## Usage

Add the files to your project in folder FPSSinglePlatformHelper (FPSSinglePlatformHelper.h, FPSSinglePlatformHelper.m, GTMDefines.h, GTMStringEncoding.h, GTMStringEncoding.m) and import the header (FPSSinglePlatformHelper.h) in the file where you'll be using it. Then, you need to conform your class to the FPSSinglePlatformHelperDelegate protocol. like so:

    #import "FPSSinglePlatformHelper.h"
    @interface SinglePlatformViewController : UIViewController <FPSSinglePlatformHelperDelegate>
    
After that, here's how you request the JSON:

    FPSSinglePlatformHelper *spHelper = [[FPSSinglePlatformHelper alloc] initWithClientID:@"Client_ID" andSigningKey:@"Signing_KEY"];
    spHelper.delegate = self;
    //(ex: Mint 400 MCAllister Street San Francisco, CA 94103)
    [spHelper menuForPlace:@"Name of the place" withAddress:@"Address" city:@"City" state:@"State" zip:@"Zip"];
    
Implement the delagate method in order to receive the JSON:
    

    - (void)JSON:(id)jsonObj foundPlace:(BOOL)isFound withMenu:(BOOL)isMenu;
    {
        if(isFound) {
          NSLog(@"%@", jsonObj);
          NSError *error;
          NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObj options:NSJSONWritingPrettyPrinted     error:&error];
          NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
          if(isMenu) {
              [jsonObj objectForKey:@"menus"];
              self.textView.text = jsonString;
          }
          else {
              self.textView.text = @"Place is found with no menu information";
          }
      }
      else {
          self.textView.text = @"Can not find place using location API";
      }
    }
    
