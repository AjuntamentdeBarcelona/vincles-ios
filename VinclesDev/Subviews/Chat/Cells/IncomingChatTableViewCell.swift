//
//  IncomingChatTableViewCell.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import AVFoundation
import RealmSwift

protocol IncomingChatTableViewCellDelegate{
    func tappedImage(imageView: UIImageView)
    func tappedVideo(contentId: Int, isGroup: Bool)
    func tappedError()
    
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
    @IBOutlet weak var textMessageLabel: ActiveLabel!
    
    var delegate: IncomingChatTableViewCellDelegate?
    
    @IBOutlet weak var viewAudio: UIView!
    var messageId: Int?
    var groupMessageId: Int?
    
    @IBOutlet weak var labelAudio : UILabel!
    @IBOutlet weak var buttonPlay : UIButton!
    @IBOutlet weak var sliderAudio : UISlider!
    
    var senderId = -1
    
    var contentIds = [Int]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for view in scrollView.subviews{
            view.removeFromSuperview()
        }
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.messageBubbleTopLabel.textAlignment = .left
        textViewContainer!.options = [.topRight, .bottomLeft, .bottomRight]
        
        textViewContainer!.radius = 12.0
        messageBubbleImageView.tintColor = UIColor(named: .grayChatReceived)
        textViewContainer.backgroundColor = UIColor(named: .grayChatReceived)
        
        
        let linkAttributes: [String : Any] = [
            NSAttributedString.Key.foregroundColor.rawValue: UIColor.green,
            NSAttributedString.Key.underlineColor.rawValue: UIColor.lightGray,
            NSAttributedString.Key.underlineStyle.rawValue: NSUnderlineStyle.single.rawValue]
        
        //    textView.linkTextAttributes = linkAttributes
        buttonPlay.setImage(UIImage(asset: Asset.Icons.Chat.play), for: .normal)
        
        scrollView.delegate = self
        pageControl.currentPage = 0
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        textMessageLabel.textColor = .darkText
        
        let customType = ActiveType.custom(pattern:"(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?")

        
        textMessageLabel.customColor[customType] = .darkText
        
        textMessageLabel.configureLinkAttribute = { (type, attributes, isSelected) in
            var atts = attributes
            atts[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
            return atts
        }
        
        
        textMessageLabel.enabledTypes = [customType]
        
        textMessageLabel.handleCustomTap(for: customType) { url in
            if !url.lowercased().hasPrefix("http://") && !url.lowercased().hasPrefix("https://"){
                if let urlNew = URL(string: "http://\(url)"){
                    UIApplication.shared.open(urlNew)
                }
            }
            else{
                if let urlNew = URL(string: "\(url)"){
                    UIApplication.shared.open(urlNew)
                }
            }
        }
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func setAvatar(){
        if let url = ProfileImageManager.sharedInstance.getProfilePicture(userId: senderId), let image = UIImage(contentsOfFile: url.path){
            avatarImageView.image = image
        }
        else{
            avatarImageView.image = UIImage(named: "perfilplaceholder")
        }
    }
 
    func setExistingItemPre(adjunt: Int){
        if messageId != nil{
            setExistingItem(adjunt: adjunt)
        }
        else if groupMessageId != nil{
            setExistingItemGroup(idMessage: adjunt)
        }
    }
    
    func configWithMessage(messageId: Int, sender: User, hideAvatar: Bool){
        senderId = sender.id
        
        let chatModelManager = ChatModelManager()
        
        guard let message = chatModelManager.messageWith(id: messageId) else{
            return
        }
        pageControl.currentPage = 0
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        for subview in scrollView.subviews{
            subview.removeFromSuperview()
        }
        
        self.avatarImageView.isHidden = hideAvatar
        
        if hideAvatar{
            textViewContainer!.options = [.topLeft, .topRight, .bottomLeft, .bottomRight]
            messageBubbleImageView.isHidden = true
        }
        else{
            textViewContainer!.options = [.topRight, .bottomLeft, .bottomRight]
            messageBubbleImageView.isHidden = false
        }
        self.messageId = messageId
        
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
        
        avatarImageView.tag = sender.id
    
        if let url = ProfileImageManager.sharedInstance.getProfilePicture(userId: senderId), let image = UIImage(contentsOfFile: url.path){
            avatarImageView.image = image
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
        
        let blackAttribute = [ NSAttributedString.Key.font: UIFont(font: FontFamily.AkkuratBold.bold, size: CGFloat(size)), NSAttributedString.Key.foregroundColor: UIColor.black ] as [NSAttributedString.Key : Any]
        let grayAttribute = [ NSAttributedString.Key.font: UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(size)), NSAttributedString.Key.foregroundColor: UIColor(named: .darkGray) ] as [NSAttributedString.Key : Any]
        
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
        buttonPlay.isHidden = true
        actIndAudio.isHidden = true
        self.scrollView.delegate = self
        
        
        contentIds = [Int]()
        if message.idAdjuntContents.count > 0{
            contentIds = Array(message.idAdjuntContents)
            let itemWidth = bubbleSize.width + 16
            
            for (index,adjunt) in message.idAdjuntContents.enumerated(){
                
                
                let itemView = UIView(frame: CGRect(x: CGFloat(index) * itemWidth, y: 0, width: itemWidth, height: itemWidth))
                itemView.clipsToBounds = true
                itemView.tag = adjunt
                
                let activityInd = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                activityInd.isHidden = true
                activityInd.tag = 1003
                
                itemView.addSubview(activityInd)
                
                let itemImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: itemWidth, height: itemWidth))
                itemImageView.contentMode = .scaleAspectFill
                itemImageView.clipsToBounds = true
                activityInd.center = itemImageView.center
                
                itemImageView.tag = 1005
                itemImageView.isUserInteractionEnabled = true
                itemView.addSubview(itemImageView)
                
                viewAudio.isHidden = true
                
                itemView.backgroundColor = UIColor(named: .darkGray)
                self.scrollView.addSubview(itemView)
                
                let downloadButton = UIButton(frame: CGRect(x: 0, y: 0, width: itemWidth * 0.25, height: itemWidth * 0.25))
                downloadButton.center = itemImageView.center
                downloadButton.tag = 1001
                downloadButton.setImage(UIImage(asset: Asset.Icons.Galeria.download), for: .normal)
                itemView.addSubview(downloadButton)
                
                let playButton = UIButton(frame: CGRect(x: 0, y: 0, width: itemWidth * 0.5, height: itemWidth * 0.5))
                playButton.center = itemImageView.center
                playButton.tag = 1002
                playButton.setImage(UIImage(asset: Asset.Icons.Galeria.video), for: .normal)
                playButton.isUserInteractionEnabled = false
                playButton.isHidden = true
                
                itemImageView.addSubview(playButton)
                
                let errorButton = UIButton(frame: CGRect(x: 0, y: 0, width: itemWidth * 0.25, height: itemWidth * 0.25))
                errorButton.center = itemImageView.center
                errorButton.tag = 1004
                errorButton.setImage(UIImage(asset: Asset.Icons.cancel), for: .normal)
                itemView.addSubview(errorButton)
                errorButton.isHidden = true
          
                if ContentManager.sharedInstance.galleryMediaExists(contentId: adjunt, isGroup: false){
                    setExistingItem(adjunt: adjunt)
                }
                else if UserDefaults.standard.bool(forKey: "manualDownload"){
                    downloadButton.isHidden = false
                    
                    if message.metadataTipus.contains("AUDIO"){
                        buttonDownloadAudio.isHidden = false
                    }
                    
                }
                else{
                    downloadButton.isHidden = true
                    if index == 0{
                        downloadMediaItem(index: 0, adjunt: adjunt)
                    }
                }
                
                downloadButton.addTargetClosure { (sender) in
                    self.downloadMediaItem(index: index,adjunt: adjunt)
                }
                
                buttonDownloadAudio.addTargetClosure { (sender) in
                    self.downloadMediaItem(index: index,adjunt: adjunt)
                }
                
                
                errorButton.addTargetClosure { (sender) in
                    self.delegate?.tappedError()
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
    
    
    
    func setExistingItem(adjunt: Int){
        let container = self.scrollView.viewWithTag(adjunt)
        let chatModelManager = ChatModelManager()
        
        guard let messageId = messageId else{
            return
        }
        
        guard let message = chatModelManager.messageWith(id: messageId) else{
            return
        }
        let messageType =  ContentManager.sharedInstance.getMessageType(adjunt: adjunt, isGroup: false)
        
        
        guard let downloadButton = container?.viewWithTag(1001) as? UIButton else{
            return
        }
        
        guard let playButton = container?.viewWithTag(1002) as? UIButton else{
            return
        }
        
        guard let itemImageView = container?.viewWithTag(1005) as? UIImageView else{
            return
        }
        
        guard let activityInd = container?.viewWithTag(1003) as? UIActivityIndicatorView else{
            return
        }
        
        guard let cancelButton = container?.viewWithTag(1004) as? UIButton else{
            return
        }
        
        
        if ContentManager.sharedInstance.corruptedIds.contains(adjunt){
            playButton.isHidden = true
            activityInd.isHidden = true
            cancelButton.isHidden = false
            downloadButton.isHidden = true
            return
        }
        
        if ContentManager.sharedInstance.errorIds.contains(adjunt){
            cancelButton.isHidden = false
            downloadButton.isHidden = true
            playButton.isHidden = true
            activityInd.isHidden = true
            return
        }
        
        
        
       
        
        downloadButton.isHidden = true
        
        self.buttonDownloadAudio.isHidden = true
        
        var player: AVAudioPlayer?
        
        if messageType == .video || messageType == .image{
            let documentDirectory = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURLThumb = documentDirectory.appendingPathComponent("thumb\(adjunt).jpg")
            
            if FileManager.default.fileExists(atPath: fileURLThumb.path){
                if let image = UIImage(contentsOfFile: fileURLThumb.path) {
                    itemImageView.image = image
                }
            }
        }
        else{
            do {
                let documentDirectory = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURLAudio = documentDirectory.appendingPathComponent("audio\(message.idAdjuntContents[0]).m4a")
                player = try AVAudioPlayer(contentsOf: fileURLAudio)
            } catch let error as NSError {
                print(error.description)
            }
        }
        
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
                
                guard let player = player else{
                    return
                }
                self.buttonPlay.isHidden = false
                self.labelAudio.text = self.stringFromTimeInterval(interval: player.duration) as String
                self.sliderAudio.maximumValue = Float(player.duration)
                
                Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
                
                self.actIndAudio.stopAnimating()
                self.actIndAudio.isHidden = true
            }
            
        }
        cancelButton.isHidden = true
        
        if messageType == .video{
            let documentDirectory = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURLVideo = documentDirectory.appendingPathComponent("gallery\(adjunt).mp4")
            let fileURLThumb = documentDirectory.appendingPathComponent("thumb\(adjunt).jpg")
            
            if !FileManager.default.fileExists(atPath: fileURLThumb.path) && FileManager.default.fileExists(atPath: fileURLVideo.path){
                cancelButton.isHidden = false
                downloadButton.isHidden = true
                playButton.isHidden = true
                
            }
            
        }
        
        
        activityInd.stopAnimating()
        activityInd.isHidden = true
        self.actIndAudio.stopAnimating()
        self.actIndAudio.isHidden = true
        
        
    }
    
    func downloadMediaItem(index: Int, adjunt: Int){
        
        let container = self.scrollView.viewWithTag(adjunt)
        
        guard let downloadButton = container?.viewWithTag(1001) as? UIButton else{
            return
        }

        guard let activityInd = container?.viewWithTag(1003) as? UIActivityIndicatorView else{
            return
        }
        
        activityInd.startAnimating()
        activityInd.isHidden = false
        downloadButton.isHidden = true
        self.actIndAudio.startAnimating()
        self.actIndAudio.isHidden = false
        buttonDownloadAudio.isHidden = true
        
        if ContentManager.sharedInstance.galleryMediaExists(contentId: adjunt, isGroup: false){
            self.setExistingItem(adjunt: adjunt)
        }
        else{
          ContentManager.sharedInstance.downloadGalleryMedia(contentId: adjunt, isGroup: false)
        }
    }
    
    
    func setExistingItemGroup(idMessage: Int){
        let container = self.scrollView.viewWithTag(0)
        
        let messageType =  ContentManager.sharedInstance.getMessageType(adjunt: idMessage, isGroup: true)

        guard let downloadButton = container?.viewWithTag(1001) as? UIButton else{
            return
        }
        
        guard let playButton = container?.viewWithTag(1002) as? UIButton else{
            return
        }
        
        guard let itemImageView = container?.viewWithTag(idMessage) as? UIImageView else{
            return
        }
        
        guard let activityInd = container?.viewWithTag(1003) as? UIActivityIndicatorView else{
            return
        }
        
        guard let cancelButton = container?.viewWithTag(1004) as? UIButton else{
            return
        }
        
        
        downloadButton.isHidden = true
        
        self.buttonDownloadAudio.isHidden = true
        
        var player: AVAudioPlayer?
        
        if messageType == .video || messageType == .image{
            DispatchQueue.main.async {
                let documentDirectory = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURLThumb = documentDirectory.appendingPathComponent("group_thumb\(idMessage).jpg")
                
                if FileManager.default.fileExists(atPath: fileURLThumb.path){
                    if let image = UIImage(contentsOfFile: fileURLThumb.path) {
                        itemImageView.image = image
                    }
                }
            }
           
        }
        else{
            do {
                guard let messageId = groupMessageId else{
                    return
                }
                let documentDirectory = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURLAudio = documentDirectory.appendingPathComponent("group_audio\(messageId).m4a")
                player = try AVAudioPlayer(contentsOf: fileURLAudio)
                
            } catch let error as NSError {
                print(error.description)
            }
        }
        
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
                
                guard let player = player else{
                    return
                }
                self.buttonPlay.isHidden = false
                self.labelAudio.text = self.stringFromTimeInterval(interval: player.duration) as String
                self.sliderAudio.maximumValue = Float(player.duration)
                
                Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
                
                self.actIndAudio.stopAnimating()
                self.actIndAudio.isHidden = true
            }
            
        }
        cancelButton.isHidden = true
        
        if messageType == .video{
            guard let groupMessageId = groupMessageId else{
                return
            }
            let documentDirectory = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURLVideo = documentDirectory.appendingPathComponent("group_gallery\(groupMessageId).mp4")
            let fileURLThumb = documentDirectory.appendingPathComponent("group_thumb\(groupMessageId).jpg")
            
            if FileManager.default.fileExists(atPath: fileURLVideo.path) && !FileManager.default.fileExists(atPath: fileURLThumb.path){
                cancelButton.isHidden = false
                downloadButton.isHidden = true
                playButton.isHidden = true
                
            }
            
        }
        
        
        activityInd.stopAnimating()
        activityInd.isHidden = true
        self.actIndAudio.stopAnimating()
        self.actIndAudio.isHidden = true
        
        
    }
    
    func downloadMediaItemGroup(message: GroupMessage){
        
        let container = self.scrollView.viewWithTag(0)
        
        guard let downloadButton = container?.viewWithTag(1001) as? UIButton else{
            return
        }
        
      
        guard let activityInd = container?.viewWithTag(1003) as? UIActivityIndicatorView else{
            return
        }
        
       
        
        activityInd.startAnimating()
        activityInd.isHidden = false
        downloadButton.isHidden = true
        self.actIndAudio.startAnimating()
        self.actIndAudio.isHidden = false
        buttonDownloadAudio.isHidden = true
        
        
        if ContentManager.sharedInstance.galleryMediaExists(contentId: message.id, isGroup: true){
            self.setExistingItemGroup(idMessage: message.id)
        }
        else{
            ContentManager.sharedInstance.downloadGalleryMedia(contentId: message.id, isGroup: true, idChat: message.idChat)
        }
       
    }
    
    
    func configWithGroupMessage(messageId: Int, hideAvatar: Bool){
        
        let chatModelManager = ChatModelManager()
        
        guard let message = chatModelManager.groupMessageWith(id: messageId) else{
            return
        }
        
        senderId = message.idUserSender
        
        for view in scrollView.subviews{
            view.removeFromSuperview()
        }
        
        self.avatarImageView.isHidden = hideAvatar
        
        if hideAvatar{
            textViewContainer!.options = [.topLeft, .topRight, .bottomLeft, .bottomRight]
            messageBubbleImageView.isHidden = true
        }
        else{
            textViewContainer!.options = [.topRight, .bottomLeft, .bottomRight]
            messageBubbleImageView.isHidden = false
        }
        
        
        
        self.groupMessageId = messageId
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
      
        
        if let url = ProfileImageManager.sharedInstance.getProfilePicture(userId: senderId), let image = UIImage(contentsOfFile: url.path){
            avatarImageView.image = image
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
        
        let blackAttribute = [ NSAttributedString.Key.font: UIFont(font: FontFamily.AkkuratBold.bold, size: CGFloat(size)), NSAttributedString.Key.foregroundColor: UIColor.black ] as [NSAttributedString.Key : Any]
        let grayAttribute = [ NSAttributedString.Key.font: UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(size)), NSAttributedString.Key.foregroundColor: UIColor(named: .darkGray) ] as [NSAttributedString.Key : Any]
        
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
        
        
        
        pageControl.isHidden = true
        
        actIndAudio.isHidden = true
        buttonPlay.isHidden = true
        
        contentIds = [Int]()
        if message.idContent != -1{
            contentIds.append(message.id)
            let itemWidth = bubbleSize.width + 16
            
            let itemView = UIView(frame: CGRect(x: 0, y: 0, width: itemWidth, height: itemWidth))
            itemView.clipsToBounds = true
            itemView.tag = 0
            
            let activityInd = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            activityInd.center = itemView.center
            activityInd.isHidden = true
            itemView.addSubview(activityInd)
            activityInd.tag = 1003
            
            
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
            downloadButton.tag = 1001
            
            let playButton = UIButton(frame: CGRect(x: 0, y: 0, width: itemWidth * 0.5, height: itemWidth * 0.5))
            playButton.center = itemView.center
            playButton.setImage(UIImage(asset: Asset.Icons.Galeria.video), for: .normal)
            playButton.isUserInteractionEnabled = false
            playButton.isHidden = true
            itemView.addSubview(playButton)
            playButton.tag = 1002
            
            let errorButton = UIButton(frame: CGRect(x: 0, y: 0, width: itemWidth * 0.25, height: itemWidth * 0.25))
            errorButton.center = itemImageView.center
            errorButton.tag = 1004
            errorButton.setImage(UIImage(asset: Asset.Icons.cancel), for: .normal)
            itemView.addSubview(errorButton)
            errorButton.isHidden = true
            
           
            if ContentManager.sharedInstance.galleryMediaExists(contentId:  message.id, isGroup: true){
                setExistingItemGroup(idMessage: message.id)
            }
            else if UserDefaults.standard.bool(forKey: "manualDownload"){
                downloadButton.isHidden = false
                
                if message.metadataTipus.contains("AUDIO"){
                    buttonDownloadAudio.isHidden = false
                }
                
            }
            else{
                downloadButton.isHidden = true
                
                downloadMediaItemGroup(message: message)
            }
            
            downloadButton.addTargetClosure { (sender) in
                self.downloadMediaItemGroup(message: message)
                
            }
            
            buttonDownloadAudio.addTargetClosure { (sender) in
                self.downloadMediaItemGroup(message: message)
            }
            
            errorButton.addTargetClosure { (sender) in
                self.delegate?.tappedError()
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.recordingAudio{
            return
        }
        delegate?.tappedImage(imageView: (sender.view)! as! UIImageView)
    }
    
    @objc func tapVideo(sender: UITapGestureRecognizer){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.recordingAudio{
            return
        }
        
        guard let superv = sender.view?.superview else{
            return
        }
         var contentId = superv.tag
        if groupMessageId == nil{
            let documentDirectory = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURLVideo = documentDirectory.appendingPathComponent("gallery\(contentId).mp4")
            let fileURLThumb = documentDirectory.appendingPathComponent("thumb\(contentId).jpg")
            
            if !FileManager.default.fileExists(atPath: fileURLThumb.path) && FileManager.default.fileExists(atPath: fileURLVideo.path){
                delegate?.tappedError()
            }
            else{
                delegate?.tappedVideo(contentId: contentId, isGroup: false)
            }
        }
        else{
            contentId = sender.view!.tag

            let documentDirectory = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURLVideo = documentDirectory.appendingPathComponent("group_gallery\(contentId).mp4")
            let fileURLThumb = documentDirectory.appendingPathComponent("group_thumb\(contentId).jpg")
            
            if !FileManager.default.fileExists(atPath: fileURLThumb.path) && FileManager.default.fileExists(atPath: fileURLVideo.path){
                delegate?.tappedError()
            }
            else{
                delegate?.tappedVideo(contentId: contentId, isGroup: false)
            }
            
        }
        
    }
    
    
    func stopAudio(){
        var isPlaying = false
        if let player = AudioManager.sharedInstance.player{
            var id = -1
            if messageId != nil{
                id = messageId!
            }
            else if groupMessageId != nil{
                id = groupMessageId!
                
            }
            
            
            if AudioManager.sharedInstance.playingContent == id{
                isPlaying = true
            }
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.recordingAudio{
            return
        }
        
        var isPlaying = false
        if let player = AudioManager.sharedInstance.player{
            var id = -1
            if messageId != nil{
                id = self.messageId!
            }
            else if groupMessageId != nil{
                id = self.groupMessageId!
                
            }
            
            if AudioManager.sharedInstance.playingContent == id{
                isPlaying = true
            }
        }
        
        var fileURLAudio: URL?
        let documentDirectory = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        
        if messageId != nil{
            let chatModelManager = ChatModelManager()
            
            guard let message = chatModelManager.messageWith(id: messageId!) else{
                return
            }
            AudioManager.sharedInstance.playingContent = self.messageId!
            fileURLAudio = documentDirectory.appendingPathComponent("audio\(message.idAdjuntContents[0]).m4a")
        }
        else if groupMessageId != nil{
            let chatModelManager = ChatModelManager()
            
            guard let message = chatModelManager.groupMessageWith(id: groupMessageId!) else{
                return
            }
            
            AudioManager.sharedInstance.playingContent = self.groupMessageId!
            fileURLAudio = documentDirectory.appendingPathComponent("group_audio\(message.id).m4a")
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
        if messageId != nil{
            id = self.messageId!
        }
        else if groupMessageId != nil{
            id = self.groupMessageId!
            
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
        
        if messageId != nil{
            id = self.messageId!
        }
        else if groupMessageId != nil{
            id = self.groupMessageId!
            
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
        loadItemAt(page: Int(pageNumber))
    }
    
    func loadItemAt(page: Int){
        let chatModelManager = ChatModelManager()
        guard let messageId = messageId else{
            return
        }
        guard let message = chatModelManager.messageWith(id: messageId) else{
            return
        }
        
        
        if !ContentManager.sharedInstance.galleryMediaExists(contentId: message.idAdjuntContents[page], isGroup: false) && message.idAdjuntContents.count > page{
            downloadMediaItem(index: page, adjunt: message.idAdjuntContents[page])
        }
        
        
    }
    
    
}

