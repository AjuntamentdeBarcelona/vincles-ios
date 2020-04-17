//
//  NotificationsDataSource.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

protocol NotificationsDataSourceDelegate{
    func reloadTableData()
    func actionButtonPressed(notification: VincleNotification)

}


class NotificationsDataSource: NSObject , UITableViewDelegate, UITableViewDataSource {
    var delegate: NotificationsDataSourceDelegate?

    var items = [VincleNotification]()
    
    let notificationsModelManager = NotificationsModelManager()
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationsTableViewCell
        let notification = items[indexPath.row]
        cell.configWithNotification(notification: notification)
        cell.eliminarButton.addTargetClosure { (sender) in
            self.notificationsModelManager.markNotificationRemoved(notification: notification)
            self.delegate?.reloadTableData()
        }
        cell.actionButton.addTargetClosure { (sender) in
            self.delegate?.actionButtonPressed(notification: notification)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? NotificationsTableViewCell{
            cell.setAvatar()
        }
    }
}
