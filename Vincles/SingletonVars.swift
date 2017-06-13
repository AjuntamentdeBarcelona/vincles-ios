/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import Foundation
import SwiftyJSON

enum MenuInitDestination {
    case Inicio
    case Redes
    case Mensajes
    case CrearMensajes
    case VideoLlamada
    case Trucant
    case Agenda
}

class SingletonVars {
    
    static let sharedInstance = SingletonVars()
    
    var initMenuHasToChange = false
    var isFirstAppLoad = false
    var idRoomCall = ""
    var idUserCall = ""
    var callInProgress = false
    var notificationCallActive = false
    var initDestination:MenuInitDestination = .Inicio
    var isCaller = true
    var currentUserVincles:UserVincle?
    var notisAry:[JSON] = []
    var lastNotiProcess:Double = 0
    
    let serialQueueNotis = dispatch_queue_create(
        "com.vincles.serialQueueNotis", DISPATCH_QUEUE_SERIAL)

    
}
