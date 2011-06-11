//
//  Miso_WrapperViewController.m
//  Miso Wrapper
//
//  Created by Andrew Fernandez on 6/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Miso_WrapperViewController.h"
#import "Miso.h"
@implementation Miso_WrapperViewController
@synthesize misotest;
- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    misotest = [Miso alloc];
    [misotest setDelegate:self];
    [misotest initiateMiso];
    
    //OAToken *accestoken = [[OAToken alloc] initWithKey:@"g2vfIi7IioVP2tlw9jUQ" secret:@"UhqICSBMAvFR4SZRQxBwnseuz6DG0ZVQOKtUF6z5"];
    //[misotest setAccessToken:accestoken];
    
    
}

- (void)finishedAuthorizingUser{
    
    NSLog(@"Finished Auth");
    [misotest retrieveUserDetailsWithId:nil];
    [misotest retrieveUserDetailsWithId:@"12938"];
    [misotest searchForUsersWithQuery:@"somrat" numberOfResults:nil];
    [misotest searchForUsersWithQuery:@"shalimar" numberOfResults:@"50"];
}

- (void)finishedRetrievingApi:(NSDictionary *)data{
    
    NSLog(@"Delegate: %@",data); 
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
