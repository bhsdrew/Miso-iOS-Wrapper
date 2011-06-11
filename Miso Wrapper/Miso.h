//
//  Miso.h
//  Miso Wrapper
//
//  Created by Andrew Fernandez on 6/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthConsumer.h"


#define misoRequestTokenUrl     @"https://gomiso.com/oauth/request_token/"
#define misoAuthorizeUrl        @"https:/gomiso.com/oauth/authorize"
#define misoAccessTokenUrl      @"https://gomiso.com/oauth/access_token"
@protocol MisoDelegate;

@interface Miso : NSObject  <UIWebViewDelegate>{
    id<MisoDelegate> delegate;
    OAToken *requestToken;
    NSString *authorizeParams;
    OAToken *accessToken;
}

@property (nonatomic,retain) OAToken *requestToken;
@property (nonatomic,retain) NSString *authorizeParams;
@property (nonatomic,retain) OAToken *accessToken;
@property (nonatomic,assign) id<MisoDelegate> delegate;


- (void) initiateMiso;
- (void) authorizeUser;

- (NSDictionary *)parseQueryString:(NSString *)query;


/*user api*/
- (void)retrieveUserDetailsWithId:(NSString *)userid;
- (void)searchForUsersWithQuery:(NSString *)query numberOfResults:(NSString *)count;
- (void)retrieveUserFollowersWithId:(NSString *)userid;
- (void)retrieveFollowedUsersWithId:(NSString *)userid;
- (void)followUserWithId:(NSString *)userid;
- (void)unfollowUserWithId:(NSString *)userid;

/**************** USER OBJECT *********************
 Object Representation
 
 A User object is represented with the basic following fields:
 id                 The user id for this user.                      1234
 username           The user's username.                            john24
 profile_image_url 	The url to the user's profile image.            http://gomiso.com/uploads/BAhbCFsHOgZm.png
 full_name          The user first and last name (if available). 	John Smith
 tagline            The user's chosen profile tagline.              TV is Great
 
 Extended details for users are:
 currently_followed 	Only returned for user search and user show actions. 
                        Will return "true" if the currently logged in user is 
                        following given user and "false" if (s)he is not.                           true
 total_points               The total points the user has earned.                                   10
 badge_count                The number of badges the user has earned.                               4
 checkin_count              The number of times the user has checked in.                            22
 following_count            The number of users this user is following.                             5
 follower_count             The number of followers this user has.                                  67
 twitter                    Exists only if user has a linked Twitter account.                       (Node)
 twitter.id                 The twitter account's unique id.                                        56789
 twitter.share_checkins 	Returns true if the user wants checkins posted to Twitter by default. 	false
 facebook                   Exists only if user has a linked Facebook account.                      (Node)
 facebook.id                The facebook account's unique id.                                       76854
 facebook.share_checkins 	Returns true if the user wants checkins posted to Facebook by default. 	true 
 
 **************************************************/


/*Media api*/
- (void)searchMediaListingWithQuery:(NSString *)query ofKind:(NSString *)kind numberOfResults:(NSString *)count;
- (void)retrieveMediaDetailsWithId:(NSString *)mediaid;
- (void)retrieveTrendingMediaWithNumberOfResults:(NSString *)count;
- (void)retrieveFavoritedMediaForUserId:(NSString *)userid;
- (void)markNewFavoriteMediaWithId:(NSString *)mediaid;
- (void)unmarkFavoriteMediaWithId:(NSString *)mediaid;

/**************** MEDIA OBJECT *********************
 Object Representation
 
 A Media object is represented with the basic following fields:
 id                         The id for this media object.                               5678
 title                      The media title for this object.                            The Dark Knight
 poster_image_url           The poster image for this media object.                     http://gomiso.com/uploads/BAhbCFsHOgZm.png
 poster_image_url_small 	The thumbnail poster image for this media object.           http://gomiso.com/uploads/BAhbCFsHOgZm.png
 kind                       The media object's type.                                    'TvShow' or 'Movie'
 release_year               The year the movie was released or the show started.        http://gomiso.com/uploads/BAhbCFsHOgZm.png
 tvdb_id                    The tvdb id associated with this media, if it exists.       tt1234
 currently_favorited        The media is currently favorited by the logged in user. 	true
 episode_count              The total number of episodes aired for this media 
                            (if it's a TV Show)                                         123
 latest_episode             An episode object representing the most recently aired 
                            episode for this media (if it's a TV Show)                  See Episode Representation
 
 Extended details for media are:
 genres                     Comma-delimited genres related to this media.               Drama, Mystery
 cast                       Comma-delimited actors related to this media.               Christian Bale, Heath Ledger
 summary                    The summary of the storyline for this media.                Batman faces the Joker in an epic battle.
 viewing_count              The total number of checkins to this media.                 1000
 followers_count            The total number of users following this media.             800
 
 **************************************************/


/*Feed api*/
- (void)retrieveFeedForUserId:(NSString *)userid mediaId:(NSString *)mediaid withMaxId:(NSString *)maxid sinceId:(NSString *)since numberOfResults:(NSString *)count;
- (void)retrieveHomeFeedForUserId:(NSString *)userid mediaId:(NSString *)mediaid withMaxId:(NSString *)maxid sinceId:(NSString *)since numberOfResults:(NSString *)count;

/**************** FEED OBJECT ****************************
 Object Representation

 A Feed item object is represented with the following fields:
 id                     The id for this feed item object.                           9876
 type                   The type for this feed item object.                         checkin, rating
 user                   The user that created this feed item.                       { user_id: 123, full_name: "John Smith",
                                                                                    profile_image_url: "http://gomiso.com/uploads/BAhbCFsHOgZm.png" }
 
 created_at             The timestamp for when this feed item was created           "2010-12-11T00:21:44Z"
 body                   The comment associated with the feed item. 
                        checkins, notes, and ratings may have a comment.            Dexter is a great show
 topics                 A dictionary of associated topics, may contain a media,
                        episode, badge or vote object.                              { media: {...}, episode: {...}, 
                                                                                    badge: {...}, vote: {...}}
 
 rating                 The rating associated with the feed item. 
                        Only ratings will have a rating.                            Dexter is a great show
 url                    The URL associated with the feed item. 
                        Only links will have a URL.                                 http://www.dexter.com
 image_url              The image URL associated with the feed item.
                        Only links will have an image URL.                          http://www.dexter.com
 likes_count            The number of users who have "liked" the feed item.         1
 likes                  An array of users who have "liked" the feed item.           [ "like" : { user_id : 123, full_name : "John Smith",
                                                                                    profile_image_url: "http://gomiso.com/uploads/BAhbCFsHOgZm.png" } ]
 
 comments_count         The number of users who have commented on the feed item. 	1
 comments               An array of users who have commented on the feed item.      [ "comment" : { user_id : 123, full_name : "John Smith"
                                                                                    , profile_image_url: "http://gomiso.com/uploads/BAhbCFsHOgZm.png", body : "What is that show about?" } ]

 **************************************************/

/*Checkins api*/
- (void)retrieveRecentCheckinsForUserId:(NSString *)userid mediaId:(NSString *)mediaid withMaxId:(NSString *)maxid sinceId:(NSString *)since numberOfResults:(NSString *)count;
- (void)createCheckinForMediaId:(NSString *)mediaid withSeasonNum:(NSString *)season episodeNum:(NSString *)episode comment:(NSString *)comment postToFacebook:(NSString *)facebook postToTwitter:(NSString *)twitter;

/**************** CHECKINS OBJECT ****************************
 Object Representation

 id                         The id for this checkin object.                                     9876
 created_at                 The timestamp for when this checkin was created                     "2010-12-11T00:21:44Z"
 comment                    The comment attached for this checkin.                              Dexter is a great show
 user_id                    The user id for this checkin.                                       1234
 user_username              The user username for this checkin.                                 john24
 user_full_name             The user name for this checkin.                                     John Smith
 user_profile_image_url 	The profile image for the given user.                               http://gomiso.com/uploads/BAhbCFsHOgZm.png
 media_id                   The media id for this checkin.                                      5678
 media_title                The media title for this checkin.                                   The Dark Knight
 media_poster_url           The poster image for the given media.                               http://gomiso.com/uploads/BAhbCFsHOgZm.png
 media_poster_url_small 	The thumbnail poster image for the given media.                     http://gomiso.com/uploads/BAhbCFsHOgZm.png
 episode_num                The number of the episode checked into 
                            (if this is an episode checkin)                                     12
 episode_season_num         The number of the season the episode belonged to 
                            (if this is an episode checkin)                                     12
 episode_label              The label of the episode checked into 
                            (if this is an episode checkin)                                     S03E12
 episode_title              The title of the episode checked into 
                            (if this is an episode checkin)                                     It Takes Two to Tango
 episode_poster_url         The image url of the episode checked into 
                            (if this is an episode checkin)                                     http://gomiso.com/abcdefg.jpg
 episode_poster_url_small 	The thumbnail image url of the episode checked into 
                            (if this is an episode checkin)                                     http://gomiso.com/abcdefg.jpg
 badges                     An array of badges that were awarded with this checkin. 
                            Fields explained in badges section below.                           [{"name": "FancyPants", "category": "level"
                                                                                                , "id": 1234},{"name": "IdolFan", "category": "achievement", "id": 4321}]
 **************************************************/


/*Badges api*/
- (void)retrieveListOfBadgesForUserId:(NSString *)userid inCategory:(NSString *)category;

/**************** CHECKINS OBJECT ****************************
 Object Representation
 
 A Badge object is represented with the following fields:
 id                 The id of the badge.                                            3456
 name               The name that is displayed for the badge.                       TV Newbie
 tagline            A brief tagline associated with the badge and how it was won 	You sure do watch a lot of reality shows!
 category           The type of badge - level, achievement or featured              level
 hint               Helpful advice about how to win the badge                       Check in to Family Guy 3000 times a day
 awarded            A boolean (true/false) flag explaining whether 
                    or not the given user has been awarded this badge               true
 graphic_url        A url for the badge image                                       http://gomiso.com/badge.jpg
 
 
 **************************************************/


/*Episodes api*/
- (void)retrieveEpisodesForMediaId:(NSString *)mediaid withSeasonNum:(NSString *)season numberOfResults:(NSString *)count;
- (void)retrieveEpisodeInfoForMediaId:(NSString *)media withSeasonNum:(NSString *)season episodeNum:(NSString *)episode;

/**************** CHECKINS OBJECT ****************************
 Object Representation
 
 An Episode object is represented with the basic following fields:
 title                      The tile for this episode object                                    The Big One
 season_num                 The season during which this episode aired                          3
 episode_num                The episode number with respect to the season during
                            which this episode aired                                            12
 aired                      The date the episode originally aired                               2010-12-11T00:21:44Z
 tvdb_id                    The tvdb id for the given episode                                   12345
 label                      The season & episode label for the given episode                    S02E12
 poster_image_url           The poster image for this episode object                            http://gomiso.com/uploads/BAhbCFsHOgZm.png
 poster_image_url_small 	The thumbnail poster image for this episode object                  http://gomiso.com/uploads/JHDkcDlskS.png
 summary                    A short text description/synopsis of the episode                    Leo meets his real parents and is terrified 
                                                                                                to learn his father has halitosis.
 cast                       Comma-delimited actors related to this media.                       Christian Bale, Heath Ledger                                
 
 
 **************************************************/

/*Notifications api*/
- (void)retrieveNotificationsForUser;
- (void)retrieveSingleNotificationWithId:(NSString *)notificationid;

/**************** CHECKINS OBJECT ****************************
 Object Representation
 
 A Notification Item object is represented with the basic following fields:
 
 id                 The id for the notification                                             1234
 type               The type of notification                                                "comment"
 description        The text of the notification as it is displayed within the app.         Steve Jones also commented on John Smith's post 
                                                                                            about The Big Bang Theory
 created_at         The date at which the notification was generated                        2010-09-25T19: 14: 08Z
 user               A truncated user object representing the user 
                    responsible for the notifcation                                         {username: "SteveyPoo", full_name: "Steve 
                                                                                            Jones", url: "http://steve.io", tagline: "It's Steve", id: 1234, profile_image_url: "http://gomiso.com/steve.jpg"}

 Extended details for notifications are
 
 body               If the notification is in reference to a comment, 
                    this will be the body of that comment                                   I can't stand this movie!
 feed_item_id       The feed item associated with this notification (if there is one)       4567
 topics             An object representing the various objects associated 
                    with the notification (the media it refers to, etc)                     {media: (A full media object representation)}

**************************************************/


@end

/*
 *Your application should implement this delegate
 */
@protocol MisoDelegate <NSObject>

@optional

-(void)finishedRetrievingApi:(NSDictionary *)data;

-(void)finishedAuthorizingUser;

@end
