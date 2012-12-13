//
//  Constants.h
//  Shelby Oracle
//
//  Created by Arthur Ariel Sabintsev on 12/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

/// API Constants
#define kAPIShelbyPostAuthorizeEmail        @"https://api.shelby.tv/v1/token?email=%@&password=%@"
#define kAPIShelbyGetRollFrames             @"https://api.shelby.tv/v1/roll/%@/frames?auth_token=%@"
#define kAPIShelbyGetMoreRollFrames         @"https://api.shelby.tv/v1/roll/%@/frames?auth_token=%@&skip=%@&limit=20"

/// NSUserDefault Constants
#define kShelbyAuthToken    @"Shelby Authorization Token"