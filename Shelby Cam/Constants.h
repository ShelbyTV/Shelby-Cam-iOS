//
//  Constants.h
//  Shelby Chat
//
//  Created by Arthur Ariel Sabintsev on 12/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

/// Shelby API Constants
#define kAPIShelbyPostAuthorizeEmail        @"https://api.shelby.tv/v1/token?email=%@&password=%@"
#define kAPIShelbyGetRollFrames             @"https://api.shelby.tv/v1/roll/%@/frames?auth_token=%@"
#define kAPIShelbyGetMoreRollFrames         @"https://api.shelby.tv/v1/roll/%@/frames?auth_token=%@&skip=%@&limit=20"

/// YouTube API Constants
#define kYouTubeClientID                    @"874673079602.apps.googleusercontent.com"
#define kYouTubeClientSecret                @"JRpCqgFqTc27-G5Ch5c7PxTk"
#define kYouTubeKeychainName                @"Shelby Cam"
#define kYoutubeScope                       @"https://www.googleapis.com/auth/youtube"

/// Observer Constants
#define kShelbyUserDidAuthenticate          @"Shelby User Did Authenticate"

/// NSUserDefault Constants
#define kShelbyAuthToken                    @"Shelby Authorization Token"

/// Color Constants
#define kShelbyGrayColor                    [UIColor colorWithRed:191.0f/255.0f green:191.0f/255.0f  blue:191.0f/255.0f  alpha:1.0f];