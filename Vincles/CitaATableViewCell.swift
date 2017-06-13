/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit

class CitaATableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var fromTimeLabel: UILabel!
    @IBOutlet weak var toTimeLabel: UILabel!
    @IBOutlet weak var descripLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var recordaBtn: UIButton!
    @IBOutlet weak var separa: UIView!
    
    enum vcFrom {
        case Avui,Dema,Other
    }
    
    var cellCita:Cita!
    var parentController:UIViewController!
    var isRow:NSIndexPath!
    var from:vcFrom!
    

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func setupCell() {
        
        let langBundle = UserPreferences().bundleForLanguageSelected()
        
        let hourFormatter = NSDateFormatter()
        hourFormatter.dateFormat = "H:mm"
        
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone.localTimeZone()
        
        let toDate = calendar.dateByAddingUnit(.Minute, value: Int(cellCita.duration!)!, toDate:  cellCita.date!, options: [])

        fromTimeLabel.text = hourFormatter.stringFromDate(cellCita.date!)
        toTimeLabel.text = hourFormatter.stringFromDate(toDate!)
        descripLabel.text = cellCita.descript!
        
        switch cellCita.state! {
        case EVENT_STATE_PENDING:
            
            stateLabel.text = langBundle.localizedStringForKey("CELL_STATE_PENDING", value: nil, table: nil)
            recordaBtn.layer.cornerRadius = 4.0
            recordaBtn.enabled = true
            recordaBtn.setTitle("Recordar cita",forState:UIControlState.Normal)
            recordaBtn.hidden = false
            recordaBtn.backgroundColor = UIColor(hexString: HEX_RED_BTN)

        case EVENT_STATE_ACCEPTED:
            stateLabel.text = langBundle.localizedStringForKey("CELL_STATE_ACCEPTED", value: nil, table: nil)
            recordaBtn.hidden = true
        case EVENT_STATE_REJECTED:
            stateLabel.text = langBundle.localizedStringForKey("CELL_STATE_REJECTED", value: nil, table: nil)
            recordaBtn.hidden = true
            createEraseBtn()
            
       default:
            print("DEFAULT STATE CITA == \(cellCita.state!)")
        }
    }
    
    private func createEraseBtn() {
        
        let btn: UIButton = UIButton(frame: CGRectMake(118, 87, 104, 29))
        btn.backgroundColor = UIColor.blackColor()
        btn.layer.cornerRadius = 4.0
        btn.addTarget(self, action: #selector(CitaATableViewCell.deleteCita(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        btn.tag = 1
        self.addSubview(btn)
        
        let btnLabel = UILabel(frame: CGRectMake(0, 0, 60, 23))
        btnLabel.textColor = UIColor.whiteColor()
        btnLabel.font = UIFont(name: "Akkurat-Bold", size: 15)
        btnLabel.text = "Eliminar"
        btnLabel.textAlignment = .Center
        btn.addSubview(btnLabel)
        
        let btnImgView = UIImageView(frame: CGRectMake(0, 0, 15, 15))
        btnImgView.image = UIImage(named: "icon-trash-list")
        btnImgView.contentMode = .ScaleAspectFit
        btn.addSubview(btnImgView)
        
        // btn Constraints
        let widthConstr = NSLayoutConstraint(item: btn, attribute: .Width, relatedBy: .Equal,
                                                 toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 104)
        let heightConstr = NSLayoutConstraint(item: btn, attribute: .Height, relatedBy: .Equal,
                                                  toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 29)
        let bottomSpace = NSLayoutConstraint(item: btn, attribute: .Bottom,
                                                          relatedBy: .Equal, toItem: self, attribute: .BottomMargin,
                                                          multiplier: 1.0, constant: -3)
        let alignLeading = NSLayoutConstraint(item: btn, attribute:.Left,
                                              relatedBy: .Equal, toItem: separa, attribute:.CenterX,
                                              multiplier: 1.0, constant: 13)
        btn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([widthConstr,heightConstr,bottomSpace,alignLeading])
        
        // btnLabel Constraints
        let lblAlignCenterX = NSLayoutConstraint(item: btnLabel, attribute: .CenterX, relatedBy: .Equal, toItem: btn, attribute: .CenterX, multiplier: 1, constant: 8)
        
        let lblAlignCenterY = NSLayoutConstraint(item: btnLabel, attribute: .CenterY, relatedBy: .Equal, toItem: btn, attribute: .CenterY, multiplier: 1, constant: 0)
        
        let widthConstraint = NSLayoutConstraint(item: btnLabel, attribute: .Width, relatedBy: .Equal,
                                                 toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 60)
        let heightConstraint = NSLayoutConstraint(item: btnLabel, attribute: .Height, relatedBy: .Equal,
                                                  toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 23)
        btnLabel.translatesAutoresizingMaskIntoConstraints = false
         NSLayoutConstraint.activateConstraints([widthConstraint,heightConstraint,lblAlignCenterX,lblAlignCenterY])
        
        // btnImageView Constraints
        let imgWidthConstraint = NSLayoutConstraint(item: btnImgView, attribute: .Width, relatedBy: .Equal,
                                                 toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 15)
        let imgHeightConstraint = NSLayoutConstraint(item: btnImgView, attribute: .Height, relatedBy: .Equal,
                                                  toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 15)
        let imgAlignCenterY = NSLayoutConstraint(item: btnImgView, attribute: .CenterY, relatedBy: .Equal, toItem: btnLabel, attribute: .CenterY, multiplier: 1, constant: 0)
        let imgTrailSpace = NSLayoutConstraint(item: btnImgView, attribute: .Right,
                                               relatedBy: .Equal, toItem: btnLabel, attribute: .Left,
                                               multiplier: 1.0, constant: -5)
        btnImgView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([imgWidthConstraint,imgHeightConstraint,imgAlignCenterY,imgTrailSpace])
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func deleteCita(sender:UIButton) {
        
        // check if cita date is today tomorrow or other
        
        switch from! {
        case .Avui:
            let parentVC = parentController as! AvuiVC
            parentVC.deleteCita(cellCita, row: isRow)

        case .Dema:
            let parentVC = parentController as! DemaVC
            parentVC.deleteCita(cellCita, row: isRow)
            
        case .Other:
            let parentVC = parentController as! MesDetailVC
            parentVC.deleteCita(cellCita, row: isRow)
          
        }
    }
    
    @IBAction func recordaBtnPress(sender:UIButton) {
        
        if cellCita.state! == EVENT_STATE_PENDING {
            
            
            // remember cita call
            VinclesApiManager.sharedInstance.rememberCita(cellCita.calendarId!, eventId: cellCita.id!, completion: { (result) in
                
                if result == SUCCESS {
                    
                    
                }else{
                }
            })
            
            // disable recordabtn
            recordaBtn.enabled = false
            recordaBtn.setTitle("Enviada",forState:UIControlState.Normal)
            recordaBtn.backgroundColor = UIColor(hexString: HEX_GRAY_BTN)
        }else{
        }
    }
}
