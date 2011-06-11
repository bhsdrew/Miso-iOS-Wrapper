//
//  Miso_WrapperViewController.h
//  Miso Wrapper
//
//  Created by Andrew Fernandez on 6/9/11.
//  Copyright 2011 IronsoftStudios.com All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Miso.h"

@interface Miso_WrapperViewController : UIViewController <MisoDelegate>{
    Miso *misotest;
}

@property (nonatomic,retain) Miso *misotest;
@end
