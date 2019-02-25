//
//  ErrorEnums.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import Foundation

enum APICodeError: Int{
    case NoAccess = 1001
    
    func getStringForErrorCode() -> String {
        switch self {
        case .NoAccess:
            return NSLocalizedString("Error\(1001)", comment: "Error")
       
            
        }
    }
    
}
enum LoginError: Int {
    case DataError = 400
    case ServerError = 500
    case GenericError = 0

    func getStringForErrorCode() -> String {
        switch self {
        case .DataError:
            return L10n.loginErrorData
        case .ServerError:
            return L10n.loginErrorData
        default:
            return L10n.loginErrorServer
        }
    }
}

enum ForgotPasswordError: Int {
    case ServerError = 500
    case GenericError = 0

    func getStringForErrorCode() -> String {
        switch self {
        case .ServerError:
            return L10n.forgotAlertError
        default:
            return L10n.errorGenerico
        }
    }
    
    
}

enum RegisterError: Int {
    case EmailUsedError = 409
    case ServerError = 500
    case GenericError = 0
   
    func getStringForErrorCode() -> String {
        switch self {
        case .EmailUsedError:
            return L10n.registerErrorData
        case .ServerError:
            return L10n.registerErrorServer
        case .GenericError:
            return L10n.errorGenerico
        }
    }
}

enum ValidateError: Int {
    case InvalidCodeError = 409
    case ServerError = 500
    case GenericError = 0
    
    func getStringForErrorCode() -> String {
        switch self {
        case .InvalidCodeError:
            return L10n.validacionErrorIncorrect
        case .ServerError:
            return L10n.errorGenerico
        case .GenericError:
            return L10n.errorGenerico
        }
    }
}

enum LogoutError: Int {
    case ServerError = 500
    case GenericError = 0
    
    func getStringForErrorCode() -> String {
        switch self {
        case .ServerError:
            return L10n.errorGenerico
        default:
            return L10n.errorGenerico
        }
    }
    
    
}

