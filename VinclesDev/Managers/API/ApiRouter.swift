//
//  ApiManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import Alamofire

enum ApiRouter: URLRequestConvertible {
    static var baseURLString = URL_BASE
    static var OAuthToken: String?
    
    
    case Login(params: [String:Any])
    case RenewToken(params: [String:Any])
    case Logout(params: [String:Any])
    case RegisterVinculat(params: [String:Any])
    case ValidateVinculat(params: [String:Any])
    case RecoverPassword(params: [String:Any])
    case GetSelfUserInfo
    case GetContentsLibrary(params: [String:Any])
    case GetCirclesUser
    case UploadContent
    case AddContentToLibrary(params: [String:Any])
    case RemoveContentFromLibrary(params: [String:Any])
    case GetGroupsUser
    case GetCirclesUserVinculat
    case GenerateCode
    case AddCode(params: [String:Any])
    case RemoveContact(params: [String:Any])
    case ChangeUserPhoto
    case ShareContent(params: [String:Any])
    case SendInstallation(params: [String:Any])
    case UpdateInstallation(params: [String:Any])
    case GetInstallations(params: [String:Any])
    case SendUserMessage(params: [String:Any])
    case ChatUserGetMessages(params: [String:Any])
    case SendBadToken
    case GetNotifications(params: [String:Any])
    case GetNotificationById(params: [String:Any])
    case GetMessageById(params: [String:Any])
    case MarkMessageWatched(params: [String:Any])
    case ChatGroupGetMessages(params: [String:Any])
    case SendGroupMessage(params: [String:Any])
    case GetGroupMessageById(params: [String:Any])
    case RemoveContactFromVinculat(params: [String:Any])
    case GetUserBasicInfo(params: [String:Any])
    case GetServerTime
    case GetGroupParticipants(params: [String:Any])
    case GetMeetings(params: [String:Any])
    case CreateMeeting(params: [String:Any])
    case UpdateUser(params: [String:Any])
    case AcceptMeeting(params: [String:Any])
    case DeclineMeeting(params: [String:Any])
    case DeleteMeeting(params: [String:Any])
    case EditMeeting(params: [String:Any])
    case GetMeeting(params: [String:Any])
    case GetSpecificContent(params: [String:Any])
    case StartVideoConference(params: [String:Any])
    case ErrorVideoConference(params: [String:Any])
    case InviteUserFromGroup(params: [String:Any])
    case ChangePassword(params: [String:Any])
    case SendMigrationStatus
    case GetChatLastAccess(params: [String:Any])
    case PutChatLastAccess(params: [String:Any])
    case GetUserFullInfo(params: [String:Any])
    case PostDataUsage(params: [String:Any])

    var method: Alamofire.HTTPMethod {
        switch self {
        case .Login, .RenewToken, .Logout, .RegisterVinculat, .ValidateVinculat, .RecoverPassword, .UploadContent, .GenerateCode, .AddCode, .ChangeUserPhoto, .ShareContent, .SendInstallation, .SendUserMessage, .SendGroupMessage, .CreateMeeting, .StartVideoConference, .ErrorVideoConference, .InviteUserFromGroup, .ChangePassword, .AddContentToLibrary, .PostDataUsage:
            return .post
        case .GetSelfUserInfo, .GetContentsLibrary, .GetCirclesUser, .GetGroupsUser, .GetCirclesUserVinculat, .ChatUserGetMessages, .SendBadToken, .GetNotifications, .GetNotificationById, .GetMessageById, .ChatGroupGetMessages, .GetGroupMessageById, .GetUserBasicInfo, .GetServerTime, .GetGroupParticipants, .GetMeetings, .GetMeeting, .GetSpecificContent, .GetChatLastAccess, .GetInstallations, .GetUserFullInfo:
            return .get
            
        case .UpdateInstallation, .MarkMessageWatched, .UpdateUser, .AcceptMeeting, .DeclineMeeting, .EditMeeting, .SendMigrationStatus, .PutChatLastAccess:
            return .put
            
        case .RemoveContentFromLibrary, .RemoveContact, .RemoveContactFromVinculat, .DeleteMeeting:
            return .delete
        }
        
    }
    
    var path: String {
        switch self {
        case .Login, .RenewToken:
            return LOGIN_ENDPOINT
        case .Logout:
            return LOGOUT_ENDPOINT
        case .RegisterVinculat:
            return REGISTER_VINCULAT_ENDPOINT
        case .ValidateVinculat:
            return VALIDATE_VINCULAT_ENDPOINT
        case .RecoverPassword:
            return RECOVER_PASSWORD_ENDPOINT
        case .GetSelfUserInfo:
            return USER_SELF_INFO_ENDPOINT
        case .GetContentsLibrary:
            return GET_CONTENTS_LIBRARY_ENDPOINT
        case .GetCirclesUser:
            return GET_CIRCLES_USER_ENDPOINT
        case .UploadContent:
            return UPLOAD_CONTENT
        case .AddContentToLibrary(let params):
            return ADD_CONTENT_TO_LIBRARY_ENDPOINT
        case .RemoveContentFromLibrary(let params):
            return String(format: REMOVE_CONTENT_FROM_LIBRARY_ENDPOINT, params["contentId"] as! Int)
        case .GetGroupsUser:
            return GET_GROUPS_USER_ENDPOINT
        case .GetCirclesUserVinculat:
            return GET_CIRCLES_USER_VINCULAT_ENDPOINT
        case .GenerateCode:
            return GENERATE_CODE_ENDPOINT
        case .AddCode:
            return ADD_CODE_ENDPOINT
        case .RemoveContact(let params):
            return String(format: REMOVE_CONTACT_ENDPOINT, params["contactId"] as! Int)
        case .ChangeUserPhoto:
            return CHANGE_USER_PHOTO
        case .ShareContent:
            return SHARE_CONTENT_USERS
        case .SendInstallation:
            return SEND_INSTALLATION
        case .GetInstallations:
            return GET_INSTALLATIONS
        case .UpdateInstallation:
            return String(format: UPDATE_INSTALLATION, UserDefaults.standard.integer(forKey: "idInst"))
        case .SendUserMessage:
            return SEND_USER_TEXT_MESSAGE
        case .ChatUserGetMessages(let params):
            return String(format: CHAT_USER_GET_ALL_MESSAGES, params["idUser"] as! Int)
        case .SendBadToken:
            return GET_NOTIFICATIONS
        case .GetNotifications:
            return GET_NOTIFICATIONS
        case .GetNotificationById(let params):
            return String(format: GET_NOTIFICATION_ID, params["id_push"] as! Int)
        case .GetMessageById(let params):
            return String(format: CHAT_USER_GET_MESSAGE_ID, params["idMessage"] as! Int)
        case .MarkMessageWatched(let params):
            return String(format: MARK_MESSAGE_WATCHED, params["idMessage"] as! Int)
        case .ChatGroupGetMessages(let params):
            return String(format: GET_GROUP_CHAT_MESSAGES, params["idChat"] as! Int)
        case .SendGroupMessage(let params):
            return String(format: SEND_GROUP_TEXT_MESSAGE, params["idChat"] as! Int)
        case .GetGroupMessageById(let params):
            return String(format: CHAT_GROUP_GET_MESSAGE_ID, params["idChat"] as! Int, params["idMessage"] as! Int)
        case .RemoveContactFromVinculat(let params):
            return String(format: REMOVE_CONTACT_VINCULAT_ENDPOINT, params["idCircle"] as! Int)
        case .GetUserBasicInfo(let params):
            return String(format: GET_USER_BASIC_INFO, params["id"] as! Int)
        case .GetServerTime:
            return GET_SERVER_TIME
        case .GetGroupParticipants(let params):
            return String(format: GET_GROUP_PARTICIPANTS, params["id"] as! Int)
        case .GetMeetings:
            return GET_MEETINGS
        case .CreateMeeting:
            return CREATE_MEETING
        case .UpdateUser:
            return USER_SELF_INFO_ENDPOINT
        case .AcceptMeeting(let params):
            return String(format: ACCEPT_INVITATION_MEETING, params["id"] as! Int)
        case .DeclineMeeting(let params):
            return String(format: DECLINE_INVITATION_MEETING, params["id"] as! Int)
        case .DeleteMeeting(let params):
            return String(format: DELETE_MEETING, params["id"] as! Int)
        case .EditMeeting(let params):
            return String(format: DELETE_MEETING, params["id"] as! Int)
        case .GetMeeting(let params):
            return String(format: DELETE_MEETING, params["id"] as! Int)
        case .GetSpecificContent(let params):
            return String(format: GET_SPECIFIC_CONTENT, params["id"] as! Int)
        case .StartVideoConference:
            return START_VIDEOCONFERENCE
        case .ErrorVideoConference:
            return ERROR_VIDEOCONFERENCE
        case .InviteUserFromGroup(let params):
            return String(format: SEND_INVITATION_FROM_GROUP, params["idGroup"] as! Int, params["idUser"] as! Int)
        case .ChangePassword:
            return USER_CHANGE_PASSWORD
        case .SendMigrationStatus:
            return SEND_MIGRATION_STATUS
        case .GetChatLastAccess(let params):
            return String(format: CHAT_LAST_ACCESS, params["idChat"] as! Int)
        case .PutChatLastAccess(let params):
            return String(format: CHAT_LAST_ACCESS, params["idChat"] as! Int)
        case .GetUserFullInfo(let params):
            return String(format: GET_USER_FULL_INFO, params["id"] as! Int)
        case .PostDataUsage:
            return POST_DATA_USAGE
        }
    }
    
    var params: [String: Any]? {
        switch self {
        case .Login(let params),.RenewToken(let params),.Logout(let params),.RegisterVinculat(let params),.ValidateVinculat(let params),.RecoverPassword(let params),.GetContentsLibrary(let params),.AddCode(let params),.ShareContent(let params),.SendInstallation(let params),.UpdateInstallation(let params),.SendUserMessage(let params),.ChatUserGetMessages(let params),.GetNotifications(let params),.ChatGroupGetMessages(let params),.GetMeetings(let params),.SendGroupMessage(let params),.CreateMeeting(let params),.UpdateUser(let params),.EditMeeting(let params),.StartVideoConference(let params),.ErrorVideoConference(let params),.ChangePassword(let params),.PutChatLastAccess(let params),.AddContentToLibrary(let params),.GetInstallations(let params),.PostDataUsage(let params):
            return params
        default:
            return nil
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: ApiRouter.baseURLString)!
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = 300
        switch self {
        case .RenewToken, .Login, .Logout:
            urlRequest.setValue( "Basic \(BASIC_AUTH_STR)", forHTTPHeaderField: "Authorization")
            
            return try Alamofire.URLEncoding.default.encode(urlRequest, with: params)
        case  .RegisterVinculat, .ValidateVinculat, .RecoverPassword:
            urlRequest.setValue( "Basic \(BASIC_AUTH_STR)", forHTTPHeaderField: "Authorization")
            return try Alamofire.JSONEncoding.default.encode(urlRequest, with: params)
        case .GetSelfUserInfo, .GetCirclesUser, .UploadContent, .AddContentToLibrary, .RemoveContentFromLibrary, .GetGroupsUser, .GetCirclesUserVinculat, .GenerateCode, .AddCode, .RemoveContact, .ChangeUserPhoto, .ShareContent, .SendInstallation, .UpdateInstallation, .SendUserMessage, .GetNotificationById, .GetMessageById, .MarkMessageWatched, .SendGroupMessage, .GetGroupMessageById, .RemoveContactFromVinculat, .GetUserBasicInfo, .GetServerTime, .GetGroupParticipants, .CreateMeeting, .UpdateUser, .AcceptMeeting, .DeclineMeeting, .DeleteMeeting, .EditMeeting, .GetMeeting, .GetSpecificContent, .StartVideoConference, .ErrorVideoConference, .InviteUserFromGroup, .ChangePassword, .SendMigrationStatus, .GetChatLastAccess, .PutChatLastAccess, .GetUserFullInfo, .PostDataUsage:
            
            
            let authModelManager = AuthModelManager()
            
            if let accessToken = authModelManager.getAccessToken(){
                urlRequest.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
            return try Alamofire.JSONEncoding.default.encode(urlRequest, with: params)
        case .GetContentsLibrary, .ChatUserGetMessages, .GetNotifications, .ChatGroupGetMessages, .GetMeetings, .GetInstallations:
            
            let authModelManager = AuthModelManager()
            
            if let accessToken = authModelManager.getAccessToken(){
                
                
                urlRequest.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
                
            }
            
            return try Alamofire.URLEncoding.default.encode(urlRequest, with: params)
        case .SendBadToken:
            
            let authModelManager = AuthModelManager()
            
            if let accessToken = authModelManager.getAccessToken(){
                urlRequest.setValue( "Bearer BADACCESSTOKEN", forHTTPHeaderField: "Authorization")
            }
            
            return try Alamofire.URLEncoding.default.encode(urlRequest, with: params)
        }
        
        
    }
    
}



