//
//  ApiClient.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit


protocol ApiClientProtocol {
    
    typealias AuthResponseCallback = (AuthResponse?) -> Void
    typealias ErrorCallback = (String) -> Void
    typealias DictResponseCallback = ([String:Any]) -> Void
    typealias ArrayResponseCallback = ([[String:Any]]) -> Void
    typealias VoidCallback = () -> ()
    typealias DataResponseCallback = (Data) -> Void
    typealias MessageTypeResponseCallback = (Data, MessageType) -> Void
    typealias ErrorCallbackExtended = (String, Int) -> Void

    static func loginWith(username: String, password: String, onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback)
    static func recoverPassword(username: String, onSuccess:  @escaping VoidCallback, onError:  @escaping ErrorCallback)
    static func registerVinculat(email: String, password: String, name: String, lastname: String, birthdate: Int, phone: String, gender: String, liveInBarcelona: Bool, photoMimeType: String?, onSuccess: @escaping DictResponseCallback, onError: @escaping ErrorCallback)
    static func validateRegister(username: String, code: String, onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback)
    static func logoutWith(token: String, onSuccess:  @escaping VoidCallback, onError:  @escaping ErrorCallback)
    static func getUserSelfInfo(onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback)
    static func getCirclesUser(onSuccess:  @escaping ArrayResponseCallback, onError:  @escaping ErrorCallback)
     static func addContentToLibrary(contentId: Int, onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback)
    static func removeContentFromLibrary(contentId: Int, onSuccess:  @escaping VoidCallback, onError:  @escaping ErrorCallback)
    static func getGroupsUser(onSuccess:  @escaping ArrayResponseCallback, onError:  @escaping ErrorCallback)
    static func generateCode(onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback)
    static func addCode(code: String, relationShip: String, onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback)
    static func removeContact(contactId: Int, onSuccess:  @escaping VoidCallback, onError:  @escaping ErrorCallback)
    static func changeUserPhoto(imageData: Data, onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback)
    static func getUserSelfInfoNoValidation(onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback)
    static func shareContent(contentId: [Int], usersIds: [Int], chatIds: [Int], metadataTipus: [String],   onSuccess:  @escaping VoidCallback, onError:  @escaping ErrorCallback)
}


