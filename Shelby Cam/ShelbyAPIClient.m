//
//  ShelbyAPIClient.m
//  Shelby Chat
//
//  Created by Arthur Ariel Sabintsev on 12/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "ShelbyAPIClient.h"


@implementation ShelbyAPIClient

+ (void)postAuthenticationWithEmail:(NSString*)email andPassword:(NSString*)password
{
 
    NSString *requestString = [NSString stringWithFormat:kAPIShelbyPostAuthorizeEmail, email, password];
    NSURL *requestURL = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod:@"POST"];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        if ( response.statusCode == 200 ) {
         
            DLog(@"Login Successful");
            
            NSArray *responseArray = [JSON objectForKey:@"result"];
            NSString *authToken = [responseArray valueForKey:@"authentication_token"];
            [[NSUserDefaults standardUserDefaults] setValue:authToken forKey:kShelbyAuthToken];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kShelbyUserDidAuthenticate
                                                                object:nil];
            
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        DLog(@"Authenticaiton failed with error %@", error);
        
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Error"
                                                            message:@"Please try again."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        
    }];
    
    [operation start];
    
}

+ (void)getPersonalRoll
{

    
    
}

@end