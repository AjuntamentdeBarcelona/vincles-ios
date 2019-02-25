//
//  ChatDayTableViewCell.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class ChatDayTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        contView.layer.borderColor = UIColor(named: .darkRed).cgColor
        contView.layer.borderWidth = 1.0
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configWithDate(date: Date){
        if date.isInToday{
            dateLabel.text = L10n.chatHoy
        }
        else{
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateStyle = .medium
            dateFormatterGet.timeStyle = .none
            dateFormatterGet.locale = Locale.current
            
            let lang = UserDefaults.standard.string(forKey: "i18n_language")
            if(lang == "es"){
                dateFormatterGet.locale = Locale(identifier: "es")
            }
            else{
                dateFormatterGet.locale = Locale(identifier: "ca")
            }
            
            dateLabel.text = dateFormatterGet.string(from: date)

        }
    }
}
