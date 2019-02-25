/*
 *  Copyright 2014 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "ARDTURNClient+Internal.h"

#import "ARDUtilities.h"
#import "RTCIceServer+JSON.h"

// TODO(tkchin): move this to a configuration object.
static NSString *kTURNRefererURLString = @"https://appr.tc";
static NSString *kARDTURNClientErrorDomain = @"ARDTURNClient";
static NSInteger kARDTURNClientErrorBadResponse = -1;

@implementation ARDTURNClient {
  NSURL *_url;
}

- (instancetype)initWithURL:(NSURL *)url {
  NSParameterAssert([url absoluteString].length);
  if (self = [super init]) {
    _url = url;
  }
  return self;
}

- (void)requestServersWithCompletionHandler:
    (void (^)(NSArray *turnServers, NSError *error))completionHandler {
     NSString* urlConfig = [NSString stringWithFormat:@"%@/config", _url];
      [self makeTurnServerRequestToURL:[NSURL URLWithString:urlConfig]
                 WithCompletionHandler:completionHandler];
}

#pragma mark - Private

- (void)makeTurnServerRequestToURL:(NSURL *)url
             WithCompletionHandler:(void (^)(NSArray *turnServers,
                                             NSError *error))completionHandler {
  NSMutableURLRequest *iceServerRequest = [NSMutableURLRequest requestWithURL:url];
  iceServerRequest.HTTPMethod = @"GET";
  [iceServerRequest addValue:kTURNRefererURLString forHTTPHeaderField:@"referer"];
  [NSURLConnection sendAsyncRequest:iceServerRequest
                  completionHandler:^(NSURLResponse *response,
                                      NSData *data,
                                      NSError *error) {
      if (error) {
          NSLog(@"makeTurnServerRequestToURL error");

        completionHandler(nil, error);
        return;
      }
                      
                      NSError* erro1;
                      NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                           options:kNilOptions
                                                                             error:&erro1];
                      
                      NSError* erro2;

                      NSData *data2 = [[json objectForKey:@"pc_config"] dataUsingEncoding:NSUTF8StringEncoding];
                      NSDictionary* json2 = [NSJSONSerialization JSONObjectWithData:data2
                                                                           options:kNilOptions
                                                                             error:&erro2];
                  
                      
                      NSArray* iceServers = json2[@"iceServers"];
                      NSLog(@"iceServers : %i",iceServers.count);

                      NSLog(@"%@",iceServers);

                      NSMutableArray *turnServers = [NSMutableArray array];
                      for (NSDictionary* object in iceServers) {
                         [turnServers addObject:[RTCIceServer serverFromJSONDictionary:object]];
                      }
     
                        RTCIceServer* server1 = [[RTCIceServer alloc] initWithURLStrings:[[NSArray alloc] initWithObjects:@"turn:vincles.i2cat.net:5349?transport=tcp", @"turn:vincles.i2cat.net:5349?transport=udp", nil] username:@"vincles" credential:@"vinclesdev"];
                      [turnServers addObject:server1];
                      
                  
                      
      if (!turnServers) {
          NSLog(@"Bad TURN response error");

        NSError *responseError =
          [[NSError alloc] initWithDomain:kARDTURNClientErrorDomain
                                     code:kARDTURNClientErrorBadResponse
                                 userInfo:@{
            NSLocalizedDescriptionKey: @"Bad TURN response.",
            }];
        completionHandler(nil, responseError);
        return;
      }
                      
     
                      
      completionHandler(turnServers, nil);
                   

                      
                   }];
}

@end
