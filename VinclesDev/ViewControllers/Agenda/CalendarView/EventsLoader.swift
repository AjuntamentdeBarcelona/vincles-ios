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
    
    static func createCalendarIfNeeded() {
        self.eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                
                DispatchQueue.main.async {
                    let calendars = self.eventStore.calendars(for: EKEntityType.event)
                    for calendar in calendars {
                        if let calInd = UserDefaults.standard.value(forKey: "calIdentifier") as? String{
                            if calendar.calendarIdentifier ==  calInd{
                                print(calendar.title)
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
                    }
                    catch{
                        print("error")
                    }
                }
                
                
            }
        })
        
        
      
        
    }
    
    
    static func syncAllMeetings(completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        createCalendarIfNeeded()
        
        
        self.eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                
                DispatchQueue.main.async {
                    let realm = try! Realm()
                    let meetings = realm.objects(Meeting.self)
                    
                    for meeting in meetings{
                        self.addEventToCalendar(meeting: meeting)
                    }
                }
                
                
            }
        })
    }
    
    static func addEventToCalendar(meeting: Meeting, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        if UserDefaults.standard.bool(forKey: "sincroCalendari"){

        createCalendarIfNeeded()
        
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
                                print(event.eventIdentifier)
                                
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
                            print(event.eventIdentifier)
                            
                            UserDefaults.standard.set(event.eventIdentifier, forKey: "\(meeting.id)")
                            
                            print(event.eventIdentifier)
                            
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
    
    
    static func removeEventFromCalendar(meeting: Meeting, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {

        self.eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                
                DispatchQueue.main.async {
                    if let identifier = UserDefaults.standard.value(forKey: "\(meeting.id)") as? String{
                        
                        UserDefaults.standard.set(nil, forKey: "\(meeting.id)")
                        if let event = self.eventStore.event(withIdentifier: identifier){
                  
                            
                            do {
                                try self.eventStore.remove(event, span: .thisEvent)
                                print(event.eventIdentifier)
                                
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
                        if let calInd = UserDefaults.standard.value(forKey: "calIdentifier") as? String{
                            if calendar.calendarIdentifier ==  calInd{
                                do {
                                    try self.eventStore.removeCalendar(calendar, commit: true)
                                    UserDefaults.standard.set(nil, forKey: "calIdentifier")
                                }
                                catch{
                                    print("error")
                                }
                                return
                            }
                        }
                        
                    }
                    
                   
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
