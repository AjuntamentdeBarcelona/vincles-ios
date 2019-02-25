//
//  IncomingChatTableViewCell.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import AVFoundation

protocol IncomingChatTableViewCellDelegate{
    func tappedImage(imageView: UIImageView)
    func tappedVideo(contentId: Int, isGroup: Bool)
}

class IncomingChatTableViewCell: UITableViewCell, UIScrollViewDelegate {

    @IBOutlet weak var messageBubbleTopLabel: UILabel!
    @IBOutlet weak var messageBubbleImageView: UIImageView!
    @IBOutlet weak var messageBubbleContainerView: UIView!
    @IBOutlet weak var avatarImageView: CircularImageView!
    @IBOutlet weak var textViewContainer: RoundedView!
    @IBOutlet weak var textViewWidth: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var distanceImageTextView: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var actIndAudio: UIActivityIndicatorView!
    @IBOutlet weak var buttonDownloadAudio : UIButton!
    @IBOutlet weak var textMessageLabel: UILabel!

    var delegate: IncomingChatTableViewCellDelegate?

    @IBOutlet weak var viewAudio: UIView!
    var message: Message?
    var groupMessage: GroupMessage?

    @IBOutlet weak var labelAudio : UILabel!
    @IBOutlet weak var buttonPlay : UIButton!
    @IBOutlet weak var sliderAudio : UISlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.messageBubbleTopLabel.textAlignment = .left
        textViewContainer!.options = [.topRight, .bottomLeft, .bottomRight]

        textViewContainer!.radius = 12.0
        messageBubbleImageView.tintColor = UIColor(named: .grayChatReceived)
        textViewContainer.backgroundColor = UIColor(named: .grayChatReceived)
       // mediaImageView.layer.cornerRadius = 12.0

       //  textView.isEditable = false
      //   textView.isSelectable = true
      //   textView.isUserInteractionEnabled = true
     
     //    textView.contentInset = UIEdgeInsets.zero
     //    textView.scrollIndicatorInsets = UIEdgeInsets.zero
     //    textView.contentOffset = CGPoint.zero
     //    textView.textContainerInset = UIEdgeInsets.zero
    //     textView.textContainer.lineFragmentPadding = 0;
     //    textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        let linkAttributes: [String : Any] = [
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.green,
            NSAttributedStringKey.underlineColor.rawValue: UIColor.lightGray,
            NSAttributedStringKey.underlineStyle.rawValue: NSUnderlineStyle.styleSingle.rawValue]
        
     //    textView.linkTextAttributes = linkAttributes
        buttonPlay.setImage(UIImage(asset: Asset.Icons.Chat.play), for: .normal)

        scrollView.delegate = self


    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configWithMessage(message: Message, sender: User, hideAvatar: Bool){
        self.avatarImageView.isHidden = hideAvatar
        
        if hideAvatar{
            textViewContainer!.options = [.topLeft, .topRight, .bottomLeft, .bottomRight]
            messageBubbleImageView.isHidden = true
        }
        else{
            textViewContainer!.options = [.topRight, .bottomLeft, .bottomRight]
            messageBubbleImageView.isHidden = false
        }
        self.message = message
        textMessageLabel.text = message.messageText
        if let tamanyLletra = UserDefaults.standard.value(forKey: "tamanyLletra") as? String{
            switch tamanyLletra{
            case "PETIT":
                textMessageLabel.font = UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(SMALL_FONT_CHAT))
            case "MITJA":
                textMessageLabel.font = UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(MEDIUM_FONT_CHAT))
            case "GRAN":
                textMessageLabel.font = UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(BIG_FONT_CHAT))
            default:
                break
            }
        }
        let mediaManager = MediaManager()
        avatarImageView.tag = sender.id
        
        mediaManager.setProfilePicture(userId: sender.id, imageView: avatarImageView) {
            
        }
        
        var size = 15.0
        
        if  (UIDevice.current.userInterfaceIdiom == .pad){
            size = 19.0
        }
        
        let lang = UserDefaults.standard.string(forKey: "i18n_language")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: lang!)
        let hour = dateFormatter.string(from: message.sendTime)
        
        let blackAttribute = [ NSAttributedStringKey.font: UIFont(font: FontFamily.AkkuratBold.bold, size: CGFloat(size)), NSAttributedStringKey.foregroundColor: UIColor.black ] as [NSAttributedStringKey : Any]
        let grayAttribute = [ NSAttributedStringKey.font: UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(size)), NSAttributedStringKey.foregroundColor: UIColor(named: .darkGray) ] as [NSAttributedStringKey : Any]
        
        let firstString = NSMutableAttributedString(string: sender.name, attributes: blackAttribute)
        firstString.append(NSAttributedString(string: " \(hour)" , attributes: grayAttribute))

        messageBubbleTopLabel.attributedText = firstString
        
        let occupedSpaceLeft = CGFloat(73.0)
        var leaveSpaceRight = CGFloat(90.0)
        if  (UIDevice.current.userInterfaceIdiom == .pad){
            leaveSpaceRight = CGFloat(290.0)
        }
        
        let availableSpace = UIScreen.main.bounds.size.width - 50 - (occupedSpaceLeft + leaveSpaceRight)
        
        let chatManager = ChatManager()
        let bubbleSize = chatManager.getBubbleSizeForMessage(message: message, width: availableSpace, font: textMessageLabel.font!)
        textViewWidth.constant = bubbleSize.width
        textViewHeight.constant = bubbleSize.height

        imageHeight.constant = availableSpace
        
        
        if message.messageText.count == 0{
            distanceImageTextView.constant = 0
            print(bubbleSize.width)
            textViewWidth.constant = bubbleSize.width
            textViewHeight.constant = 0
            textMessageLabel.isHidden = true
        }
        else{
            textViewWidth.constant = bubbleSize.width + 2
            textViewHeight.constant = bubbleSize.height + 2
            textMessageLabel.isHidden = false
            
        }
        
        if message.idAdjuntContents.count == 0{
            distanceImageTextView.constant = 0
            imageHeight.constant = 0
        }
        else{
            distanceImageTextView.constant = 5
        }
        

        for view in scrollView.subviews{
            view.removeFromSuperview()
        }
        
        pageControl.isHidden = true
        if message.idAdjuntContents.count > 1{
            pageControl.isHidden = false
            pageControl.numberOfPages = message.idAdjuntContents.count

        }
        viewAudio.isHidden = true
        actIndAudio.isHidden = true

        buttonPlay.isHidden = true
        actIndAudio.isHidden = true

        if message.idAdjuntContents.count > 0{
            let itemWidth = bubbleSize.width + 16
            
            for (index,adjunt) in message.idAdjuntContents.enumerated(){
                let itemView = UIView(frame: CGRect(x: CGFloat(index) * itemWidth, y: 0, width: itemWidth, height: itemWidth))
                itemView.clipsToBounds = true
                
                let activityInd = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                activityInd.isHidden = true
                itemView.addSubview(activityInd)
                
                let itemImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: itemWidth, height: itemWidth))
                itemImageView.contentMode = .scaleAspectFill
                itemImageView.clipsToBounds = true
                activityInd.center = itemImageView.center

                itemImageView.tag = adjunt
                itemImageView.isUserInteractionEnabled = true
                itemView.addSubview(itemImageView)
                
                viewAudio.isHidden = true

                itemView.backgroundColor = UIColor(named: .darkGray)
                self.scrollView.addSubview(itemView)
               
                let downloadButton = UIButton(frame: CGRect(x: 0, y: 0, width: itemWidth * 0.25, height: itemWidth * 0.25))
                downloadButton.center = itemImageView.center
                downloadButton.setImage(UIImage(asset: Asset.Icons.Galeria.download), for: .normal)
                itemView.addSubview(downloadButton)
                
                let playButton = UIButton(frame: CGRect(x: 0, y: 0, width: itemWidth * 0.5, height: itemWidth * 0.5))
                playButton.center = itemImageView.center
                playButton.setImage(UIImage(asset: Asset.Icons.Galeria.video), for: .normal)
                playButton.isUserInteractionEnabled = false
                playButton.isHidden = true
                
                itemImageView.addSubview(playButton)
                
                if UserDefaults.standard.bool(forKey: "manualDownload") && !mediaManager.chatExistingItem(id: adjunt){
                    downloadButton.isHidden = false
                    
                    if message.metadataTipus.contains("AUDIO"){
                        buttonDownloadAudio.isHidden = false
                    }
                    
                }
                else{
                    downloadButton.isHidden = true
                    
                    downloadMediaItem(adjunt: adjunt, itemImageView: itemImageView, playButton: playButton, activityInd: activityInd, downloadButton: downloadButton)
                }

                downloadButton.addTargetClosure { (sender) in
                    self.downloadMediaItem(adjunt: adjunt, itemImageView: itemImageView, playButton: playButton, activityInd: activityInd, downloadButton: downloadButton)
                }
                
                buttonDownloadAudio.addTargetClosure { (sender) in
                    self.downloadMediaItem(adjunt: adjunt, itemImageView: itemImageView, playButton: playButton, activityInd: activityInd, downloadButton: downloadButton)
                }
                
               
                
            }
 
            scrollView.isHidden = false
            
            if message.metadataTipus.contains("AUDIO"){
                scrollView.isHidden = true
                self.imageHeight.constant = 60
                buttonPlay.isHidden = true
                viewAudio.isHidden = false
                
            }
            else{
                scrollView.contentSize = CGSize(width: CGFloat(message.idAdjuntContents.count) * itemWidth, height: itemWidth)
                self.imageHeight.constant = itemWidth
            }
        }
        
        if message.watched{
            textViewContainer.backgroundColor = UIColor(named: .grayChatReceived)
            messageBubbleImageView.tintColor = UIColor(named: .grayChatReceived)
        }
        else{
            textViewContainer.backgroundColor = UIColor(named: .redNotifications)
            messageBubbleImageView.tintColor = UIColor(named: .redNotifications)

        }
 
    }
    
    func downloadMediaItem(adjunt: Int, itemImageView: UIImageView, playButton: UIButton, activityInd: UIActivityIndicatorView, downloadButton: UIButton){
        let mediaManager = MediaManager()
        
        activityInd.startAnimating()
        activityInd.isHidden = false
        downloadButton.isHidden = true
        self.actIndAudio.startAnimating()
        self.actIndAudio.isHidden = false
        buttonDownloadAudio.isHidden = true
        
        mediaManager.setChatMedia(contentId: adjunt, imageView: itemImageView, isThumb: true, onCompletion: { (success,messageType) in
            
            DispatchQueue.main.async {
                
                if success{
                    downloadButton.isHidden = true
                    self.buttonDownloadAudio.isHidden = true
                    
                    if messageType == .video{
                        playButton.isHidden = false
                        
                        itemImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(self.tapVideo)))
                    }
                    else if messageType == .image{
                        playButton.isHidden = true
                        
                        itemImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(self.tapImageView)))
                        
                    }
                    else if messageType == .audio{
                        playButton.isHidden = true
                        
                        DispatchQueue.main.async { () -> Void in
                            
                            self.buttonPlay.isHidden = false
                            
                            do {
                                
                                let documentDirectory = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                                let fileURLAudio = documentDirectory.appendingPathComponent("audio\(self.message!.idAdjuntContents[0]).m4a")
                                
                                
                                do {
                                    let player = try AVAudioPlayer(contentsOf: fileURLAudio)

                                    print(player.duration)

                                        self.labelAudio.text = self.stringFromTimeInterval(interval: player.duration) as String
                                        self.sliderAudio.maximumValue = Float(player.duration)
                                        
                                        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
                                        
                                        self.actIndAudio.stopAnimating()
                                        self.actIndAudio.isHidden = true
                          
                                    
                                   
                                } catch let error as NSError {
                                    print(error.description)
                                    print(error.description)

                                }
                                
                            } catch let error as NSError {
                                print(error.description)
                            }
                        }
                        
                    }
                    
                    activityInd.stopAnimating()
                    activityInd.isHidden = true
                    self.actIndAudio.stopAnimating()
                    self.actIndAudio.isHidden = true
                }
                else{
                    activityInd.stopAnimating()
                    self.buttonDownloadAudio.isHidden = false
                    
                    self.actIndAudio.stopAnimating()
                    self.actIndAudio.isHidden = true
                    
                    playButton.isHidden = true
                    activityInd.isHidden = true
                    downloadButton.isHidden = false
                }
            }
            
            
        })
    }
    
    func downloadMediaItemGroup(message: GroupMessage, itemImageView: UIImageView, playButton: UIButton, activityInd: UIActivityIndicatorView, downloadButton: UIButton){
        let mediaManager = MediaManager()
        
        activityInd.startAnimating()
        activityInd.isHidden = false
        downloadButton.isHidden = true
        self.actIndAudio.startAnimating()
        self.actIndAudio.isHidden = false
        buttonDownloadAudio.isHidden = true
        
        mediaManager.setGroupChatMedia(idMessage: message.id, idChat: message.idChat, imageView: itemImageView, isThumb: true, onCompletion: {(success, messageType) in

            DispatchQueue.main.async {
                
                if success{
                    downloadButton.isHidden = true
                    self.buttonDownloadAudio.isHidden = true
                    
                    if messageType == .video{
                        playButton.isHidden = false
                        
                        itemImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(self.tapVideo)))
                    }
                    else if messageType == .image{
                        playButton.isHidden = true
                        
                        itemImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(self.tapImageView)))
                        
                    }
                    else if messageType == .audio{
                        playButton.isHidden = true
                        
                        DispatchQueue.main.async { () -> Void in
                            
                            self.buttonPlay.isHidden = false
                            
                            do {
                                
                                let documentDirectory = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                                let fileURLAudio = documentDirectory.appendingPathComponent("group_audio\(message.id).m4a")
                                
                                
                                do {
                                    let player = try AVAudioPlayer(contentsOf: fileURLAudio)
                                    
                                    
                                        self.labelAudio.text = self.stringFromTimeInterval(interval: player.duration) as String
                                        self.sliderAudio.maximumValue = Float(player.duration)
                                        
                                        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
                                        
                                        self.actIndAudio.stopAnimating()
                                        self.actIndAudio.isHidden = true
                                    
                                    
                                    
                                   
                                } catch let error as NSError {
                                    print(error.description)
                                }
                                
                            } catch let error as NSError {
                                print(error.description)
                            }
                        }
                        
                    }
                    
                    activityInd.stopAnimating()
                    activityInd.isHidden = true
                    self.actIndAudio.stopAnimating()
                    self.actIndAudio.isHidden = true
                }
                else{
                    activityInd.stopAnimating()
                    self.buttonDownloadAudio.isHidden = false
                    
                    self.actIndAudio.stopAnimating()
                    self.actIndAudio.isHidden = true
                    
                    playButton.isHidden = true
                    activityInd.isHidden = true
                    downloadButton.isHidden = false
                }
            }
            
            
        })
    }
    
    func configWithGroupMessage(message: GroupMessage, hideAvatar: Bool){
        self.avatarImageView.isHidden = hideAvatar
        
        if hideAvatar{
            textViewContainer!.options = [.topLeft, .topRight, .bottomLeft, .bottomRight]
            messageBubbleImageView.isHidden = true
        }
        else{
            textViewContainer!.options = [.topRight, .bottomLeft, .bottomRight]
            messageBubbleImageView.isHidden = false
        }

        
        
        self.groupMessage = message
        textMessageLabel.text = message.text
        if let tamanyLletra = UserDefaults.standard.value(forKey: "tamanyLletra") as? String{
            switch tamanyLletra{
            case "PETIT":
                textMessageLabel.font = UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(SMALL_FONT_CHAT))
            case "MITJA":
                textMessageLabel.font = UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(MEDIUM_FONT_CHAT))
            case "GRAN":
                textMessageLabel.font = UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(BIG_FONT_CHAT))
            default:
                break
            }
        }
        let mediaManager = MediaManager()
        avatarImageView.tag = message.idUserSender
        
        mediaManager.setProfilePicture(userId: message.idUserSender, imageView: avatarImageView) {
            
        }
        
        var size = 15.0
        
        if  (UIDevice.current.userInterfaceIdiom == .pad){
            size = 19.0
        }
        
        let lang = UserDefaults.standard.string(forKey: "i18n_language")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: lang!)
        let hour = dateFormatter.string(from: message.sendTime)
        
        let blackAttribute = [ NSAttributedStringKey.font: UIFont(font: FontFamily.AkkuratBold.bold, size: CGFloat(size)), NSAttributedStringKey.foregroundColor: UIColor.black ] as [NSAttributedStringKey : Any]
        let grayAttribute = [ NSAttributedStringKey.font: UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(size)), NSAttributedStringKey.foregroundColor: UIColor(named: .darkGray) ] as [NSAttributedStringKey : Any]
        
        let firstString = NSMutableAttributedString(string: message.fullNameUserSender, attributes: blackAttribute)
        firstString.append(NSAttributedString(string: " \(hour)" , attributes: grayAttribute))
        
        messageBubbleTopLabel.attributedText = firstString
        
        let occupedSpaceLeft = CGFloat(73.0)
        var leaveSpaceRight = CGFloat(90.0)
        if  (UIDevice.current.userInterfaceIdiom == .pad){
            leaveSpaceRight = CGFloat(290.0)
        }
        
        let availableSpace = UIScreen.main.bounds.size.width - 50 - (occupedSpaceLeft + leaveSpaceRight)
        
        let chatManager = ChatManager()
        let bubbleSize = chatManager.getBubbleSizeForGroupMessage(message: message, width: availableSpace, font: textMessageLabel.font!)
        textViewWidth.constant = bubbleSize.width + 2
        textViewHeight.constant = bubbleSize.height + 2
        
        imageHeight.constant = availableSpace
        
        if message.text.count == 0{
            distanceImageTextView.constant = 0
        }
        
        if message.idContent == -1{
            distanceImageTextView.constant = 0
            imageHeight.constant = 0
        }
        else{
            distanceImageTextView.constant = 5
        }
        
        for view in scrollView.subviews{
            view.removeFromSuperview()
        }
        
        pageControl.isHidden = true
        
        actIndAudio.isHidden = true
        buttonPlay.isHidden = true
        if message.idContent != -1{
            let itemWidth = bubbleSize.width + 16
            
            let itemView = UIView(frame: CGRect(x: 0, y: 0, width: itemWidth, height: itemWidth))
            itemView.clipsToBounds = true
            
            let activityInd = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            activityInd.center = itemView.center
            activityInd.isHidden = true
            itemView.addSubview(activityInd)
            
            
            let itemImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: itemWidth, height: itemWidth))
            itemImageView.contentMode = .scaleAspectFill
            itemImageView.clipsToBounds = true
            
            itemImageView.tag = message.id
            itemImageView.isUserInteractionEnabled = true
            itemView.addSubview(itemImageView)
            
            viewAudio.isHidden = true
            
            itemView.backgroundColor = UIColor(named: .darkGray)
            self.scrollView.addSubview(itemView)
            
            let downloadButton = UIButton(frame: CGRect(x: 0, y: 0, width: itemWidth * 0.25, height: itemWidth * 0.25))
            downloadButton.center = itemView.center
            downloadButton.setImage(UIImage(asset: Asset.Icons.Galeria.download), for: .normal)
            itemView.addSubview(downloadButton)
            
            let playButton = UIButton(frame: CGRect(x: 0, y: 0, width: itemWidth * 0.5, height: itemWidth * 0.5))
            playButton.center = itemView.center
            playButton.setImage(UIImage(asset: Asset.Icons.Galeria.video), for: .normal)
            playButton.isUserInteractionEnabled = false
            playButton.isHidden = true
            itemView.addSubview(playButton)
            
            if UserDefaults.standard.bool(forKey: "manualDownload") && !mediaManager.chatGroupExistingItem(idMessage: message.id){
                downloadButton.isHidden = false
                
                if message.metadataTipus.contains("AUDIO"){
                    buttonDownloadAudio.isHidden = false
                }
                
            }
            else{
                downloadButton.isHidden = true
                
                downloadMediaItemGroup(message: message, itemImageView: itemImageView, playButton: playButton, activityInd: activityInd, downloadButton: downloadButton)
            }
            
            downloadButton.addTargetClosure { (sender) in
                self.downloadMediaItemGroup(message: message, itemImageView: itemImageView, playButton: playButton, activityInd: activityInd, downloadButton: downloadButton)

            }
            
            buttonDownloadAudio.addTargetClosure { (sender) in
                self.downloadMediaItemGroup(message: message, itemImageView: itemImageView, playButton: playButton, activityInd: activityInd, downloadButton: downloadButton)
            }
            
            
            scrollView.isHidden = false
            
            if message.metadataTipus.contains("AUDIO"){
                scrollView.isHidden = true
                self.imageHeight.constant = 60
                buttonPlay.isHidden = true
                viewAudio.isHidden = false
                
            }
            else{
                scrollView.contentSize = CGSize(width: itemWidth, height: itemWidth)
                self.imageHeight.constant = itemWidth
            }
        }
        
        // DONE WATCHED
        if message.watched{
            textViewContainer.backgroundColor = UIColor(named: .grayChatReceived)
            messageBubbleImageView.tintColor = UIColor(named: .grayChatReceived)
        }
        else{
            textViewContainer.backgroundColor = UIColor(named: .redNotifications)
            messageBubbleImageView.tintColor = UIColor(named: .redNotifications)
            
        }
    }
    
    @objc func tapImageView(sender: UITapGestureRecognizer){
        delegate?.tappedImage(imageView: (sender.view)! as! UIImageView)
    }
    
    @objc func tapVideo(sender: UITapGestureRecognizer){
        if groupMessage == nil{
            delegate?.tappedVideo(contentId: (sender.view?.tag)!, isGroup: false)
        }
        else{
            delegate?.tappedVideo(contentId: (sender.view?.tag)!, isGroup: true)
        }
    }

    
    func stopAudio(){
        var isPlaying = false
        if let player = AudioManager.sharedInstance.player{
            var id = -1
            if message != nil{
                id = self.message!.id
            }
            else if groupMessage != nil{
                id = self.groupMessage!.id
                
            }
            
            if AudioManager.sharedInstance.playingContent == id{
                isPlaying = true
            }
            print("\(id) - \(AudioManager.sharedInstance.playingContent)")
        }
        
        if isPlaying{
            buttonPlay.setImage(UIImage(asset: Asset.Icons.Chat.play), for: .normal)
        }
        else{
            sliderAudio.setValue(0, animated: false)
            self.labelAudio.text = self.stringFromTimeInterval(interval: Double(self.sliderAudio.maximumValue)) as String
            buttonPlay.setImage(UIImage(asset: Asset.Icons.Chat.play), for: .normal)
        }
        
    }
    
    @IBAction func playAudio(_ sender: UIButton) {
        var isPlaying = false
        if let player = AudioManager.sharedInstance.player{
            var id = -1
            if message != nil{
                id = self.message!.id
            }
            else if groupMessage != nil{
                id = self.groupMessage!.id
                
            }
            
            if AudioManager.sharedInstance.playingContent == id{
                isPlaying = true
            }
        }
        
        var fileURLAudio: URL?
        let documentDirectory = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        
        if message != nil{
            AudioManager.sharedInstance.playingContent = self.message!.id
            fileURLAudio = documentDirectory.appendingPathComponent("audio\(self.message!.idAdjuntContents[0]).m4a")
        }
        else if groupMessage != nil{
            AudioManager.sharedInstance.playingContent = self.groupMessage!.id
            fileURLAudio = documentDirectory.appendingPathComponent("group_audio\(groupMessage!.id).m4a")
        }
        
        if let fileURLAudio = fileURLAudio{
            do {
                
                
                if isPlaying &&  AudioManager.sharedInstance.player != nil &&  (AudioManager.sharedInstance.player?.isPlaying)!{
                    AudioManager.sharedInstance.player?.pause()
                    
                    sender.setImage(UIImage(asset: Asset.Icons.Chat.play), for: .normal)
                }
                else if isPlaying &&  AudioManager.sharedInstance.player != nil &&  AudioManager.sharedInstance.player?.currentTime != TimeInterval(0.0){
                    AudioManager.sharedInstance.player?.play()
                    
                    sender.setImage(UIImage(asset: Asset.Icons.Chat.pause), for: .normal)
                }
                else{
                    AudioManager.sharedInstance.player?.currentTime = TimeInterval(0.0)
                    AudioManager.sharedInstance.player?.stop()
                    AudioManager.sharedInstance.player = try AVAudioPlayer(contentsOf: fileURLAudio)
                    AudioManager.sharedInstance.player?.delegate = AudioManager.sharedInstance
                    AudioManager.sharedInstance.audioStop()
                    AudioManager.sharedInstance.player?.prepareToPlay()
                    sender.setImage(UIImage(asset: Asset.Icons.Chat.pause), for: .normal)
                    AudioManager.sharedInstance.player?.play()
                }
                
                
            } catch let error as NSError {
                AudioManager.sharedInstance.player?.currentTime = TimeInterval(0.0)
                AudioManager.sharedInstance.player?.stop()
                AudioManager.sharedInstance.audioStop()
                
            }
        }
        
    }
    
    @objc func updateSlider(){
        var id = -1
        if message != nil{
            id = self.message!.id
        }
        else if groupMessage != nil{
            id = self.groupMessage!.id
            
        }
        
        if AudioManager.sharedInstance.playingContent == id{
            
            if let player = AudioManager.sharedInstance.player{
                if player.isPlaying{
                    buttonPlay.setImage(UIImage(asset: Asset.Icons.Chat.pause), for: .normal)
                }
                else{
                    buttonPlay.setImage(UIImage(asset: Asset.Icons.Chat.play), for: .normal)
                }

                sliderAudio.value = Float(player.currentTime)
                self.labelAudio.text = self.stringFromTimeInterval(interval: player.currentTime) as String

            }
        }
    }
    
    
    func stringFromTimeInterval(interval: Double) -> NSString {
        
        let hours = (Int(interval) / 3600)
        let minutes = Int(interval / 60) - Int(hours * 60)
        let seconds = Int(interval) - (Int(interval / 60) * 60)
        
        return NSString(format: "%0.2d:%0.2d",minutes,seconds)
    }
    
    @IBAction func slide(_ slider: UISlider) {
        
        var id = -1
        if message != nil{
            id = self.message!.id
        }
        else if groupMessage != nil{
            id = self.groupMessage!.id
            
        }
        
        if AudioManager.sharedInstance.playingContent == id{
            if let player = AudioManager.sharedInstance.player{
                player.currentTime = TimeInterval(slider.value)
                self.labelAudio.text = self.stringFromTimeInterval(interval: player.currentTime) as String

            }
        }
        
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
}

