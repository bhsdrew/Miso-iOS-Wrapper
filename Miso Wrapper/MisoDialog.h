//
//  MisoDialog.h
//  Miso Wrapper
//
//  Created by Andrew Fernandez on 6/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Miso.h"

@interface MisoDialog : UIViewController <UIWebViewDelegate>{
    
    NSURL *url;
    Miso *misoconsumer;
}

@property (nonatomic,retain) NSURL *url;
@property (nonatomic,retain) Miso *misoconsumer;
-(id) initWithUrl:(NSURL *)authurl misoClass:(Miso *)misoparent;
@end
