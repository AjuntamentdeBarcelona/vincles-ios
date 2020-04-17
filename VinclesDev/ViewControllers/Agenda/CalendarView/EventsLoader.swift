/*
 * EventsLoader.swift
 * Created by Michael Michailidis on 26/10/2017.
 * http://blog.karmadust.com/
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import Foundation
import EventKit
import RealmSwift

open class EventsLoader {
    
    private static let eventStore = EKEventStore()
    
    var yourReminderCalendar: EKCalendar?
    
    static func createCalendarIfNeeded(completion: @escaping (_ result: Bool)->()) {
        self.eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if error != nil{
                completion(false)
            }
            if (granted) && (error == nil) {
                
                DispatchQueue.main.async {
                    let calendars = self.eventStore.calendars(for: EKEntityType.event)
                    for calendar in calendars {
                        if let calInd = UserDefaults.standard.value(forKey: "calIdentifier") as? String{
                            if calendar.calendarIdentifier ==  calInd{
                                completion(true)
                                return
                            }
                        }
                        
                    }
                    
                    let newCalendar = EKCalendar(for: EKEntityType.event, eventStore: self.eventStore)
                    newCalendar.title = "Vincles BCN"
                    
                    newCalendar.source = self.eventStore.defaultCalendarForNewEvents?.source
                    
                    do {
                        try self.eventStore.saveCalendar(newCalendar, commit: true)
                        UserDefaults.standard.set(newCalendar.calendarIdentifier, forKey: "calIdentifier")
                        completion(true)

                    }
                    catch{
                        completion(false)
                        print("error")
                    }
                }
                
                
            }
        })
        
        
        
        
    }
    
    
    static func syncAllMeetings(completion: @escaping ((_ success: Bool) -> Void)) {
        createCalendarIfNeeded { (success) in
            if success{
                self.eventStore.requestAccess(to: .event, completion: { (granted, error) in
                    if error != nil{
                        completion(false)
                    }
                    if (granted) && (error == nil) {
                        
                        DispatchQueue.main.async {
                            let realm = try! Realm()
                            
                            if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
                                
                                
                                for meeting in  user.meetings{
                                    self.addEventToCalendar(meeting: meeting)
                                }
                            }
                            
                            completion(true)

                        }
                        
                        
                    }
                    
                })
            }
            else{
                completion(false)
            }
        }
        
        
       
    }
    
    static func addEventToCalendar(meeting: Meeting, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        if UserDefaults.standard.bool(forKey: "sincroCalendari"){
            
            createCalendarIfNeeded { (success) in
                var calendariId = ""
                
                let calendars = self.eventStore.calendars(for: EKEntityType.event)
                for calendar in calendars {
                    if let calInd = UserDefaults.standard.value(forKey: "calIdentifier") as? String{
                        if calendar.calendarIdentifier ==  calInd{
                            calendariId = calInd
                        }
                    }
                }
                
                
                self.eventStore.requestAccess(to: .event, completion: { (granted, error) in
                    if (granted) && (error == nil) {
                        
                        DispatchQueue.main.async {
                            if let identifier = UserDefaults.standard.value(forKey: "\(meeting.id)") as? String{
                                
                                if let event = self.eventStore.event(withIdentifier: identifier){
                                    event.title = meeting.descrip
                                    let startDate = Date(timeIntervalSince1970: TimeInterval(meeting.date / 1000))
                                    event.startDate = startDate
                                    event.endDate = Calendar.current.date(byAdding: .minute, value: meeting.duration, to: startDate)
                                    event.notes = ""
                                    if let calendar = eventStore.calendar(withIdentifier: calendariId){
                                        event.calendar = calendar
                                    }
                                    
                                    do {
                                        try eventStore.save(event, span: .thisEvent)
                                        
                                    } catch let e as NSError {
                                        completion?(false, e)
                                        return
                                    }
                                }
                                completion?(true, nil)
                                
                                
                                
                            }
                            else{
                                let event = EKEvent(eventStore: self.eventStore)
                                event.title = meeting.descrip
                                let startDate = Date(timeIntervalSince1970: TimeInterval(meeting.date / 1000))
                                event.startDate = startDate
                                event.endDate = Calendar.current.date(byAdding: .minute, value: meeting.duration, to: startDate)
                                event.notes = ""
                                if let calendar = eventStore.calendar(withIdentifier: calendariId){
                                    event.calendar = calendar
                                }
                                do {
                                    try eventStore.save(event, span: .thisEvent)
                                    
                                    UserDefaults.standard.set(event.eventIdentifier, forKey: "\(meeting.id)")
                                    
                                    
                                } catch let e as NSError {
                                    completion?(false, e)
                                    return
                                }
                                completion?(true, nil)
                                
                            }
                        }
                        
                        
                        
                    } else {
                        completion?(false, error as NSError?)
                    }
                })
                
            }
            
           
            
        }
    }
    
    
    static func removeEventFromCalendar(meeting: Meeting, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        
        self.eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                
                DispatchQueue.main.async {
                    if let identifier = UserDefaults.standard.value(forKey: "\(meeting.id)") as? String{
                        
                        UserDefaults.standard.set(nil, forKey: "\(meeting.id)")
                        if let event = self.eventStore.event(withIdentifier: identifier){
                            
                            
                            do {
                                try self.eventStore.remove(event, span: .thisEvent)
                                
                            } catch let e as NSError {
                                completion?(false, e)
                                return
                            }
                        }
                        completion?(true, nil)
                    }
                    
                }
            } else {
                completion?(false, error as NSError?)
            }
        })
        
    }
    
    static func removeAllEvents(completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        
        
        
        self.eventStore .requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                
                let startDate = Date.distantPast
                let endDate = Date.distantFuture
                
                DispatchQueue.main.async {
                    let calendars = self.eventStore.calendars(for: EKEntityType.event)
                    for calendar in calendars {
                        if let calInd = UserDefaults.standard.value(forKey: "calIdentifier") as? String{
                            if calendar.calendarIdentifier ==  calInd{
                                
                                let oneMonthAgo = NSDate(timeIntervalSinceNow: -1000*30*24*3600)
                                let oneMonthAfter = NSDate(timeIntervalSinceNow: +30*1000*24*3600)
                                
                                let predicate = eventStore.predicateForEvents(withStart: oneMonthAgo as Date, end: oneMonthAfter as Date, calendars: [calendar])
                                
                                let eV = eventStore.events(matching: predicate) as [EKEvent]?
                                
                                if eV != nil {
                                    for i in eV! {
                                        
                                        do{
                                            (try eventStore.remove(i, span: EKSpan.thisEvent, commit: true))
                                        }
                                        catch let error {
                                            print("Error removing events: ", error)
                                        }
                                        
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    
                }
                
                
                
                
                DispatchQueue.main.async {
                    let realm = try! Realm()
                    let meetings = realm.objects(Meeting.self)
                    
                    for meeting in meetings{
                        self.removeEventFromCalendar(meeting: meeting)
                    }
                }
                
                
            }
        })
        
        
    }
    
    static func removeCalendar(completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        
        
        self.eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                
                DispatchQueue.main.async {
                    let calendars = self.eventStore.calendars(for: EKEntityType.event)
                    
                    for calendar in calendars {
                        if calendar.title ==  "Vincles BCN"{
                            do {
                                try self.eventStore.removeCalendar(calendar, commit: true)
                            }
                            catch{
                                print("error")
                            }
                            return
                        }
                    }
                    
                    let calendars2 = self.eventStore.calendars(for: EKEntityType.event)

                    
                    for calendar in calendars2 {
                        if let calInd = UserDefaults.standard.value(forKey: "calIdentifier") as? String{
                            if calendar.calendarIdentifier ==  calInd{
                                do {
                                    try self.eventStore.removeCalendar(calendar, commit: true)
                                }
                                catch{
                                    print("error")
                                }
                                return
                            }
                        }
                        
                    }
                    
                    UserDefaults.standard.set(nil, forKey: "calIdentifier")

                    
                }
                
                
            }
        })
        
        
    }
    
    
    
    static func load(from fromDate: Date, to toDate: Date, complete onComplete: @escaping ([CalendarEvent]?) -> Void) {
        
        let q = DispatchQueue.main
        guard EKEventStore.authorizationStatus(for: .event) == .authorized else {
            
            return self.eventStore.requestAccess(to: EKEntityType.event, completion: {(granted, error) -> Void in
                guard granted else {
                    return q.async { onComplete(nil) }
                }
                EventsLoader.fetch(from: fromDate, to: toDate) { events in
                    q.async { onComplete(events) }
                }
            })
        }
        
        EventsLoader.fetch(from: fromDate, to: toDate) { events in
            q.async { onComplete(events) }
        }
    }
    
    private static func fetch(from fromDate: Date, to toDate: Date, complete onComplete: @escaping ([CalendarEvent]) -> Void) {
        
        let predicate = self.eventStore.predicateForEvents(withStart: fromDate, end: toDate, calendars: nil)
        
        let secondsFromGMTDifference = TimeInterval(TimeZone.current.secondsFromGMT())
        
        let events = self.eventStore.events(matching: predicate).map {
            return CalendarEvent(
                title:      $0.title,
                startDate:  $0.startDate.addingTimeInterval(secondsFromGMTDifference),
                endDate:    $0.endDate.addingTimeInterval(secondsFromGMTDifference)
            )
        }
        
        onComplete(events)
    }
}
