//
//  MeetingsDataSource.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

protocol MeetingsDataSourceClickDelegate{
    func selectedMeeting(meeting: Meeting)
    func editMeeting(meeting: Meeting)
    func deleteMeeting(meeting: Meeting)
    func acceptMeeting(meeting: Meeting)
    func declineMeeting(meeting: Meeting)

}


class MeetingsDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    var selectedDate: Date?
    lazy var agendaModelManager = AgendaModelManager()
    var clickDelegate: MeetingsDataSourceClickDelegate?

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meetingCell", for: indexPath) as! AgendaMeetingTableViewCell
        cell.delegate = self
        if let selectedDate = selectedDate{
            cell.configWithMeeting(meeting: agendaModelManager.meetingOnDateAt(date: selectedDate, index: indexPath.row))
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let selectedDate = selectedDate{
            return agendaModelManager.numberOfMeetingsOn(date: selectedDate)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let selectedDate = selectedDate{
            clickDelegate?.selectedMeeting(meeting: agendaModelManager.meetingOnDateAt(date: selectedDate, index: indexPath.row))

        }
        
    }
}

extension MeetingsDataSource: AgendaMeetingTableViewCellDelegate{
    func acceptClicked(meeting: Meeting) {
        clickDelegate?.acceptMeeting(meeting: meeting)

    }
    
    func declineClicked(meeting: Meeting) {
        clickDelegate?.declineMeeting(meeting: meeting)

    }
    
    func deleteClicked(meeting: Meeting) {
        clickDelegate?.deleteMeeting(meeting: meeting)

        
    }
    
    func editClicked(meeting: Meeting) {
        clickDelegate?.editMeeting(meeting: meeting)
    }
    
    
}
