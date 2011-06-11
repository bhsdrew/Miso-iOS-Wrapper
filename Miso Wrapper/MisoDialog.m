//
//  MisoDialog.m
//  Miso Wrapper
//
//  Created by Andrew Fernandez on 6/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MisoDialog.h"


@implementation MisoDialog
@synthesize url;
@synthesize misoconsumer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString *newurl = [[request URL] scheme];
    NSLog(@"%@",newurl);
    if([newurl isEqualToString:@"misowrap"]){
        NSLog(@"paramstring: %@",[[request URL] query]);
        
        [misoconsumer setAuthorizeParams:[[request URL] query]];
        [misoconsumer authorizeUser];
        [self.view removeFromSuperview];
        
    }
    return YES;
}

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

-(id) initWithUrl:(NSURL *)authurl misoClass:(Miso *)misoparent{
    self.misoconsumer = misoparent;
    UIWebView *authscreen = [[UIWebView alloc] initWithFrame:CGRectMake(20, 20, 280, 400)];
    [authscreen loadRequest:[NSURLRequest requestWithURL:authurl]];
    [authscreen setDelegate:self];
    UIViewController *authview = [[UIViewController alloc] init];
    [authview.view addSubview:authscreen];
    
    UIButton *misoclose = [UIButton buttonWithType:UIButtonTypeCustom];
    [misoclose setBackgroundImage:[UIImage imageNamed:@"closebutton.png"] forState:UIControlStateNormal];
    
    //[misoclose setBackgroundImage:[UIImage imageNamed:@"toolButtonselected.png"]forState:UIControlStateSelected];
    
    [misoclose setTitle:@"" forState:UIControlStateNormal];
    [misoclose addTarget:self action:@selector(dismissMisoWebView) forControlEvents:UIControlEventTouchUpInside];
    misoclose.frame = CGRectMake(275, 0, 37, 38);
    [authview.view addSubview:misoclose];
    [self.view addSubview:authview.view];
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    
    [window.rootViewController.view addSubview:self.view];
    
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
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
