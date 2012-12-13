//
//  ShelbyAPIClient.h
//  Shelby Oracle
//
//  Created by Arthur Ariel Sabintsev on 12/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShelbyAPIClient : NSObject

+ (void)postAuthenticationWithEmail:(NSString*)email andPassword:(NSString*)password;
+ (void)getPersonalRoll;

@end