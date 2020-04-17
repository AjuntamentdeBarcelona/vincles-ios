//
//  AgendaMeetingTableViewCell.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

protocol AgendaMeetingTableViewCellDelegate{
    func editClicked(meeting: Meeting)
    func deleteClicked(meeting: Meeting)
    func acceptClicked(meeting: Meeting)
    func declineClicked(meeting: Meeting)

}


class AgendaMeetingTableViewCell: UITableViewCell {
    @IBOutlet weak var creadorLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var partLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var topClock: NSLayoutConstraint!
    @IBOutlet weak var leftClock: NSLayoutConstraint!
    @IBOutlet weak var widthClock: NSLayoutConstraint!
    @IBOutlet weak var distanceClockLabel: NSLayoutConstraint!
    @IBOutlet weak var meetingBack: UIImageView!

    @IBOutlet weak var leftDistance: NSLayoutConstraint!
    @IBOutlet weak var bottomDistance: NSLayoutConstraint!
    @IBOutlet weak var distanceLineInfo: NSLayoutConstraint!
    @IBOutlet weak var distanceHourLine: NSLayoutConstraint!
    @IBOutlet weak var widthLabelHour: NSLayoutConstraint!

    @IBOutlet weak var firstButton: HoverButton!
    @IBOutlet weak var secondButton: HoverButton!
    
    var delegate: AgendaMeetingTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            topClock.constant = 20
            leftClock.constant = 10
            widthClock.constant = 15
            distanceClockLabel.constant = 8
            hourLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 13.0)
            distanceHourLine.constant = 0
            distanceLineInfo.constant = 13
            bottomDistance.constant = 20
            leftDistance.constant = 10
            firstButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 15.0)
            secondButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 15.0)
            widthLabelHour.constant = 40

        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configWithMeeting(meeting: Meeting){
        meetingBack.isHidden = true
        let profileModelManager = ProfileModelManager()
        
        if let name = meeting.hostInfo?.name{
            
            if meeting.hostInfo?.id == profileModelManager.getUserMe()?.id{
                creadorLabel.text = L10n.citaCreadaPer + L10n.citaCreadaTi
                
            }
            else{
                creadorLabel.text = L10n.citaCreadaPer + name
            }
        }
        descLabel.text = meeting.descrip
        
        
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
        
        partLabel.text = L10n.citaParticipants + noms.joined(separator: ", ")
        if noms.count == 0{
            partLabel.isHidden = true
        }
        else{
            partLabel.isHidden = false
        }
        let lang = UserDefaults.standard.string(forKey: "i18n_language")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: lang!)
        
        let initDate = Date(timeIntervalSince1970: TimeInterval(meeting.date / 1000))
        
        let calendar = Calendar.current
        if let endDate = calendar.date(byAdding: .minute, value: meeting.duration, to: initDate){
            hourLabel.text = dateFormatter.string(from: initDate) + "\n" + dateFormatter.string(from: endDate)
            
        }
        
        let agendaManager = AgendaManager()
        
        if meeting.hostInfo?.id == profileModelManager.getUserMe()?.id{
            // MINE
            firstButton.isHidden = false
            secondButton.isHidden = false
            firstButton.setTitle(L10n.citaCancela, for: .normal)
            secondButton.setTitle(L10n.citaEdita, for: .normal)
            firstButton.setImage(UIImage(asset: Asset.Icons.Galeria.tornarNoCompartir), for: .normal)
            secondButton.setImage(UIImage(asset: Asset.Icons.Agenda.editarCita), for: .normal)
            firstButton.greenMode = false

            firstButton.addTargetClosure { (sender) in
                self.delegate?.deleteClicked(meeting: meeting)
              
            }
            
            secondButton.addTargetClosure { (sender) in
               self.delegate?.editClicked(meeting: meeting)
            }
            
            if UIDevice.current.userInterfaceIdiom == .phone{
                firstButton.setTitle(L10n.citaCancelaPhone, for: .normal)
                secondButton.setTitle(L10n.citaEditaPhone, for: .normal)
            }
        }
        else{
            // INVITED
            
            if let myState = meeting.guests.filter("userInfo.id == %i", profileModelManager.getUserMe()?.id ?? -1).first?.state{
                switch myState{
                case "PENDING":
                    firstButton.greenMode = true
                    firstButton.isHidden = false
                    secondButton.isHidden = false
                 
                    meetingBack.isHidden = false

                    
                    firstButton.setTitle(L10n.citaAccepta, for: .normal)
                    secondButton.setTitle(L10n.citaRebutjar, for: .normal)
                    if UIDevice.current.userInterfaceIdiom == .phone{
                        firstButton.setTitle(L10n.citaAcceptaPhone, for: .normal)
                        secondButton.setTitle(L10n.citaCitaRebutjarPhone, for: .normal)
                    }
                    firstButton.setImage(UIImage(asset: Asset.Icons.Agenda.checkGreen), for: .normal)

                    secondButton.setImage(UIImage(asset: Asset.Icons.Galeria.tornarNoCompartir), for: .normal)
                    
                    firstButton.addTargetClosure { (sender) in
                        
                        self.delegate?.acceptClicked(meeting: meeting)

                       
                    }
                    
                    secondButton.addTargetClosure { (sender) in
                        
                        self.delegate?.declineClicked(meeting: meeting)

                       
                    }
                case "ACCEPTED":
                    firstButton.isHidden = false
                    secondButton.isHidden = true
                    firstButton.greenMode = false

                    firstButton.setTitle(L10n.citaNoAsistire, for: .normal)
                    firstButton.setImage(UIImage(asset: Asset.Icons.Galeria.tornarNoCompartir), for: .normal)
                    firstButton.addTargetClosure { (sender) in
                        self.delegate?.declineClicked(meeting: meeting)

                    }
                case "REJECTED":
                    firstButton.isHidden = true
                    secondButton.isHidden = true
                  
                default:
                    break
                    
                }
            }
         
        }
        
        if UIScreen.main.nativeBounds.height == 1136{
            firstButton.setImage(nil, for: .normal)
            secondButton.setImage(nil, for: .normal)

        }
        
        
    }
    
    
}
