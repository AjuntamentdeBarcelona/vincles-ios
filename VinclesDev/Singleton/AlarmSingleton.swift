//
//  AlarmSingleton.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import RealmSwift
class AlarmSingleton: NSObject, PopUpDelegate {
    
    
    static let sharedInstance = AlarmSingleton()
    
    var alarmMeeting: Meeting?
    var timer: Timer?
    var popupVC: PopupViewController!
    let realm = try! Realm()

    func stop(){
        timer?.invalidate()
    }
    
    func setupAlarm(){

        timer?.invalidate()
        
        let agendaModelManager = AgendaModelManager()
        if let meeting = agendaModelManager.nextMeetingForAlarm(){
            alarmMeeting = meeting
            
            
            let time = meeting.date / 1000
            let current = Int64(Date().timeIntervalSince1970)
            
            let alarmTime = time - 3600
    
            print(alarmTime - current)
            timer = Timer.scheduledTimer(timeInterval: (TimeInterval(alarmTime - current)), target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: false)
            
         
            
        }
    }
    
    @objc func runTimedCode(){
        print("alarm")
        timer?.invalidate()
        let profileModelManager = ProfileModelManager()
        
        if let meeting = alarmMeeting{
            print(meeting.id)
            let lang = UserDefaults.standard.string(forKey: "i18n_language")
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateStyle = .long
            dateFormatterGet.timeStyle = .short
            dateFormatterGet.locale = Locale(identifier: lang!)
            
            let initDate = Date(timeIntervalSince1970: TimeInterval(meeting.date / 1000))
            
            
            popupVC = StoryboardScene.Popup.popupViewController.instantiate()
            popupVC.delegate = self
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.popupTitle = L10n.citaRecordatori
            
            var stringDur = ""
            
            switch meeting.duration{
            case 30:
                stringDur = L10n.duracionMediaHora
            case 60:
                stringDur = L10n.duracionUnaHora
            case 90:
                stringDur = L10n.duracionHoraMedia
            case 120:
                stringDur = L10n.duracionDosHoras
            default:
                break
            }
            var stringDesc = "\(meeting.descrip)\n\(dateFormatterGet.string(from: initDate))\n\(L10n.citaPopUpDurada): \(stringDur)"
            
            if meeting.guests.count > 0{
                var noms = [String]()
                for part in meeting.guests{
                    if let name = part.userInfo?.name, let surname = part.userInfo?.lastname{
                        if part.userInfo?.id == profileModelManager.getUserMe()?.id{
                            noms.append(L10n.chatTu)
                            
                        }
                        else{
                            noms.append("\(name) \(surname)")
                        }
                        
                    }
                }
                
                stringDesc = "\(meeting.descrip)\n\(dateFormatterGet.string(from: initDate))\n\(L10n.citaPopUpDurada): \(meeting.duration) \(L10n.citaPopUpMinutos)\n\(L10n.citaParticipants)\(noms.joined(separator: ", "))"
                
                
            }
            popupVC.popupDescription = stringDesc
            
            popupVC.button1Title = L10n.ok
            
            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
            alertWindow.rootViewController = UIViewController()
            alertWindow.windowLevel = UIWindowLevelAlert + 1;
            alertWindow.makeKeyAndVisible()
            
            alertWindow.rootViewController?.present(popupVC, animated: true, completion: nil)
            
            
            let notificationsModelManager = NotificationsModelManager()
            notificationsModelManager.removeFakeNotificationForMeeting(meeting: meeting)
            let value = notificationsModelManager.getNextFakeNotificationId
            
            let notification = VincleNotification()
            notification.type = NOTI_FAKE_REMINDER_EVENT
            notification.id = Int(value)
            notification.idMeeting = meeting.id
            notification.creationTimeInt = Int64(Date().timeIntervalSince1970) * 1000
            notification.processed = true
            try! realm.write {
                realm.add(notification, update: true)
            }
            
            let notDict:[String: Any] = ["idMeeting": notification.idMeeting, "type": NOTI_FAKE_REMINDER_EVENT]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
        }
        
        
        
    }
    
    func firstButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
            self.alarmMeeting = nil
        }
        
    }
    
    func secondButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
            self.alarmMeeting = nil
            
        }
        
    }
    
    
}
