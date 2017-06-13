/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import Foundation

let IP = "ip-server"
let URL_BASE = "https://\(IP)"
let BASIC_AUTH_STR = "auth-string"
let GCM_SANDBOX = true

let SERVER_HOST_URL = "https://server-host-url:port"
let TURN_SERVER_ADDRESS_1 = "turn:server-url:port?transport=udp"
let TURN_SERVER_1_USERNAME = "username"
let TURN_SERVER_1_PASSWORD = "pass"

let TURN_SERVER_ADDRESS_2 = "turn:turn-server-url:port?transport=tcp"
let TURN_SERVER_2_USERNAME = "username"
let TURN_SERVER_2_PASSWORD = "pass"

let STUN_SERVER_ADDRESS = "stun:stun-server-url:port"
let ANALYTICS_GLOBAL_TRACKER = "analytics-tracker"

let URL_BODY = "\(URL_BASE)/"
let URL_CREATE_PUBLIC_USER = "\(URL_BASE)/specific-call-url"
let URL_REGISTER_USER_VINCULAT = "\(URL_BASE)/specific-call-url"
let URL_VALIDATE_USER_VINCULAT = "\(URL_BASE)/specific-call-url"
let URL_CREATE_EXIST_USER = "\(URL_BASE)/specific-call-url"
let URL_CREATE_NEW_USER = "\(URL_BASE)/specific-call-url"
let URL_LOGIN = "\(URL_BASE)/specific-call-url"
let URL_RECOVERY = "\(URL_BASE)/specific-call-url"
let URL_LOGOUT = "\(URL_BASE)/specific-call-url"
let URL_CIRCLES_BELONG = "\(URL_BASE)/specific-call-url"
let URL_UPLOAD_CONTENT = "\(URL_BASE)/specific-call-url"
let URL_GET_MESSAGES = "\(URL_BASE)/specific-call-url"
let URL_SEND_MESSAGE = "\(URL_BASE)/specific-call-url"
let URL_ADD_DEVICE_INFO = "\(URL_BASE)/specific-call-url"
let URL_UPDATE_DEVICE_INFO = "\(URL_BASE)/specific-call-url"
let URL_UPDATE_USER_INFO = "\(URL_BASE)/specific-call-url"
let URL_CHANGE_USER_PASSWORD = "\(URL_BODY)users/me/password"
let URL_GET_USER_INFO = "\(URL_BASE)/specific-call-url"
let URL_SET_PROFILE_PHOTO = "\(URL_BASE)/specific-call-url"
let URL_GET_ALL_NOTIFICATIONS = "\(URL_BASE)/specific-call-url"



let SUCCESS = "SUCCESS"

let FAILURE = "FAILURE"

let JSON_HEADER_PUBLIC_REQUEST = [
    "Content-Type":"application/json"
]

let LOGIN_HEADER_REQUEST = [
    "Content-Type":"application/x-www-form-urlencoded",
    "Authorization":"Basic \(BASIC_AUTH_STR)"
]

let LOGOUT_HEADER_REQUEST = [
    "Content-Type":"application/x-www-form-urlencoded",
    "Authorization":"Basic \(BASIC_AUTH_STR)"
]

let RECOVERY_HEADER_REQUEST = [
    "Content-Type":"application/json"]

let MESSAGE_TYPE_IMAGE = "IMAGES_MESSAGE"
let MESSAGE_TYPE_VIDEO = "VIDEO_MESSAGE"
let MESSAGE_TYPE_TEXT = "TEXT_MESSAGE"
let MESSAGE_TYPE_AUDIO = "AUDIO_MESSAGE"


let PHOTO_MIME_PNG = "image/png"
let PHOTO_MIME_JPG = "image/jpeg"
let VIDEO_MIME_MP4 = "video/mp4"
let AUDIO_MIME_AC3 = "audio/ac3"

let USERNAME_SUFFIX = "USER-SUFFIX"

// HEX COLORS
let HEX_WHITE_BACKGROUND = "#F7F2EC"
let HEX_DARK_WHITE_SEGMENT = "#E5DFD6"
let HEX_DARK_BACK_FOOTER = "#E5DFD4"
let HEX_DARK_GREY_MY_PHOTO_BTN = "#758182"
let HEX_RED_BTN = "#DC002E"
let HEX_GRAY_BTN = "#758182"
let HEX_CELL_MSG_READ = "#D1CBC1"
let HEX_DARK_GRAY_HEADER = "#333333"

// INIT FEED TYPE CELL TYPES
let INIT_CELL_AUDIO_MSG = "AUDIO_MESSAGE"
let INIT_CELL_VIDEO_MSG = "VIDEO_MESSAGE"
let INIT_CELL_IMAGE_MSG = "IMAGES_MESSAGE"
let INIT_CELL_NEW_MESSAGE = "NEW_MESSAGE"
let INIT_CELL_CONNECTED_TO = "CONNECTED"
let INIT_CELL_DISCONNECTED_OF = "DISCONNECTED"
let INIT_CELL_EVENT_SENT = "EVENT_SENT"
let INIT_CELL_EVENT_ACCEPTED = "EVENT_ACCEPTED"
let INIT_CELL_EVENT_REJECTED = "EVENT_REJECTED"
let INIT_CELL_EVENT_DELETED = "EVENT_DELETED"
let INIT_CELL_INCOMING_EVENT = "INCOMING_EVENT"
let INIT_CELL_LOST_CALL = "LOST_CALL"
let INIT_CELL_CALL_REALIZED = "CALL_REALIZED"


// EVENTS STATES
let EVENT_STATE_PENDING = "PENDING"
let EVENT_STATE_ACCEPTED = "ACCEPTED"
let EVENT_STATE_REJECTED = "REJECTED"

// NOTIFICATION TYPE
let NOTI_NEW_EVENT = "NEW_EVENT"
let NOTI_EVENT_ACCEPTED = "EVENT_ACCEPTED"
let NOTI_EVENT_REJECTED = "EVENT_REJECTED"
let NOTI_EVENT_UPDATED = "EVENT_UPDATED"
let NOTI_EVENT_DELETED = "EVENT_DELETED"
let NOTI_NEW_MESSAGE = "NEW_MESSAGE"
let NOTI_INCOMING_CALL = "INCOMING_CALL"
let NOTI_USER_UPDATED = "USER_UPDATED"
let NOTI_USER_UNLINKED = "USER_UNLINKED"

let NOTI_TRUCANT_TRYAGAIN = "TRUCANTTRYAGAIN"
let NOTI_TRUCADAFALLADA_RETRY = "TRUCADAFALLADARETRY"
let NOTI_TRUCADAFALLADA_GIVEUP =  "TRUCADAFALLADAGIVEUP"

// RELACIÓ PARENTIU
let RELATION_PARTNER = "PARTNER"
let RELATION_CHILD = "CHILD"
let RELATION_GRANDCHILD = "GRANDCHILD"
let RELATION_CAREGIVER = "CAREGIVER"
let RELATION_FRIEND = "FRIEND"
let RELATION_VOLUNTEER = "VOLUNTEER"
let RELATION_BROTHER = "SIBLING"
let RELATION_NEPHEW = "NEPHEW"
let RELATION_OTHER = "OTHER"


// VIDEOCALL
let CALL_WAIT_LIMIT = 25.0
let VIDEO_MAX_DURATION = 120.0

// MISC

let DEFAULT_PROFILE_IMAGE = "unknownProfileImage.jpg"

//ANALYTICS
let EDITADADES_VC = "Editar perfil"
let CONFIGURA_VC = "Configuració"
let NOTAS_VC = "Notes"
let SOBREVINCLES_VC = "Sobre Vincles BCN"
let XARXES_VC = "Llistat de xarxes"
let INTROSECONDCODE_VC = "Nova xarxa"
let WELCOMEEXTRA_VC = "Benvinguda a nova xarxa"
let VIDEOTRUCADA_VC = "Vídeo-trucada trucar"
let TRUCANT_VC = "Vídeo-trucada"
let TRUCADAFALLADA_VC = "Vídeo-trucada perduda"
let INCOMINTRUCADA_VC = "Vídeo-trucada entrant"
let MISSATGESFEED_VC = "Llistat de missatges rebuts"
let NOUMISSATGE_VC = "Enviar nou missatge"
let MSGFOTOREAD_VC = "Llegir missatge d'imatge"
let MSGVIDEOREAD_VC = "Llegir missatge de vídeo"
let MSGAUDIOREAD_VC = "Llegir missatge d'àudio"
let AGENDA_VC = "Agenda"
let NOVACITA_VC = "Crear nova cita de l'agenda"
let EDITACITA_VC = "Detall de dia de l'agenda"
let INICIOTABLE_VC = "Inici"
let REGISTRATION_VC = "Nou registre"
let LOGIN_VC = "Login"
let TERMSCONDITIONS_VC = "Termes i condicions"
let HOWTO_VC = "Tour"
let RECOVERYPASS_VC = "Recuperació de constrasenya"
let CONFIRMATIONCODE_VC = "Validació d'usuari registrat"

