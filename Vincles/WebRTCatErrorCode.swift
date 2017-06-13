/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import Foundation

enum WebRTCatErrorCode: Int {
    case CantJoinRoom = 101
    case CantConnectToSignallingServer = 102
    case CantMessageRoom = 103
    case IceConnectionFailed = 104
    case InternalStateMachineError = 105
    case UserVinclesNotLinkedAnymore = 106
    case SignalingServerConnectionError = 201
    case SignalingServerConnectionClosed = 202
    case SignalingServerReportedError = 301
    case UnknownSignalingServerMessage = 302
    case GeneralError = 500
    case NotWebRTCError = 600
    
}
