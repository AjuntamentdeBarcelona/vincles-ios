//
//  AgendaModelManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import RealmSwift
import SwiftyJSON

class AgendaModelManager: NSObject {
    var newestMeetingDate: Int64?{
        
        let realm = try! Realm()
        
        guard let user = realm.objects(User.self).first else{
            return nil
        }
        return user.meetings.sorted(by: { $0.date > $1.date }).first?.date
 
    }
    
    var oldestMeetingDate: Int64?{
        let realm = try! Realm()
        
        guard let user = realm.objects(User.self).first else{
            return nil
        }
        return user.meetings.sorted(by: { $0.date < $1.date }).first?.date
    }
    
    var numberOfMeetings: Int{
        let realm = try! Realm()
        guard let user = realm.objects(User.self).first else{
            return 0
        }
        return user.meetings.count
    }
    
    func numberOfMeetingsOn(date: Date) -> Int{
        
        let calendar = Calendar.current
        
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)

        let realm = try! Realm()
        guard let user = realm.objects(User.self).first else{
            return 0
        }
        return user.meetings.filter("day == %i && month == %i && year == %i", day, month, year).count
        
    }
    
    func meetingOnDateAt(date: Date, index: Int) -> Meeting?{
        let calendar = Calendar.current
        
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        let realm = try! Realm()

        guard let user = realm.objects(User.self).first else{
            return nil
        }
        return user.meetings.filter("day == %i && month == %i && year == %i", day, month, year).sorted(by: { $0.date < $1.date })[index]
        
    }
    
    func nextMeetingForAlarm() -> Meeting?{
        let realm = try! Realm()
        if let user = realm.objects(User.self).first{
            let calendar = Calendar.current
            let date = calendar.date(byAdding: .minute, value: 60, to: Date())
            if let dateNew = date?.timeIntervalSince1970{
                return user.meetings.filter("date > %@", Int64(dateNew * 1000)).sorted(by: { $0.date < $1.date }).first
            }
        }
      
        return nil

    }
    
    var numberOfUnansweredMeetings: Int{
        let realm = try! Realm()
        guard let user = realm.objects(User.self).first else{
            return 0
        }
        let meetings = user.meetings
        
        var count = 0

        for meeting in meetings{
            if let myState = meeting.guests.filter("userInfo.id == %i", user.id ).first?.state{
                if myState == "PENDING"{
                    if meeting.date / 1000 >= Int64(Date().timeIntervalSince1970){
                    
                        count += 1
                    }
                }
            }
            
        }
        
        return count
    }
    
    func numberOfGuests(meeting: Meeting) -> Int{

        return meeting.guests.count
        
    }
    
    
    func guestAtIndex(meeting: Meeting, index: Int) -> MeetingGuest{
        return meeting.guests[index]
        
    }
    
    
    var meetings: List<Meeting>?{
        let realm = try! Realm()
        guard let user = realm.objects(User.self).first else{
            return nil
        }
        return user.meetings
    }
    
  
    func meetingWithId(id: Int) -> Meeting?{
        let realm = try! Realm()
        
        if (realm.objects(Meeting.self).filter("id == %i", id).count) > 0{
            return realm.objects(Meeting.self).filter("id == %i", id).first
        }
        
        return nil
    }
    

    func userMeetingWithId(id: Int) -> Meeting?{
        let realm = try! Realm()
        
        guard let auth = realm.objects(AuthResponse.self).first else{
            return nil
        }
        
        if let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            return user.meetings.filter("id == %i", id).first

        }
        
       
        return nil
    }
    
    
    func addMeeting(dict: [String:Any]){
        
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            
                let meeting = Meeting(json: JSON(dict))
                EventsLoader.addEventToCalendar(meeting: meeting)
                try! realm.write {
                    realm.add(meeting, update: true)
                    if user.meetings.index(of: meeting) == nil{
                        user.meetings.append(meeting)
                    }
                }
                AlarmSingleton.sharedInstance.setupAlarm()

        }
    }
    
    
    func deleteMeeting(id: Int) -> Bool{
        
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            
            if let meeting = user.meetings.filter("id == %i",id).first{
                EventsLoader.removeEventFromCalendar(meeting: meeting)

                try! realm.write {
                    user.meetings.remove(at: user.meetings.index(of: meeting)!)
                  //  realm.delete(meeting)
                    
                }
                AlarmSingleton.sharedInstance.setupAlarm()
                return true

            }
            
           
        }
        return false
    }
    
    
    func addMeetings(array: [[String:Any]]){
        
        let realm = try! Realm()

        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            for dict in array{
                
                let meeting = Meeting(json: JSON(dict))
                EventsLoader.addEventToCalendar(meeting: meeting)

                try! realm.write {
                    realm.add(meeting, update: true)
                    if user.meetings.index(of: meeting) == nil{
                        user.meetings.append(meeting)
                    }
                }
                AlarmSingleton.sharedInstance.setupAlarm()

            }
            
        } 
    }
    
}
