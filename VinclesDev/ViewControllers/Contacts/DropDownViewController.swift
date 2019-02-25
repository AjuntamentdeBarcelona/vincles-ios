//
//  DropDownViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import ContextMenu

class DropDownViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var sender:AddContactViewController!
    var relations:[String] = []
//    let relationshipKeys = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.contactsAfegirRelacionOptionTitle
        preferredContentSize = CGSize(width: 200, height: 200)

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if UserDefaults.standard.string(forKey: "i18n_language") == "ca" {
            self.relations = ["Parella", " Fill/a", " Nét/a", " Amic/ga", " Voluntari/a", " Cuidador/a", " Germà/na", " Nebot/da", " Altres"]
        }else{
            self.relations = ["Pareja", "Hijo/a", "Nieto/a", "Amigo/a", "Voluntario/a", "Cuidador/a", "Hermano/a", "Sobrino/a", "Otros"]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.flashScrollIndicators()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.relations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "DropDownTableViewCell") as! DropDownTableViewCell
        cell.label.text = self.relations[indexPath.row]
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.sender.selectKinkshipButton.setTitle(self.relations[indexPath.row], for: .normal)
        self.sender.selectedIndex = indexPath.row
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

}
