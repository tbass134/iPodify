//
//  Config.h
//  iPodify
//
//  Created by Antonio Hung on 12/30/14.
//  Copyright (c) 2014 Tony Hung. All rights reserved.
//

#ifndef iPodify_Config_h
#define iPodify_Config_h

#define kClientId "fd73406af85645d9a77ec207903b064f"
#define kCallbackURL "ipodify://callback/"

#define kTokenSwapServiceURL ""
// or "http://localhost:1234/swap" with example token swap service

// If you don't provide a token swap service url the login will use implicit grant tokens, which
// means that your user will need to sign in again every time the token expires.

#define kTokenRefreshServiceURL ""
// or "http://localhost:1234/refresh" with example token refresh service

// If you don't provide a token refresh service url, the user will need to sign in again every
// time their token expires.


#endif
