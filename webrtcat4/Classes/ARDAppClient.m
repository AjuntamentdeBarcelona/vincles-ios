/*
 *  Copyright 2014 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "ARDAppClient+Internal.h"

#import "WebRTC/RTCAudioTrack.h"
#import "WebRTC/RTCCameraVideoCapturer.h"
#import "WebRTC/RTCConfiguration.h"
#import "WebRTC/RTCFileLogger.h"
#import "WebRTC/RTCFileVideoCapturer.h"
#import "WebRTC/RTCIceServer.h"
#import "WebRTC/RTCLogging.h"
#import "WebRTC/RTCMediaConstraints.h"
#import "WebRTC/RTCMediaStream.h"
#import "WebRTC/RTCPeerConnectionFactory.h"
#import "WebRTC/RTCRtpSender.h"
#import "WebRTC/RTCRtpTransceiver.h"
#import "WebRTC/RTCTracing.h"
#import "WebRTC/RTCVideoCodecFactory.h"
#import "WebRTC/RTCVideoSource.h"
#import "WebRTC/RTCVideoTrack.h"

#import "ARDAppEngineClient.h"
#import "ARDJoinResponse.h"
#import "ARDMessageResponse.h"
#import "ARDSettingsModel.h"
#import "ARDSignalingMessage.h"
#import "ARDTURNClient+Internal.h"
#import "ARDUtilities.h"
#import "ARDWebSocketChannel.h"
#import "RTCIceCandidate+JSON.h"
#import "RTCSessionDescription+JSON.h"

static NSString *kARDRoomServerByeFormat = @"%@/leave/%@/%@";
static NSString *kARDRoomServerMessageFormat = @"%@/message/%@/%@";

static NSString * const kARDMediaStreamId = @"ARDAMS";
static NSString * const kARDAudioTrackId = @"ARDAMSa0";
static NSString * const kARDVideoTrackId = @"ARDAMSv0";
static NSString * const kARDVideoTrackKind = @"video";

// TODO(tkchin): Add these as UI options.
static BOOL const kARDAppClientEnableTracing = YES;
static BOOL const kARDAppClientEnableRtcEventLog = YES;
static int64_t const kARDAppClientAecDumpMaxSizeInBytes = 5e6;  // 5 MB.
static int64_t const kARDAppClientRtcEventLogMaxSizeInBytes = 5e6;  // 5 MB.
static int const kKbpsMultiplier = 1000;

// We need a proxy to NSTimer because it causes a strong retain cycle. When
// using the proxy, |invalidate| must be called before it properly deallocs.
@interface ARDTimerProxy : NSObject

- (instancetype)initWithInterval:(NSTimeInterval)interval
                         repeats:(BOOL)repeats
                    timerHandler:(void (^)(void))timerHandler;
- (void)invalidate;

@end

@implementation ARDTimerProxy {
    NSTimer *_timer;
    void (^_timerHandler)(void);
}

- (instancetype)initWithInterval:(NSTimeInterval)interval
                         repeats:(BOOL)repeats
                    timerHandler:(void (^)(void))timerHandler {
    NSParameterAssert(timerHandler);
    if (self = [super init]) {
        _timerHandler = timerHandler;
        _timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                  target:self
                                                selector:@selector(timerDidFire:)
                                                userInfo:nil
                                                 repeats:repeats];
    }
    return self;
}

- (void)invalidate {
    [_timer invalidate];
}

- (void)timerDidFire:(NSTimer *)timer {
    _timerHandler();
}

@end

@implementation ARDAppClient {
    RTCFileLogger *_fileLogger;
    ARDTimerProxy *_statsTimer;
    ARDSettingsModel *_settings;
    RTCVideoTrack *_localVideoTrack;
}

@synthesize shouldGetStats = _shouldGetStats;
@synthesize state = _state;
@synthesize delegate = _delegate;
@synthesize roomServerClient = _roomServerClient;
@synthesize channel = _channel;
@synthesize loopbackChannel = _loopbackChannel;
@synthesize turnClient = _turnClient;
@synthesize peerConnection = _peerConnection;
@synthesize factory = _factory;
@synthesize messageQueue = _messageQueue;
@synthesize isTurnComplete = _isTurnComplete;
@synthesize hasReceivedSdp  = _hasReceivedSdp;
@synthesize roomId = _roomId;
@synthesize clientId = _clientId;
@synthesize isInitiator = _isInitiator;
@synthesize iceServers = _iceServers;
@synthesize webSocketURL = _websocketURL;
@synthesize webSocketRestURL = _websocketRestURL;
@synthesize defaultPeerConnectionConstraints =
_defaultPeerConnectionConstraints;
@synthesize isLoopback = _isLoopback;

- (instancetype)init {
    return [self initWithDelegate:nil urlBase:nil];
}

- (instancetype)initWithDelegate:(id<ARDAppClientDelegate>)delegate  urlBase:(NSString *)urlBase{
    if (self = [super init]) {
        _roomServerClient = [[ARDAppEngineClient alloc] initWithUrlBase:urlBase];
        _delegate = delegate;
        NSURL *turnRequestURL = [NSURL URLWithString:urlBase];
        _turnClient = [[ARDTURNClient alloc] initWithURL:turnRequestURL];
        [self configure];
    }
    return self;
}

- (void)setSTUNServer:(NSString *) stunServer {
    NSArray<NSString *> *myArray = [NSArray<NSString *> arrayWithObjects:stunServer, nil];
    _iceServers = [NSMutableArray arrayWithObject:[[RTCIceServer alloc] initWithURLStrings:myArray username:@"" credential:@""]];
}

- (void) addRTCICEServer:(NSString *) url username:(NSString *)username password:(NSString *) password{
    
    NSArray<NSString *> *myArray = [NSArray<NSString *> arrayWithObjects:url, nil];
    RTCIceServer *RTCICEServer_1 = [[RTCIceServer alloc] initWithURLStrings:myArray
                                                                   username:username
                                                                 credential:password];
    RTCLog(@"USERNAME %@", username);
    RTCLog(@"PASSWORD %@", password);

    [_iceServers addObject:RTCICEServer_1];
    
}

// TODO(tkchin): Provide signaling channel factory interface so we can recreate
// channel if we need to on network failure. Also, make this the default public
// constructor.
- (instancetype)initWithRoomServerClient:(id<ARDRoomServerClient>)rsClient
                        signalingChannel:(id<ARDSignalingChannel>)channel
                              turnClient:(id<ARDTURNClient>)turnClient
                                delegate:(id<ARDAppClientDelegate>)delegate {
    NSParameterAssert(rsClient);
    NSParameterAssert(channel);
    NSParameterAssert(turnClient);
    if (self = [super init]) {
        _roomServerClient = rsClient;
        _channel = channel;
        _turnClient = turnClient;
        _delegate = delegate;
        [self configure];
    }
    return self;
}

- (void)configure {
    _messageQueue = [NSMutableArray array];
    _iceServers = [NSMutableArray array];
    _fileLogger = [[RTCFileLogger alloc] init];
    [_fileLogger start];
}

- (void)dealloc {
    self.shouldGetStats = NO;
    [self disconnect];
}

- (void)setShouldGetStats:(BOOL)shouldGetStats {
    if (_shouldGetStats == shouldGetStats) {
        return;
    }
    if (shouldGetStats) {
        __weak ARDAppClient *weakSelf = self;
        _statsTimer = [[ARDTimerProxy alloc] initWithInterval:1
                                                      repeats:YES
                                                 timerHandler:^{
                                                     ARDAppClient *strongSelf = weakSelf;
                                                     [strongSelf.peerConnection statsForTrack:nil
                                                                             statsOutputLevel:RTCStatsOutputLevelDebug
                                                                            completionHandler:^(NSArray *stats) {
                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                    ARDAppClient *strongSelf = weakSelf;
                                                                                    [strongSelf.delegate appClient:strongSelf didGetStats:stats];
                                                                                });
                                                                            }];
                                                 }];
    } else {
        [_statsTimer invalidate];
        _statsTimer = nil;
    }
    _shouldGetStats = shouldGetStats;
}

- (void)setState:(ARDAppClientState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    [_delegate appClient:self didChangeState:_state];
}

- (void) startCalling {
    RTCLog(@"startCalling");

    [self sendConnectedToBackend];
    [self sendAnswerLocal];
    [_delegate appClient:self callStart:@"call start"];
    
    
}

- (void)sendConnectedToBackend {
    NSString *urlString =
    [NSString stringWithFormat:kARDRoomServerMessageFormat, self.serverHostUrl, _roomId, _clientId];
    NSURL *url = [NSURL URLWithString:urlString];
    RTCLog(@"C->RS: BYE");
    //Make sure to do a POST
    
    NSDictionary *dict = @{ @"type" : @"system:answer", @"sourceClientName" : self.username};
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    NSData* dataObj = [myString dataUsingEncoding:NSUTF8StringEncoding];
    [NSURLConnection sendAsyncPostToURL:url withData:dataObj completionHandler:^(BOOL succeeded, NSData *data) {
        if (succeeded) {
            RTCLog(@"sended ok");
        } else {
            RTCLog(@"Failed");
        }
    }];
}

- (void) sendAnswerLocal {
    ARDSessionDescriptionMessage *message =
    [[ARDSessionDescriptionMessage alloc] initWithDescription:_peerConnection.localDescription];
    [self sendSignalingMessage:message];
    [self setMaxBitrateForPeerConnectionVideoSender];
}

- (void) sendAnswer {
    
    RTCMediaConstraints *constraints = [self defaultAnswerConstraints];
    [_peerConnection answerForConstraints:constraints completionHandler:nil];
}

- (void) setUsername:(NSString*)username{
    self.username = username;
}
- (void)connectToRoomWithId:(NSString *)roomId
                   settings:(ARDSettingsModel *)settings
                 isLoopback:(BOOL)isLoopback
                   username:(NSString*)username{
    [_messageQueue removeAllObjects];

    NSParameterAssert(roomId.length);
    NSParameterAssert(_state == kARDAppClientStateDisconnected);
    _settings = settings;
    _isLoopback = isLoopback;
    _username = username;
    
    self.state = kARDAppClientStateConnecting;
    
    RTCDefaultVideoDecoderFactory *decoderFactory = [[RTCDefaultVideoDecoderFactory alloc] init];
    RTCDefaultVideoEncoderFactory *encoderFactory = [[RTCDefaultVideoEncoderFactory alloc] init];
    encoderFactory.preferredCodec = [settings currentVideoCodecSettingFromStore];
    _factory = [[RTCPeerConnectionFactory alloc] initWithEncoderFactory:encoderFactory
                                                         decoderFactory:decoderFactory];
    
#if defined(WEBRTC_IOS)
    if (kARDAppClientEnableTracing) {
        NSString *filePath = [self documentsFilePathForFileName:@"webrtc-trace.txt"];
        RTCStartInternalCapture(filePath);
    }
#endif
    
    // Request TURN.
    __weak ARDAppClient *weakSelf = self;
   
  //     [_turnClient requestServersWithCompletionHandler:^(NSArray *turnServers,
  //                                                        NSError *error) {
  //         if (error) {
            // [self.delegate appClient:weakSelf didError:ICE_CONNECTION_FAILED];
  //         }
  //         ARDAppClient *strongSelf = weakSelf;
  //         [strongSelf.iceServers addObjectsFromArray:turnServers];
        self.isTurnComplete = YES;
        [self startSignalingIfReady];
        
        // Join room on room server.
        [_roomServerClient joinRoomWithRoomId:roomId
                                   isLoopback:isLoopback
                            completionHandler:^(ARDJoinResponse *response, NSError *error) {
                                ARDAppClient *strongSelf = weakSelf;
                                if (error) {
                                    RTCLog(@"connectToRoomWithId error");
                                    [strongSelf.delegate appClient:strongSelf didError:CANT_JOIN_ROOM];
                                    [strongSelf disconnect];
                                    return;
                                }
                                WebRtcCatErrorCode joinError =
                                [[strongSelf class] errorForJoinResultType:response.result];
                                if (joinError != NO_ERROR) {
                                    RTCLog(@"Failed to join room:%@ on room server.", roomId);
                                    [strongSelf.delegate appClient:strongSelf didError:joinError];
                                    [strongSelf disconnect];
                                    return;
                                }
                                RTCLog(@"Joined room:%@ on room server.", roomId);
                                strongSelf.roomId = response.roomId;
                                strongSelf.clientId = response.clientId;
                                
                                strongSelf.isInitiator = response.isInitiator;
                                for (ARDSignalingMessage *message in response.messages) {
                                    if (message.type == kARDSignalingMessageTypeOffer ||
                                        message.type == kARDSignalingMessageTypeAnswer) {
                                        strongSelf.hasReceivedSdp = YES;
                                        [strongSelf.messageQueue insertObject:message atIndex:0];
                                    } else {
                                        [strongSelf.messageQueue addObject:message];
                                    }
                                }
                                
                                strongSelf.webSocketURL = response.webSocketURL;
                                strongSelf.webSocketRestURL = response.webSocketRestURL;
                                [strongSelf registerWithColliderIfReady];
                                [strongSelf startSignalingIfReady];
                            }];
  //     }];
    
 
 
    
  
}

- (void)disconnect {
    if (_state == kARDAppClientStateDisconnected) {
        return;
    }
    if (self.hasJoinedRoomServerRoom) {
       [self unregisterWithRoomServer];
    //       [_roomServerClient leaveRoomWithRoomId:_roomId
     //                                    clientId:_clientId
     //                           completionHandler:nil];
    }
    if (_channel) {
        if (_channel.state == kARDSignalingChannelStateRegistered) {
            // Tell the other client we're hanging up.
              ARDByeMessage *byeMessage = [[ARDByeMessage alloc] init];
             [_channel sendMessage:byeMessage];
        }
        // Disconnect from collider.
        _channel = nil;
    }
    _clientId = nil;
    _roomId = nil;
    _isInitiator = NO;
    _hasReceivedSdp = NO;
    _messageQueue = [NSMutableArray array];
    _localVideoTrack = nil;
#if defined(WEBRTC_IOS)
    [_factory stopAecDump];
    [_peerConnection stopRtcEventLog];
#endif
    [_peerConnection close];
    _peerConnection = nil;
    self.state = kARDAppClientStateDisconnected;
#if defined(WEBRTC_IOS)
    if (kARDAppClientEnableTracing) {
        RTCStopInternalCapture();
    }
#endif
}

- (void)unregisterWithRoomServer {
    NSString *urlString =
    [NSString stringWithFormat:kARDRoomServerByeFormat, self.serverHostUrl, _roomId, _clientId];
    NSURL *url = [NSURL URLWithString:urlString];
    RTCLog(@"C->RS: BYE");
    //Make sure to do a POST
    [NSURLConnection sendAsyncPostToURL:url withData:nil completionHandler:^(BOOL succeeded, NSData *data) {
        if (succeeded) {
            RTCLog(@"Unregistered from room server.");
        } else {
            RTCLog(@"Failed to unregister from room server.");
        }
    }];
}

#pragma mark - ARDSignalingChannelDelegate

- (void)channel:(id<ARDSignalingChannel>)channel
didReceiveMessage:(ARDSignalingMessage *)message {
    
    switch (message.type) {
        case kARDSignalingMessageTypeOffer:
            RTCLog(@"offer");
        case kARDSignalingMessageTypeAnswer:
            RTCLog(@"answer");
            // Offers and answers must be processed before any other message, so we
            // place them at the front of the queue.
            _hasReceivedSdp = YES;
            if (_isInitiator) {
                [_delegate appClient:self callStart:@"call start"];
            }
            [_messageQueue insertObject:message atIndex:0];
            break;
        case kARDSignalingMessageTypeCandidate:
            RTCLog(@"candidate");
        case kARDSignalingMessageTypeCandidateRemoval:
            RTCLog(@"candidate removal");
            [_messageQueue addObject:message];
            break;
        case kARDSignalingMessageTypeBye:
            RTCLog(@"bye message");
            [self processSignalingMessage:message];
            return;
    }
    [self drainMessageQueueIfReady];
}

- (void)channel:(id<ARDSignalingChannel>)channel
 didChangeState:(ARDSignalingChannelState)state {
    switch (state) {
        case kARDSignalingChannelStateOpen:
            RTCLog(@"kARDSignalingChannelStateOpen");

            break;
        case kARDSignalingChannelStateRegistered:
            RTCLog(@"kARDSignalingChannelStateRegistered");
            break;
        case kARDSignalingChannelStateClosed:
            RTCLog(@"kARDSignalingChannelStateClosed");
            break;
        case kARDSignalingChannelStateError:
            RTCLog(@"kARDSignalingChannelStateError");
            [self.delegate appClient:self didError:SOCKET_ERROR];
            // TODO(tkchin): reconnection scenarios. Right now we just disconnect
            // completely if the websocket connection fails.
            [self disconnect];
            break;
    }
}

#pragma mark - RTCPeerConnectionDelegate
// Callbacks for this delegate occur on non-main thread and need to be
// dispatched back to main queue as needed.

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeSignalingState:(RTCSignalingState)stateChanged {
    RTCLog(@"Signaling state changed: %ld", (long)stateChanged);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
          didAddStream:(RTCMediaStream *)stream {
    RTCLog(@"Stream with %lu video tracks and %lu audio tracks was added.",
           (unsigned long)stream.videoTracks.count,
           (unsigned long)stream.audioTracks.count);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didStartReceivingOnTransceiver:(RTCRtpTransceiver *)transceiver {
    RTCMediaStreamTrack *track = transceiver.receiver.track;
    RTCLog(@"Now receiving %@ on track %@.", track.kind, track.trackId);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
       didRemoveStream:(RTCMediaStream *)stream {
    RTCLog(@"Stream was removed.");
}

- (void)peerConnectionShouldNegotiate:(RTCPeerConnection *)peerConnection {
    RTCLog(@"WARNING: Renegotiation needed but unimplemented.");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeIceConnectionState:(RTCIceConnectionState)newState {
    dispatch_async(dispatch_get_main_queue(), ^{
        RTCLog(@"ICE state changed: %ld", (long)newState);
        [self->_delegate appClient:self didChangeConnectionState:newState];
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeIceGatheringState:(RTCIceGatheringState)newState {
    RTCLog(@"ICE gathering state changed: %ld", (long)newState);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didGenerateIceCandidate:(RTCIceCandidate *)candidate {
    RTCLog(@"didGenerateIceCandidate");
    dispatch_async(dispatch_get_main_queue(), ^{
        ARDICECandidateMessage *message =
        [[ARDICECandidateMessage alloc] initWithCandidate:candidate];
        [self sendSignalingMessage:message];
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didRemoveIceCandidates:(NSArray<RTCIceCandidate *> *)candidates {
    RTCLog(@"didRemoveIceCandidates");

    dispatch_async(dispatch_get_main_queue(), ^{
        ARDICECandidateRemovalMessage *message =
        [[ARDICECandidateRemovalMessage alloc]
         initWithRemovedCandidates:candidates];
        [self sendSignalingMessage:message];
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didOpenDataChannel:(RTCDataChannel *)dataChannel {
    RTCLog(@"didOpenDataChannel");

}

#pragma mark - RTCSessionDescriptionDelegate
// Callbacks for this delegate occur on non-main thread and need to be
// dispatched back to main queue as needed.

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didCreateSessionDescription:(RTCSessionDescription *)sdp
                 error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        RTCLog(@"SPD %@", sdp.sdp);
        __weak ARDAppClient *weakSelf = self;

        if (error) {
            RTCLog(@"Failed to create session description. Error: %@", error);
            [self.delegate appClient:weakSelf didError:CREATE_SPD_ERROR];
            [self disconnect];
 
            return;
        }
        [self.peerConnection setLocalDescription:sdp
                           completionHandler:^(NSError *error) {
                               ARDAppClient *strongSelf = weakSelf;
                               [strongSelf peerConnection:strongSelf.peerConnection
                        didSetSessionDescriptionWithError:error];
                           }];
        
        if (self.isInitiator) {
            ARDSessionDescriptionMessage *message =
            [[ARDSessionDescriptionMessage alloc] initWithDescription:sdp];
            [self sendSignalingMessage:message];
            [self setMaxBitrateForPeerConnectionVideoSender];
        }
        
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didSetSessionDescriptionWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            RTCLog(@"Failed to set session description. Error: %@", error);
            [self disconnect];

            [self.delegate appClient:self didError:SET_SPD_ERROR];
            return;
        }
        // If we're answering and we've just set the remote offer we need to create
        // an answer and set the local description.
        if (!self.isInitiator && !self.peerConnection.localDescription) {
            RTCMediaConstraints *constraints = [self defaultAnswerConstraints];
            __weak ARDAppClient *weakSelf = self;
            [self.peerConnection answerForConstraints:constraints
                                completionHandler:^(RTCSessionDescription *sdp,
                                                    NSError *error) {
                                    RTCLog(@"SPD %@", sdp.sdp);

                                    if(error){
                                        [self.delegate appClient:self didError:SET_SPD_ERROR];
                                        return;
                                    }
                                    ARDAppClient *strongSelf = weakSelf;
                                    [strongSelf peerConnection:strongSelf.peerConnection
                                   didCreateSessionDescription:sdp
                                                         error:error];
                                }];
        }
    });
}

#pragma mark - Private

#if defined(WEBRTC_IOS)

- (NSString *)documentsFilePathForFileName:(NSString *)fileName {
    NSParameterAssert(fileName.length);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirPath = paths.firstObject;
    NSString *filePath =
    [documentsDirPath stringByAppendingPathComponent:fileName];
    return filePath;
}

#endif

- (BOOL)hasJoinedRoomServerRoom {
    RTCLog(@"JOINROOM");
    return _clientId.length;
}

// Begins the peer connection connection process if we have both joined a room
// on the room server and tried to obtain a TURN server. Otherwise does nothing.
// A peer connection object will be created with a stream that contains local
// audio and video capture. If this client is the caller, an offer is created as
// well, otherwise the client will wait for an offer to arrive.
- (void)startSignalingIfReady {
    if (!_isTurnComplete || !self.hasJoinedRoomServerRoom) {
        return;
    }
    self.state = kARDAppClientStateConnected;
    
    // Create peer connection.
    RTCMediaConstraints *constraints = [self defaultPeerConnectionConstraints];
    RTCConfiguration *config = [[RTCConfiguration alloc] init];
    config.iceServers = _iceServers;
    config.sdpSemantics = RTCSdpSemanticsUnifiedPlan;
    _peerConnection = [_factory peerConnectionWithConfiguration:config
                                                    constraints:constraints
                                                       delegate:self];
    // Create AV senders.
    [self createMediaSenders];
    
    if (_isInitiator) {
        // Send offer.
        __weak ARDAppClient *weakSelf = self;
        [_peerConnection offerForConstraints:[self defaultOfferConstraints]
                           completionHandler:^(RTCSessionDescription *sdp,
                                               NSError *error) {

                               if(error != nil){
                                   [self->_delegate appClient:weakSelf didError:UNKNOWN_ERROR];
                               }
                               ARDAppClient *strongSelf = weakSelf;
                               [strongSelf peerConnection:strongSelf.peerConnection
                              didCreateSessionDescription:sdp
                                                    error:error];
                           }];
    } else {
        // Check if we've received an offer.
        [self drainMessageQueueIfReady];
    }
#if defined(WEBRTC_IOS)
    // Start event log.
    if (kARDAppClientEnableRtcEventLog) {
        NSString *filePath = [self documentsFilePathForFileName:@"webrtc-rtceventlog"];
        if (![_peerConnection startRtcEventLogWithFilePath:filePath
                                            maxSizeInBytes:kARDAppClientRtcEventLogMaxSizeInBytes]) {
            RTCLog(@"Failed to start event logging.");
        }
    }
    
    // Start aecdump diagnostic recording.
    if ([_settings currentCreateAecDumpSettingFromStore]) {
        NSString *filePath = [self documentsFilePathForFileName:@"webrtc-audio.aecdump"];
        if (![_factory startAecDumpWithFilePath:filePath
                                 maxSizeInBytes:kARDAppClientAecDumpMaxSizeInBytes]) {
            RTCLog(@"Failed to start aec dump.");
        }
    }
#endif
}

// Processes the messages that we've received from the room server and the
// signaling channel. The offer or answer message must be processed before other
// signaling messages, however they can arrive out of order. Hence, this method
// only processes pending messages if there is a peer connection object and
// if we have received either an offer or answer.
- (void)drainMessageQueueIfReady {
    if (!_peerConnection || !_hasReceivedSdp) {
        return;
    }
    for (ARDSignalingMessage *message in _messageQueue) {
        [self processSignalingMessage:message];
    }
    [_messageQueue removeAllObjects];
}

// Processes the given signaling message based on its type.
- (void)processSignalingMessage:(ARDSignalingMessage *)message {
    NSParameterAssert(_peerConnection ||
                      message.type == kARDSignalingMessageTypeBye);
    switch (message.type) {
        case kARDSignalingMessageTypeOffer:
            RTCLog(@"processSignalingMessage kARDSignalingMessageTypeOffer");
        case kARDSignalingMessageTypeAnswer: {
            RTCLog(@"processSignalingMessage kARDSignalingMessageTypeAnswer");
            ARDSessionDescriptionMessage *sdpMessage =
            (ARDSessionDescriptionMessage *)message;
            RTCSessionDescription *description = sdpMessage.sessionDescription;
            RTCLog(@"SPD description %@", description.sdp);
            RTCLog(@"SPD description2 %@", description);

            __weak ARDAppClient *weakSelf = self;
            [_peerConnection setRemoteDescription:description
                                completionHandler:^(NSError *error) {
                                    
                                    if (error != nil){
                                        NSLog(@"set remote error");
                                    }
                                    ARDAppClient *strongSelf = weakSelf;
                                    [strongSelf peerConnection:strongSelf.peerConnection
                             didSetSessionDescriptionWithError:error];
                                }];
            break;
        }
        case kARDSignalingMessageTypeCandidate: {
            RTCLog(@"processSignalingMessage kARDSignalingMessageTypeCandidate");
            ARDICECandidateMessage *candidateMessage =
            (ARDICECandidateMessage *)message;
            RTCLog(@"processSignalingMessage %@", candidateMessage.candidate);
            [_peerConnection addIceCandidate:candidateMessage.candidate];
            break;
        }
        case kARDSignalingMessageTypeCandidateRemoval: {
            RTCLog(@"processSignalingMessage kARDSignalingMessageTypeCandidateRemoval");
            ARDICECandidateRemovalMessage *candidateMessage =
            (ARDICECandidateRemovalMessage *)message;
            [_peerConnection removeIceCandidates:candidateMessage.candidates];
            break;
        }
        case kARDSignalingMessageTypeBye:
            RTCLog(@"processSignalingMessage kARDSignalingMessageTypeBye");
            // Other client disconnected.
            // TODO(tkchin): support waiting in room for next client. For now just
            // disconnect.
            [self disconnect];
            break;
    }
}

// Sends a signaling message to the other client. The caller will send messages
// through the room server, whereas the callee will send messages over the
// signaling channel.
- (void)sendSignalingMessage:(ARDSignalingMessage *)message {
    if (_isInitiator) {
        __weak ARDAppClient *weakSelf = self;
        [_roomServerClient sendMessage:message
                             forRoomId:_roomId
                              clientId:_clientId
                     completionHandler:^(ARDMessageResponse *response,
                                         NSError *error) {
                         ARDAppClient *strongSelf = weakSelf;
                         if (error) {
                             RTCLog(@"sendSignalingMessage error");
                             [strongSelf.delegate appClient:strongSelf didError:SEND_MESSAGE_ERROR];
                             return;
                         }
                         WebRtcCatErrorCode messageError =
                         [[strongSelf class] errorForMessageResultType:response.result];
                         if (messageError != NO_ERROR) {
                             [strongSelf.delegate appClient:strongSelf didError:messageError];
                             return;
                         }
                     }];
    } else {
        [_channel sendMessage:message];
    }
}

- (void)setMaxBitrateForPeerConnectionVideoSender {
    for (RTCRtpSender *sender in _peerConnection.senders) {
        if (sender.track != nil) {
            if ([sender.track.kind isEqualToString:kARDVideoTrackKind]) {
                [self setMaxBitrate:[_settings currentMaxBitrateSettingFromStore] forVideoSender:sender];
            }
        }
    }
}

- (void)setMaxBitrate:(NSNumber *)maxBitrate forVideoSender:(RTCRtpSender *)sender {
    if (maxBitrate.intValue <= 0) {
        return;
    }
    
    RTCRtpParameters *parametersToModify = sender.parameters;
    for (RTCRtpEncodingParameters *encoding in parametersToModify.encodings) {
        encoding.maxBitrateBps = @(maxBitrate.intValue * kKbpsMultiplier);
    }
    [sender setParameters:parametersToModify];
}

- (RTCRtpTransceiver *)videoTransceiver {
    for (RTCRtpTransceiver *transceiver in _peerConnection.transceivers) {
        if (transceiver.mediaType == RTCRtpMediaTypeVideo) {
            return transceiver;
        }
    }
    return nil;
}

- (void)receiveRemoteTrack {
    RTCLog(@"receiveRemoteTrack");

}

- (void)createMediaSenders {
    
    RTCMediaConstraints *constraints = [self defaultMediaAudioConstraints];
    RTCAudioSource *source = [_factory audioSourceWithConstraints:constraints];
    RTCAudioTrack *track = [_factory audioTrackWithSource:source
                                                  trackId:kARDAudioTrackId];
    
    
    [_peerConnection addTrack:track streamIds:@[ kARDMediaStreamId ]];
    
    //[_peerConnection addStream:[RTCMediaStream init]];
    _localVideoTrack = [self createLocalVideoTrack];
    
    if (_localVideoTrack) {
        
        [_peerConnection addTrack:_localVideoTrack streamIds:@[ kARDMediaStreamId ]];
        
        [_delegate appClient:self didReceiveLocalVideoTrack:_localVideoTrack];
        
        
        //[_delegate appClient:self didReceiveLocalVideoTrack:_localVideoTrack];
        // We can set up rendering for the remote track right away since the transceiver already has an
        // RTCRtpReceiver with a track. The track will automatically get unmuted and produce frames
        // once RTP is received.
        RTCVideoTrack *track = (RTCVideoTrack *)([self videoTransceiver].receiver.track);
        
        //RTCRtpTransceiver *x = [self videoTransceiver];
        //NSString *d = ([self videoTransceiver].sender.track.trackId);
        
        [_delegate appClient:self didReceiveRemoteVideoTrack:track];
    }
}

- (RTCVideoTrack *)createLocalVideoTrack {
    if ([_settings currentAudioOnlySettingFromStore]) {
        return nil;
    }
    
    RTCVideoSource *source = [_factory videoSource];
    
#if !TARGET_IPHONE_SIMULATOR
    RTCCameraVideoCapturer *capturer = [[RTCCameraVideoCapturer alloc] initWithDelegate:source];
    [_delegate appClient:self didCreateLocalCapturer:capturer];
    
#else
#if defined(__IPHONE_11_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0)
    if (@available(iOS 10, *)) {
        RTCFileVideoCapturer *fileCapturer = [[RTCFileVideoCapturer alloc] initWithDelegate:source];
        [_delegate appClient:self didCreateLocalFileCapturer:fileCapturer];
    }
#endif
#endif
    
    return [_factory videoTrackWithSource:source trackId:kARDVideoTrackId];
    
}

#pragma mark - Collider methods

- (void)registerWithColliderIfReady {
    if (!self.hasJoinedRoomServerRoom) {
        RTCLog(@"!self.hasJoinedRoomServerRoom");
        return;
    }
    // Open WebSocket connection.
    if (!_channel) {
        _channel =
        [[ARDWebSocketChannel alloc] initWithURL:_websocketURL
                                         restURL:_websocketRestURL
                                        delegate:self];
        if (_isLoopback) {
            _loopbackChannel =
            [[ARDLoopbackWebSocketChannel alloc] initWithURL:_websocketURL
                                                     restURL:_websocketRestURL];
        }
    }
    [_channel registerForRoomId:_roomId clientId:_clientId];
    if (_isLoopback) {
        [_loopbackChannel registerForRoomId:_roomId clientId:@"LOOPBACK_CLIENT_ID"];
    }
}

#pragma mark - Defaults

- (RTCMediaConstraints *)defaultMediaAudioConstraints {
    NSDictionary *mandatoryConstraints = @{};
    RTCMediaConstraints *constraints =
    [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints
                                          optionalConstraints:nil];
    return constraints;
}

- (RTCMediaConstraints *)defaultAnswerConstraints {
    return [self defaultOfferConstraints];
}

- (RTCMediaConstraints *)defaultOfferConstraints {
    NSDictionary *mandatoryConstraints = @{
                                           @"OfferToReceiveAudio" : @"true",
                                           @"OfferToReceiveVideo" : @"true"
                                           };
    RTCMediaConstraints* constraints =
    [[RTCMediaConstraints alloc]
     initWithMandatoryConstraints:mandatoryConstraints
     optionalConstraints:nil];
    return constraints;
}

- (RTCMediaConstraints *)defaultPeerConnectionConstraints {
    if (_defaultPeerConnectionConstraints) {
        return _defaultPeerConnectionConstraints;
    }
    NSString *value = _isLoopback ? @"false" : @"true";
    NSDictionary *optionalConstraints = @{ @"DtlsSrtpKeyAgreement" : value };
    RTCMediaConstraints* constraints =
    [[RTCMediaConstraints alloc]
     initWithMandatoryConstraints:nil
     optionalConstraints:optionalConstraints];
    return constraints;
}

#pragma mark - Errors

+ (WebRtcCatErrorCode)errorForJoinResultType:(ARDJoinResultType)resultType {
    WebRtcCatErrorCode errorCode = NO_ERROR;
    switch (resultType) {
        case kARDJoinResultTypeSuccess:
            RTCLog(@"kARDJoinResultTypeSuccess");
            break;
        case kARDJoinResultTypeUnknown: {
            RTCLog(@"kARDJoinResultTypeUnknown");
            errorCode = CANT_JOIN_ROOM;
            break;
        }
        case kARDJoinResultTypeFull: {
            errorCode = ROOM_FULL;
            break;
        }
    }
    return errorCode;
}

+ (WebRtcCatErrorCode)errorForMessageResultType:(ARDMessageResultType)resultType {
    WebRtcCatErrorCode errorCode = NO_ERROR;
    switch (resultType) {
        case kARDMessageResultTypeSuccess:
            RTCLog(@"kARDMessageResultTypeSuccess");

            break;
        case kARDMessageResultTypeUnknown:
            RTCLog(@"kARDMessageResultTypeUnknown");

            errorCode = UNKNOWN_ERROR;
            
            break;
        case kARDMessageResultTypeInvalidClient:
           
            errorCode = INVALID_CLIENT;
            
            break;
        case kARDMessageResultTypeInvalidRoom:
            RTCLog(@"kARDMessageResultTypeInvalidRoom");

            errorCode = ROOM_INVALID;
            break;
    }
    return errorCode;
}




@end

