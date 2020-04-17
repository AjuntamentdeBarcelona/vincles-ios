//
//  AgendaManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import Foundation
import SwiftyJSON
import EventKit
import CoreData
import UserNotifications
import SlideMenuControllerSwift

class AgendaManager {
    lazy var agendaModelManager = AgendaModelManager()
   
  
    func getMeetings(startDate: Date, onSuccess: @escaping (Bool) -> (), onError: @escaping (String) -> ()) {
        
        let date = agendaModelManager.oldestMeetingDate
      
            ApiClient.getMeetings(to: date, onSuccess: { (array) in
                
                
                if array.count > 0{
                    self.agendaModelManager.addMeetings(array: array)
                }
                
                if array.count == 10{
                    let date = self.agendaModelManager.oldestMeetingDate
                    let initDate = Date(timeIntervalSince1970: TimeInterval(date! / 1000))
                    if initDate > startDate {
                        onSuccess(true)

                    }
                    else{
                        onSuccess(false)
                    }
                }
                else{
                    onSuccess(false)
                }
                
            }) { (error) in
                onError(error )
            }
        
    
        
    }
    
    
    
    func createMeeting(date: Int64, duration: Int, description: String, inviteTo: [Int], onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        
        let params = ["date": date, "duration": duration, "description": description, "inviteTo": inviteTo] as [String : Any]
        
        ApiClient.createMeeting(params: params, onSuccess: { dict in
            if let id = dict["id"] as? Int{

                ApiClient.getMeeting(id: id, onSuccess: { (dict) in
                    self.agendaModelManager.addMeeting(dict: dict)

                    onSuccess()
                }, onError: { (error, status) in
                    onError(error )
                })
                
            }

        }) { (error) in
            onError(error )

        }
        
    }
    
    func editMeeting(meetingId: Int, date: Int64, duration: Int, description: String, inviteTo: [Int], onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        
        let params = ["date": date, "duration": duration, "description": description, "inviteTo": inviteTo, "id": meetingId] as [String : Any]
        
        ApiClient.editMeeting(params: params, onSuccess: { (dict) in
            if let id = dict["id"] as? Int{
                
                ApiClient.getMeeting(id: meetingId, onSuccess: { (dict) in
                    self.agendaModelManager.addMeeting(dict: dict)
                    
                    onSuccess()
                }, onError: { (error, status) in
                    onError(error )
                })
                
            }
        }) { (error) in
            onError(error )
            
        }
        
    }
    
    
    func acceptInvitation(meetingId: Int, onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        
        ApiClient.acceptEventInvitation(meetingId: meetingId, onSuccess: { (result) in
            
            if let id = result["id"] as? Int{
                
                ApiClient.getMeeting(id: meetingId, onSuccess: { (dict) in
                    self.agendaModelManager.addMeeting(dict: dict)
                    
                    onSuccess()
                }, onError: { (error, status) in
                    onError(error )
                })
                
            }
        }) { (error) in
            onError(error )
        }
        
    }
    
    
    func getMeeting(meetingId: Int, onSuccess: @escaping () -> (), onError: @escaping (String, Int) -> ()) {
        
        ApiClient.getMeeting(id: meetingId, onSuccess: { (dict) in
            self.agendaModelManager.addMeeting(dict: dict)
            
            onSuccess()
        }, onError: { (error, status) in
            onError(error, status)
        })
        
    }

    func deleteMeeting(meetingId: Int, onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        
        ApiClient.deleteMeeting(meetingId: meetingId, onSuccess: { (result) in
            
            if let id = result["id"] as? Int{
                self.agendaModelManager.deleteMeeting(id: meetingId)
            }
            
            onSuccess()
        }) { (error) in
            onError(error )
        }
        
    }
    
    func declineInvitation(meetingId: Int, onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        
        ApiClient.declineEventInvitation(meetingId: meetingId, onSuccess: { (result) in
            if let id = result["id"] as? Int{
                
                self.agendaModelManager.deleteMeeting(id: meetingId)

                /*
                ApiClient.getMeeting(id: meetingId, onSuccess: { (dict) in
                    self.agendaModelManager.addMeeting(dict: dict)
                    
                    onSuccess()
                }, onError: { (error) in
                    onError(error )
                })
                */
            }
            onSuccess()

        }) { (error) in
            onError(error )
        }
        
    }
}
