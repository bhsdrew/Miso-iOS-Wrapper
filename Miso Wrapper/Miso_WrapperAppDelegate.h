//
//  Miso_WrapperAppDelegate.h test2
//  Miso Wrapper
//
//  Created by Andrew Fernandez on 6/9/11.
//  Copyright 2011 IronsoftStudios.com All rights reserved.
//

#import <UIKit/UIKit.h>

@class Miso_WrapperViewController;

@interface Miso_WrapperAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet Miso_WrapperViewController *viewController;

@end
