//
//  Miso.m
//  Miso Wrapper
//
//  Created by Andrew Fernandez on 6/9/11.
//  Copyright 2011 IronsoftStudios.com All rights reserved.
//

#import "Miso.h"
#import "MisoDialog.h"
#import "JSON.h"

#define misoSecret          @"SECRET"
#define misoKey             @"KEY"

@implementation Miso
@synthesize requestToken,accessToken,authorizeParams,delegate;


-(void) dealloc{
    [requestToken release];
    [authorizeParams release];
    [accessToken release];
    [super dealloc];
}

//BEGIN OAUTH REQUEST TOKEN
- (void) initiateMiso{
    
    //create oauth consumer for request token
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set request token url
    NSURL *url = [NSURL URLWithString:misoRequestTokenUrl];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:nil   // we don't have a Token yet
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    //create an oauth parameter for callingback to the appitself in order to capture the token data
    [request setOAuthParameterName:@"oauth_callback" withValue:@"misowrap://misocallback"];
    
    //request type is post
    [request setHTTPMethod:@"POST"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
    [consumer release];
    [request release];
}


- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    
        NSString *responseBody = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?oauth_token=%@",misoAuthorizeUrl,requestToken.key]];
        
        NSLog(@"token:%@",requestToken.key);
        //NSLog(@"url:%@",url);
        
        //fire login dialog to authorize app
        MisoDialog *dialog = [[MisoDialog alloc ] initWithUrl:url misoClass:self];
        [responseBody release];
        
    
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    //oauth error checking
}

//END OAUTH REQUEST TOKEN


//BEGIN OAUTH ACCESS TOKEN

- (void) authorizeUser{
    
    //prepare returned credentials into a nsdictionary
    //NSLog(@"%@",self.authorizeParams);
    NSDictionary *querystring = [self parseQueryString:self.authorizeParams];
    
    //create oauth consumer for request token
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:misoAccessTokenUrl];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.requestToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //NSLog(@"%@",[querystring objectForKey:@"oauth_token"]);
    //NSLog(@"%@",[querystring objectForKey:@"oauth_verifier"]);
    [request setOAuthParameterName:@"oauth_token" withValue:[querystring objectForKey:@"oauth_token"]];
    [request setOAuthParameterName:@"oauth_verifier" withValue:[querystring objectForKey:@"oauth_verifier"]];
    
    //request type is post
    [request setHTTPMethod:@"POST"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
    [consumer release];
    [request release];

}
- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    
        NSString *responseBody = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        
        //NSLog(@"token:%@",accessToken.key);
        //NSLog(@"token:%@",accessToken.secret);
        [delegate finishedAuthorizingUser];
        //NSLog(@"body:%@",responseBody);
        [responseBody release];
    
}
- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
}


/*************** User API Calls **************************/


- (void)retrieveUserDetailsWithId:(NSString *)userid{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/users/show.json"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    if(userid){
        OARequestParameter *user_id = [[OARequestParameter alloc] initWithName:@"user_id" value:userid];
        NSArray *params = [NSArray arrayWithObjects:user_id, nil];
        [request setParameters:params];
        [user_id release];
    }
    //request type is post
    [request setHTTPMethod:@"GET"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];
}

- (void)searchForUsersWithQuery:(NSString *)query numberOfResults:(NSString *)count{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/users.json"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    //NSLog(@"%@",query);
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:2];
    if(query){
        OARequestParameter *queryparam = [[OARequestParameter alloc] initWithName:@"q" value:[NSString stringWithFormat:@"%@",query]];
        [params addObject:queryparam];
        [queryparam release];
    }
    
    if(count){
        OARequestParameter *countparam = [[OARequestParameter alloc] initWithName:@"count" value:[NSString stringWithFormat:@"%@",count]];
        [params addObject:countparam];
        [countparam release];
    }
    
    [request setParameters:params];
    
    //request type is post
    [request setHTTPMethod:@"GET"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];
}

- (void)retrieveUserFollowersWithId:(NSString *)userid{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/users/followers.json"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    //NSLog(@"%@",query);
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:1];
    if(userid){
        OARequestParameter *user_id = [[OARequestParameter alloc] initWithName:@"user_id" value:[NSString stringWithFormat:@"%@",userid]];
        [params addObject:user_id];
        [user_id release];
    }
    
    
    [request setParameters:params];
    
    //request type is post
    [request setHTTPMethod:@"GET"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];
}
- (void)retrieveFollowedUsersWithId:(NSString *)userid{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/users/follows.json"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    //NSLog(@"%@",query);
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:1];
    if(userid){
        OARequestParameter *user_id = [[OARequestParameter alloc] initWithName:@"user_id" value:[NSString stringWithFormat:@"%@",userid]];
        [params addObject:user_id];
        [user_id release];
    }
    
    
    [request setParameters:params];
    
    //request type is post
    [request setHTTPMethod:@"GET"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];
}
- (void)followUserWithId:(NSString *)userid{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/users/follows.json"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    //NSLog(@"%@",query);
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:1];
    if(userid){
        OARequestParameter *user_id = [[OARequestParameter alloc] initWithName:@"user_id" value:[NSString stringWithFormat:@"%@",userid]];
        [params addObject:user_id];
        [user_id release];
    }
    
    [request setHTTPMethod:@"POST"];
    [request setParameters:params];
    
    //request type is post
    
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];
}
- (void)unfollowUserWithId:(NSString *)userid{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/users/follows.json"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    //NSLog(@"%@",query);
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:1];
    if(userid){
        OARequestParameter *user_id = [[OARequestParameter alloc] initWithName:@"user_id" value:[NSString stringWithFormat:@"%@",userid]];
        [params addObject:user_id];
        [user_id release];
    }
    
    
    [request setParameters:params];
    
    //request type is post
    [request setHTTPMethod:@"DELETE"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];
}

/*************** END User API Calls **************************/


/*************** Media API Calls **************************/

- (void)searchMediaListingWithQuery:(NSString *)query ofKind:(NSString *)kind numberOfResults:(NSString *)count{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/media.json"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    //NSLog(@"%@",query);
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:3];
    if(query){
        OARequestParameter *queryparam = [[OARequestParameter alloc] initWithName:@"q" value:[NSString stringWithFormat:@"%@",query]];
        [params addObject:queryparam];
        [queryparam release];
    }
    if(kind){
        OARequestParameter *kindparam = [[OARequestParameter alloc] initWithName:@"kind" value:[NSString stringWithFormat:@"%@",kind]];
        [params addObject:kindparam];
        [kindparam release];
    }
    if(count){
        OARequestParameter *countparam = [[OARequestParameter alloc] initWithName:@"count" value:[NSString stringWithFormat:@"%@",count]];
        [params addObject:countparam];
        [countparam release];
    }
    
    
    [request setParameters:params];
    
    //request type is post
    [request setHTTPMethod:@"GET"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];
}
- (void)retrieveMediaDetailsWithId:(NSString *)mediaid{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/media/show.json"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    //NSLog(@"%@",query);
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:1];
    if(mediaid){
        OARequestParameter *media_id = [[OARequestParameter alloc] initWithName:@"media_id" value:[NSString stringWithFormat:@"%@",mediaid]];
        [params addObject:media_id];
        [media_id release];
    }
    
    
    [request setParameters:params];
    
    //request type is post
    [request setHTTPMethod:@"GET"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];
    
}
- (void)retrieveTrendingMediaWithNumberOfResults:(NSString *)count{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/media/trending.json"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    //NSLog(@"%@",query);
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:1];
    if(count){
        OARequestParameter *countparam = [[OARequestParameter alloc] initWithName:@"count" value:[NSString stringWithFormat:@"%@",count]];
        [params addObject:countparam];
        [countparam release];
    }
    
    
    [request setParameters:params];
    
    //request type is post
    [request setHTTPMethod:@"GET"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];
    
}
- (void)retrieveFavoritedMediaForUserId:(NSString *)userid{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/media/favorites.json"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    //NSLog(@"%@",query);
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:1];
    if(userid){
        OARequestParameter *user_id = [[OARequestParameter alloc] initWithName:@"user_id" value:[NSString stringWithFormat:@"%@",userid]];
        [params addObject:user_id];
        [user_id release];
    }
    
    
    [request setParameters:params];
    
    //request type is post
    [request setHTTPMethod:@"GET"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];
    
}
- (void)markNewFavoriteMediaWithId:(NSString *)mediaid{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/media/favorites.json"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    //NSLog(@"%@",query);
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:1];
    if(mediaid){
        OARequestParameter *media_id = [[OARequestParameter alloc] initWithName:@"media_id" value:[NSString stringWithFormat:@"%@",mediaid]];
        [params addObject:media_id];
        [media_id release];
    }
    
    //request type is post
    [request setHTTPMethod:@"POST"];
    [request setParameters:params];
    
    
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];
    
}
- (void)unmarkFavoriteMediaWithId:(NSString *)mediaid{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/media/favorites.json"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    //NSLog(@"%@",query);
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:1];
    if(mediaid){
        OARequestParameter *media_id = [[OARequestParameter alloc] initWithName:@"media_id" value:[NSString stringWithFormat:@"%@",mediaid]];
        [params addObject:media_id];
        [media_id release];
    }
    
    
    [request setParameters:params];
    
    //request type is post
    [request setHTTPMethod:@"DELETE"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];
}

/***************END Media API Calls **************************/

/*************** Feed API Calls **************************/

- (void)retrieveFeedForUserId:(NSString *)userid mediaId:(NSString *)mediaid withMaxId:(NSString *)maxid sinceId:(NSString *)since numberOfResults:(NSString *)count{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/feeds.json"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    //NSLog(@"%@",query);
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:5];
    if(userid){
        OARequestParameter *user_id = [[OARequestParameter alloc] initWithName:@"user_id" value:[NSString stringWithFormat:@"%@",userid]];
        [params addObject:user_id];
        [user_id release];
    }
    if(mediaid){
        OARequestParameter *media_id = [[OARequestParameter alloc] initWithName:@"media_id" value:[NSString stringWithFormat:@"%@",mediaid]];
        [params addObject:media_id];
        [media_id release];
    }
    if(maxid){
        OARequestParameter *max_id = [[OARequestParameter alloc] initWithName:@"max_id" value:[NSString stringWithFormat:@"%@",maxid]];
        [params addObject:max_id];
        [max_id release];
    }
    if(since){
        OARequestParameter *since_id = [[OARequestParameter alloc] initWithName:@"since_id" value:[NSString stringWithFormat:@"%@",since]];
        [params addObject:since_id];
        [since_id release];
    }
    if(count){
        OARequestParameter *countparam = [[OARequestParameter alloc] initWithName:@"count" value:[NSString stringWithFormat:@"%@",count]];
        [params addObject:countparam];
        [countparam release];
    }
    
    
    [request setParameters:params];
    
    //request type is post
    [request setHTTPMethod:@"GET"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];
}
- (void)retrieveHomeFeedForUserId:(NSString *)userid mediaId:(NSString *)mediaid withMaxId:(NSString *)maxid sinceId:(NSString *)since numberOfResults:(NSString *)count{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/feeds/home.json"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    //NSLog(@"%@",query);
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:5];
    if(userid){
        OARequestParameter *user_id = [[OARequestParameter alloc] initWithName:@"user_id" value:[NSString stringWithFormat:@"%@",userid]];
        [params addObject:user_id];
        [user_id release];
    }
    if(mediaid){
        OARequestParameter *media_id = [[OARequestParameter alloc] initWithName:@"media_id" value:[NSString stringWithFormat:@"%@",mediaid]];
        [params addObject:media_id];
        [media_id release];
    }
    if(maxid){
        OARequestParameter *max_id = [[OARequestParameter alloc] initWithName:@"max_id" value:[NSString stringWithFormat:@"%@",maxid]];
        [params addObject:max_id];
        [max_id release];
    }
    if(since){
        OARequestParameter *since_id = [[OARequestParameter alloc] initWithName:@"since_id" value:[NSString stringWithFormat:@"%@",since]];
        [params addObject:since_id];
        [since_id release];
    }
    if(count){
        OARequestParameter *countparam = [[OARequestParameter alloc] initWithName:@"count" value:[NSString stringWithFormat:@"%@",count]];
        [params addObject:countparam];
        [countparam release];
    }
    
    
    [request setParameters:params];
    
    //request type is post
    [request setHTTPMethod:@"GET"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];
}

/***************END Feed API Calls **************************/


/*************** Checkins API Calls **************************/

- (void)retrieveRecentCheckinsForUserId:(NSString *)userid mediaId:(NSString *)mediaid withMaxId:(NSString *)maxid sinceId:(NSString *)since numberOfResults:(NSString *)count{
    
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/checkins.json"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    //NSLog(@"%@",query);
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:5];
    if(userid){
        OARequestParameter *user_id = [[OARequestParameter alloc] initWithName:@"user_id" value:[NSString stringWithFormat:@"%@",userid]];
        [params addObject:user_id];
        [user_id release];
    }
    if(mediaid){
        OARequestParameter *media_id = [[OARequestParameter alloc] initWithName:@"media_id" value:[NSString stringWithFormat:@"%@",mediaid]];
        [params addObject:media_id];
        [media_id release];
    }
    if(maxid){
        OARequestParameter *max_id = [[OARequestParameter alloc] initWithName:@"max_id" value:[NSString stringWithFormat:@"%@",maxid]];
        [params addObject:max_id];
        [max_id release];
    }
    if(since){
        OARequestParameter *since_id = [[OARequestParameter alloc] initWithName:@"since_id" value:[NSString stringWithFormat:@"%@",since]];
        [params addObject:since_id];
        [since_id release];
    }
    if(count){
        OARequestParameter *countparam = [[OARequestParameter alloc] initWithName:@"count" value:[NSString stringWithFormat:@"%@",count]];
        [params addObject:countparam];
        [countparam release];
    }
    
    
    [request setParameters:params];
    
    //request type is post
    [request setHTTPMethod:@"GET"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];
    
}
- (void)createCheckinForMediaId:(NSString *)mediaid withSeasonNum:(NSString *)season episodeNum:(NSString *)episode comment:(NSString *)comment postToFacebook:(NSString *)facebook postToTwitter:(NSString *)twitter{
    
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/checkins.json"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    //NSLog(@"%@",query);
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:6];
    if(mediaid){
        OARequestParameter *media_id = [[OARequestParameter alloc] initWithName:@"media_id" value:[NSString stringWithFormat:@"%@",mediaid]];
        [params addObject:media_id];
        [media_id release];
    }
    if(season){
        OARequestParameter *season_num = [[OARequestParameter alloc] initWithName:@"season_num" value:[NSString stringWithFormat:@"%@",season]];
        [params addObject:season_num];
        [season_num release];
    }
    if(episode){
        OARequestParameter *episode_num = [[OARequestParameter alloc] initWithName:@"episode_num" value:[NSString stringWithFormat:@"%@",episode]];
        [params addObject:episode_num];
        [episode_num release];
    }
    if(comment){
        OARequestParameter *commentparam = [[OARequestParameter alloc] initWithName:@"comment" value:[NSString stringWithFormat:@"%@",comment]];
        [params addObject:commentparam];
        [commentparam release];
    }
    if(facebook){
        OARequestParameter *facebookparam = [[OARequestParameter alloc] initWithName:@"facebook" value:[NSString stringWithFormat:@"%@",facebook]];
        [params addObject:facebookparam];
        [facebookparam release];
    }
    if(twitter){
        OARequestParameter *twitterparam = [[OARequestParameter alloc] initWithName:@"twitter" value:[NSString stringWithFormat:@"%@",twitter]];
        [params addObject:twitterparam];
        [twitterparam release];
    }
    
    //request type is post
    [request setHTTPMethod:@"POST"];
    [request setParameters:params];
    
    
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];
    
}

/***************END Checkins API Calls **************************/

/*************** Badges API Calls **************************/

- (void)retrieveListOfBadgesForUserId:(NSString *)userid inCategory:(NSString *)category{
    
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/badges.json"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    //NSLog(@"%@",query);
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:2];
    if(userid){
        OARequestParameter *user_id = [[OARequestParameter alloc] initWithName:@"user_id" value:[NSString stringWithFormat:@"%@",userid]];
        [params addObject:user_id];
        [user_id release];
    }
    if(category){
        OARequestParameter *categoryparam = [[OARequestParameter alloc] initWithName:@"category" value:[NSString stringWithFormat:@"%@",category]];
        [params addObject:categoryparam];
        [categoryparam release];
    }
        
    
    [request setParameters:params];
    
    //request type is post
    [request setHTTPMethod:@"GET"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];
}

/***************END Badges API Calls **************************/


/*************** Episodes API Calls **************************/

- (void)retrieveEpisodesForMediaId:(NSString *)mediaid withSeasonNum:(NSString *)season numberOfResults:(NSString *)count{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/episodes.json"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    //NSLog(@"%@",query);
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:3];
    if(mediaid){
        OARequestParameter *media_id = [[OARequestParameter alloc] initWithName:@"media_id" value:[NSString stringWithFormat:@"%@",mediaid]];
        [params addObject:media_id];
        [media_id release];
    }
    if(season){
        OARequestParameter *season_num = [[OARequestParameter alloc] initWithName:@"season_num" value:[NSString stringWithFormat:@"%@",season]];
        [params addObject:season_num];
        [season_num release];
    }
    if(count){
        OARequestParameter *countparam = [[OARequestParameter alloc] initWithName:@"count" value:[NSString stringWithFormat:@"%@",count]];
        [params addObject:countparam];
        [countparam release];
    }
    
    
    [request setParameters:params];
    
    //request type is post
    [request setHTTPMethod:@"GET"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];   
    [consumer release];
    [request release];
}

- (void)retrieveEpisodeInfoForMediaId:(NSString *)media withSeasonNum:(NSString *)season episodeNum:(NSString *)episode{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/episodes/show.json"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    //NSLog(@"%@",query);
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:3];
    if(media){
        OARequestParameter *media_id = [[OARequestParameter alloc] initWithName:@"media_id" value:[NSString stringWithFormat:@"%@",media]];
        [params addObject:media_id];
        [media_id release];
    }
    if(season){
        OARequestParameter *season_num = [[OARequestParameter alloc] initWithName:@"season_num" value:[NSString stringWithFormat:@"%@",season]];
        [params addObject:season_num];
        [season_num release];
    }
    if(episode){
        OARequestParameter *episode_num = [[OARequestParameter alloc] initWithName:@"episode_num" value:[NSString stringWithFormat:@"%@",episode]];
        [params addObject:episode_num];
        [episode_num release];
    }
    
    
    [request setParameters:params];
    
    //request type is post
    [request setHTTPMethod:@"GET"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];
}


/***************END Episodes API Calls **************************/

/*************** Notifications API Calls **************************/
- (void)retrieveNotificationsForUser{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/notifications.json"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    //NSLog(@"%@",query);
        
    //request type is post
    [request setHTTPMethod:@"GET"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];
}

- (void)retrieveSingleNotificationWithId:(NSString *)notificationid{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:misoKey
                                                    secret:misoSecret];
    
    //set access token url
    NSURL *url = [NSURL URLWithString:@"http://gomiso.com/api/oauth/v1/notifications/show.json"];
    
    //create oauth request with our url and consumer
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:self.accessToken   // our new request token goes here
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    
    //create an oauth parameter for the token and verifier in order to pass it to the access url
    //[request setOAuthParameterName:@"oauth_token" withValue:];
    //NSLog(@"%@",query);
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:1];
    if(notificationid){
        OARequestParameter *notification_id = [[OARequestParameter alloc] initWithName:@"notification_id" value:[NSString stringWithFormat:@"%@",notificationid]];
        [params addObject:notification_id];
        [notification_id release];
    }
    
    
    [request setParameters:params];
    //request type is post
    [request setHTTPMethod:@"GET"];
    
    //begin fetching oauth data
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(apiTicket:didFailWithError:)];
    [consumer release];
    [request release];
}

/***************END Notifications API Calls **************************/


/*************** utility functions ***********************/
- (void)apiTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    //NSLog(responseBody);
    NSDictionary *responsedata = [responseBody JSONValue];
    //NSLog(@"%@",responsedata);    
    [delegate finishedRetrievingApi:responsedata];
    [responseBody release];
    
}

- (void)apiTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {

}

- (NSDictionary *)parseQueryString:(NSString *)query {

    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithCapacity:6] autorelease];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];

    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [dict setObject:val forKey:key];
    }
    return dict;
}



@end
