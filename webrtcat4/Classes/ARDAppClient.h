/*
 *  Copyright 2014 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <Foundation/Foundation.h>
#import "WebRTC/RTCPeerConnection.h"
#import "WebRTC/RTCVideoTrack.h"

typedef NS_ENUM(NSInteger, ARDAppClientState) {
  // Disconnected from servers.
  kARDAppClientStateDisconnected,
  // Connecting to servers.
  kARDAppClientStateConnecting,
  // Connected to servers.
  kARDAppClientStateConnected,
};

typedef NS_ENUM(NSInteger, WebRtcCatErrorCode) {
    CANT_JOIN_ROOM,
    ROOM_FULL,
    ROOM_INVALID,
    UNKNOWN_ERROR,
    INVALID_CLIENT,
    CREATE_SPD_ERROR,
    SET_SPD_ERROR,
    ICE_CONNECTION_FAILED,
    SEND_MESSAGE_ERROR,
    SOCKET_ERROR,
    CHECKING_ERROR,
    NETWORK_ERROR,
    NO_ERROR

    
    
};

@class ARDAppClient;
@class ARDSettingsModel;
@class RTCMediaConstraints;
@class RTCCameraVideoCapturer;
@class RTCFileVideoCapturer;

// The delegate is informed of pertinent events and will be called on the
// main queue.
@protocol ARDAppClientDelegate <NSObject>

- (void)appClient:(ARDAppClient *)client
    didChangeState:(ARDAppClientState)state;

- (void)appClient:(ARDAppClient *)client
    didChangeConnectionState:(RTCIceConnectionState)state;

- (void)appClient:(ARDAppClient *)client
    didCreateLocalCapturer:(RTCCameraVideoCapturer *)localCapturer;

- (void)appClient:(ARDAppClient *)client
    didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack;

- (void)appClient:(ARDAppClient *)client
    didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack;

- (void)appClient:(ARDAppClient *)client
         didError:(WebRtcCatErrorCode)error;

- (void)appClient:(ARDAppClient *)client
      didGetStats:(NSArray *)stats;

- (void)appClient:(ARDAppClient *)client
      callStart:(NSString *)message;

@optional
- (void)appClient:(ARDAppClient *)client
didCreateLocalFileCapturer:(RTCFileVideoCapturer *)fileCapturer;

@end

// Handles connections to the AppRTC server for a given room. Methods on this
// class should only be called from the main queue.
@interface ARDAppClient : NSObject

@property(nonatomic, strong) NSString *serverHostUrl;
@property(nonatomic, strong) NSString *username;

// If |shouldGetStats| is true, stats will be reported in 1s intervals through
// the delegate.
@property(nonatomic, assign) BOOL shouldGetStats;
@property(nonatomic, readonly) ARDAppClientState state;
@property(nonatomic, weak) id<ARDAppClientDelegate> delegate;
// Convenience constructor since all expected use cases will need a delegate
// in order to receive remote tracks.
- (instancetype)initWithDelegate:(id<ARDAppClientDelegate>)delegate
                         urlBase:(NSString *)urlBase;

// Establishes a connection with the AppRTC servers for the given room id.
// |settings| is an object containing settings such as video codec for the call.
// If |isLoopback| is true, the call will connect to itself.
- (void)connectToRoomWithId:(NSString *)roomId
                   settings:(ARDSettingsModel *)settings
                 isLoopback:(BOOL)isLoopback
                   username:(NSString*)username;

// Disconnects from the AppRTC servers and any connected clients.
- (void)disconnect;

// sets stun server
- (void)setSTUNServer:(NSString *) stunServer;

// sets ice server
- (void) addRTCICEServer:(NSString *) url username:(NSString *)username password:(NSString *) password;

// start calling
- (void) startCalling;
- (void) setUsername:(NSString*)username;

@end
