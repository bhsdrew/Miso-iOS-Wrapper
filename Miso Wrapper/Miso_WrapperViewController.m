//
//  Miso_WrapperViewController.m
//  Miso Wrapper
//
//  Created by Andrew Fernandez on 6/9/11.
//  Copyright 2011 IronsoftStudios.com All rights reserved.
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
    
    //OAToken *accestoken = [[OAToken alloc] initWithKey:@"" secret:@""];
    //[misotest setAccessToken:accestoken];
    
    
}

- (void)finishedAuthorizingUser{
    
    NSLog(@"Finished Auth");
    
    /****************user detail example calls********************/
    
    [misotest retrieveUserDetailsWithId:nil];
    [misotest retrieveUserDetailsWithId:@"182398"];
    
    [misotest searchForUsersWithQuery:@"rego" numberOfResults:nil];
    [misotest searchForUsersWithQuery:@"somrat" numberOfResults:@"1"];
    
    [misotest retrieveUserFollowersWithId:nil];
    [misotest retrieveUserFollowersWithId:@"8"];
    
    [misotest retrieveFollowedUsersWithId:@"8"];
    [misotest retrieveFollowedUsersWithId:nil];
    
    //[misotest followUserWithId:@"182398"];
    //[misotest unfollowUserWithId:@"182398"];
    
    /*****************media detail examples calls************************/
    
    [misotest searchMediaListingWithQuery:@"stargate" ofKind:@"TvShow" numberOfResults:@"15"];
    [misotest searchMediaListingWithQuery:@"stargate" ofKind:@"Movie" numberOfResults:@"15"];
    [misotest searchMediaListingWithQuery:@"stargate" ofKind:nil numberOfResults:nil];
    
    [misotest retrieveMediaDetailsWithId:@"14300"];
    
    [misotest retrieveTrendingMediaWithNumberOfResults:@"10"];
    [misotest retrieveTrendingMediaWithNumberOfResults:nil];
    
    [misotest retrieveFavoritedMediaForUserId:nil];
    [misotest retrieveFavoritedMediaForUserId:@"8"];
    
    //[misotest markNewFavoriteMediaWithId:@"14300"];
    //[misotest unmarkFavoriteMediaWithId:@"14300"];
    
    /*****************feed detail examples calls************************/
    
    [misotest retrieveFeedForUserId:nil mediaId:nil withMaxId:nil sinceId:nil numberOfResults:nil];
    [misotest retrieveFeedForUserId:@"8" mediaId:nil withMaxId:nil sinceId:nil numberOfResults:nil];
    [misotest retrieveHomeFeedForUserId:nil mediaId:nil withMaxId:nil sinceId:nil numberOfResults:nil];
    
    /*****************checkin detail examples calls************************/
    
    [misotest retrieveRecentCheckinsForUserId:@"155932" mediaId:nil withMaxId:nil sinceId:nil numberOfResults:nil];
    
    //[misotest createCheckinForMediaId:@"14300" withSeasonNum:@"2" episodeNum:@"1" comment:@"Test Checkin" postToFacebook:@"false" postToTwitter:@"false"];
    
    /*****************Badges detail examples calls************************/
    
    [misotest retrieveListOfBadgesForUserId:@"155932" inCategory:@"achievement"];
    
    /*****************Episodes detail examples calls************************/
    
    [misotest retrieveEpisodesForMediaId:@"14300" withSeasonNum:@"2" numberOfResults:nil];
    [misotest retrieveEpisodeInfoForMediaId:@"14300" withSeasonNum:@"2" episodeNum:@"2"];
    
    /*****************Notifications detail examples calls************************/
    
    [misotest retrieveNotificationsForUser];
    [misotest retrieveSingleNotificationWithId:@"368059"];
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
