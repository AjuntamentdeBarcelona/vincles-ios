/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import MobileCoreServices
import AVKit
import AVFoundation
import SVProgressHUD



class MgVideoVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    enum State {
        case NoVideo,VideoReady,Sending,UploadFailed,SendingFailed,Success
    }
    
    
    @IBOutlet weak var redBtn: UIButton!
    @IBOutlet weak var grayBtn: UIButton!
    @IBOutlet weak var playVideoBtn: UIButton!
    
    let userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    var userVincle:UserVincle!
    
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    var imagePicker: UIImagePickerController! = UIImagePickerController()
    var isVideoPresent = false
    var isMsgSending = false
    var videoBinary:NSData?
    var savedFileURL: NSURL?
    
    var state:State!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        state = State.NoVideo
        
        if (userCercle.vincleSelected != nil) {
            userVincle = UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)
        }
        
        redBtn.addTarget(self, action: #selector(MgVideoVC.redBtnPress(_:)),
                         forControlEvents:.TouchUpInside)
        
        grayBtn.addTarget(self, action: #selector(MgVideoVC.grayBtnPress(_:)),
                          forControlEvents:.TouchUpInside)
        setUI()
        setupButtons()
    }
    
    func setUI() {
        redBtn.layer.cornerRadius = 4.0
        grayBtn.layer.cornerRadius = 4.0
        
        redBtn.backgroundColor = UIColor(hexString: HEX_RED_BTN)
        grayBtn.backgroundColor = UIColor(hexString: HEX_GRAY_BTN)
    }
    
    func setupButtons() {
        
        print ("SETUP AND STATE: ", state)
        switch state! {
        case .NoVideo:
            print("NO VIDEO")
            
            playVideoBtn.hidden = true
            
            redBtn.enabled = true
            redBtn.setTitle(langBundle.localizedStringForKey("BTN_RECORD_VIDEO_TITLE", value: nil, table: nil), forState: .Normal)
            redBtn.setImage(UIImage(named: "menu-missatges"), forState: .Normal)
            
            grayBtn.enabled = true
            grayBtn.setTitle(langBundle.localizedStringForKey("BTN_OPEN_GALLERY_TITLE", value: nil, table: nil), forState: .Normal)
            grayBtn.setImage(UIImage(named: "icon-attach-galeria"), forState: .Normal)
            
            
        case .VideoReady:
            print("VIDEO READY")

            playVideoBtn.hidden = true
            redBtn.enabled = false
            redBtn.setTitle(langBundle.localizedStringForKey("BTN_SEND_TITLE", value: nil, table: nil), forState: .Normal)
            redBtn.setTitle(langBundle.localizedStringForKey("BTN_PROCESSING_TITLE", value: nil, table: nil), forState: .Disabled)
            redBtn.setImage(UIImage(named: "icon-aceptar"), forState: .Normal)
            
            
            grayBtn.enabled = true
            grayBtn.setTitle(langBundle.localizedStringForKey("BTN_ERASE_TITLE", value: nil, table: nil), forState: .Normal)
            grayBtn.setImage(UIImage(named: "icon-cancelar"), forState: .Normal)
            
            
        case .Sending:
            print("SENDING")
            
            redBtn.alpha = 0.5
            redBtn.enabled = false
            redBtn.setTitle(langBundle.localizedStringForKey("BTN_SENDING_SEND_TITLE", value: nil, table: nil), forState: .Normal)
            
            grayBtn.enabled = false
            grayBtn.hidden = true
            grayBtn.setTitle(langBundle.localizedStringForKey("BTN_CANCEL_SEND_TITLE", value: nil, table: nil), forState: .Normal)
            grayBtn.setImage(UIImage(named: "icon-cancelar"), forState: .Normal)
            
        case .UploadFailed:
            print("UPLOAD FAILED RESEND!!!")
            playVideoBtn.hidden = false
            redBtn.enabled = true
            redBtn.alpha = 1
            redBtn.setTitle(langBundle.localizedStringForKey("BTN_RESEND_SEND_TITLE", value: nil, table: nil), forState: .Normal)
            redBtn.setImage(UIImage(named: "icon-aceptar"), forState: .Normal)
            
            grayBtn.enabled = true
            grayBtn.hidden = false
            grayBtn.setTitle(langBundle.localizedStringForKey("BTN_ERASE_TITLE", value: nil, table: nil), forState: .Normal)
            grayBtn.setImage(UIImage(named: "icon-cancelar"), forState: .Normal)
            
        case .SendingFailed:
            print("SENDING FAILED RESEND")
            redBtn.alpha = 1
            redBtn.enabled = true
            redBtn.setTitle(langBundle.localizedStringForKey("BTN_RESEND_SEND_TITLE", value: nil, table: nil), forState: .Normal)
            redBtn.setImage(UIImage(named: "icon-aceptar"), forState: .Normal)
            
            grayBtn.enabled = true
            grayBtn.hidden = false
            grayBtn.setTitle(langBundle.localizedStringForKey("BTN_ERASE_TITLE", value: nil, table: nil), forState: .Normal)
            grayBtn.setImage(UIImage(named: "icon-cancelar"), forState: .Normal)
            
        case .Success:
            print("SUCCESS ")
            SVProgressHUD.dismiss()
            performSegueWithIdentifier("msgVideo_missatgesFeed", sender: nil)
        }
    }
    
    func setupRedButton(){
        
            //Buttons enabled
            playVideoBtn.hidden = false
            playVideoBtn.enabled = true
        
            redBtn.enabled = true
            redBtn.setTitle(self.langBundle.localizedStringForKey("BTN_SEND_TITLE", value: nil, table: nil), forState: .Normal)
            redBtn.setImage(UIImage(named: "icon-aceptar"), forState: .Normal)
        
        
            grayBtn.enabled = true
            grayBtn.setTitle(langBundle.localizedStringForKey("BTN_ERASE_TITLE", value: nil, table: nil), forState: .Normal)
            grayBtn.setImage(UIImage(named: "icon-cancelar"), forState: .Normal)
        
    }
        
    func redBtnPress(sender: UIButton) {
        
        switch state! {
        case .NoVideo:
            
            if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
                if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                    
                    imagePicker.sourceType = .Camera
                    imagePicker.mediaTypes = [kUTTypeMovie as String]
                    imagePicker.allowsEditing = true
                    imagePicker.delegate = self
                    imagePicker.videoQuality = .TypeMedium
                    imagePicker.videoMaximumDuration = VIDEO_MAX_DURATION
                    
                    presentViewController(imagePicker, animated: true, completion: nil)
                } else {
                    postAlert("Rear camera doesn't exist", message: "Application cannot access the camera.")
                }
            } else {
                postAlert("Camera inaccessible", message: "Application cannot access the camera.")
            }
            
        case .VideoReady:
            print("VIDEO READY")
            state = State.Sending
            setupButtons()
            
            sendVideo(sender)
            
        case .Sending:
            print("SENDING")
            
        case .UploadFailed:
            print("UPLOAD FAILED RESEND!!!")
            
            sendVideo(sender)
            state = State.Sending
            setupButtons()
            
        case .SendingFailed:
            print("SENDING FAILED RESEND")
            
            sendVideo(sender)
            state = State.Sending
            setupButtons()
            
        case .Success:
            print("SUCCESS ")
        }
    }
    
    func grayBtnPress(sender: UIButton) {
        
        switch state! {
        case .NoVideo:
            print("NO VIDEO")
            
            startMediaBrowserFromViewController(self, usingDelegate: self)
            
        case .VideoReady:
            print("VIDEO READY")
            
            deleteVideo(sender)
            state = State.NoVideo
            setupButtons()
            
        case .Sending:
            print("SENDING")

            
        case .UploadFailed:
            print("UPLOAD FAILED RESEND!!!")
            
            state = State.NoVideo
            setupButtons()
            
        case .SendingFailed:
            print("SENDING FAILED RESEND")
            
            state = State.NoVideo
            setupButtons()
            
        case .Success:
            print("SUCCESS ")
            
        }
    }
    
    func sendVideo(sender: UIButton)
    {
        VinclesApiManager.sharedInstance.loginSelfUser(userCercle.username!, pwd: userCercle.password!, usrId: userCercle.id!);
        
        
        VinclesApiManager.sharedInstance.sendMessageWithBinary(videoBinary!, usrFrom: userCercle.id!, usrTo: userVincle.id!, mime: VIDEO_MIME_MP4, msgType: MESSAGE_TYPE_VIDEO, text: "",completion: { uploadResponse in
            
            switch uploadResponse {
            case "Upload failed":
                print(uploadResponse)
                
                self.state = State.UploadFailed
                self.setupButtons()
                
            case "Upload failed/No Wifi":
                print(uploadResponse)
                
                self.postAlert(self.langBundle.localizedStringForKey("ALERT_NO_WIFI_MESSAGE", value: nil, table: nil), message: self.langBundle.localizedStringForKey("ALERT_NO_WIFI_BODY", value: nil, table: nil))
                self.state = State.UploadFailed
                self.setupButtons()
                
            case "Upload completed":
                print(uploadResponse)
                
            case "Message Sent":
                print(uploadResponse)
                
                self.state = State.Success
                self.setupButtons()
                
            case "Error sending Message":
                print(uploadResponse)
                
                self.state = State.SendingFailed
                self.setupButtons()
                
            default:
                print(uploadResponse)
                
            }
        })
    }
    
    func startMediaBrowserFromViewController(viewController: UIViewController, usingDelegate delegate: protocol<UINavigationControllerDelegate, UIImagePickerControllerDelegate>) -> Bool {

        if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum) == false {
            return false
        }
        imagePicker.sourceType = .SavedPhotosAlbum
        imagePicker.mediaTypes = [kUTTypeMovie as NSString as String]
        imagePicker.allowsEditing = true
        imagePicker.delegate = delegate
        imagePicker.videoQuality = .TypeMedium
        imagePicker.videoMaximumDuration = VIDEO_MAX_DURATION
        presentViewController(imagePicker, animated: true, completion: nil)
        
        return true
    }
    
    
    // MARK: UIImagePickerControllerDelegate delegate methods
    // Finished recording a video
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        print("Got a video")
        
        //Buttons disabled temporally
        playVideoBtn.hidden = true
        playVideoBtn.enabled = false
        redBtn.enabled = false
        redBtn.setTitle(langBundle.localizedStringForKey("BTN_PROCESSING_TITLE", value: nil, table: nil), forState: .Disabled)
        
        if let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL) {
            
            self.savedFileURL = pickedVideo//NSURL(fileURLWithPath: dataPath)
            
            if imagePicker.sourceType == .Camera {
                // Save video to the main photo album
                let selectorToCall = #selector(MgVideoVC.videoWasSavedSuccessfully(_:didFinishSavingWithError:context:))
                UISaveVideoAtPathToSavedPhotosAlbum(pickedVideo.relativePath!, self, selectorToCall, nil)
            }
            
            self.exportVideo(AVFileTypeMPEG4, extensionKey: "mp4", completion: { (exported) in
                
                if exported
                {
                    let counter = NSByteCountFormatter.stringFromByteCount(Int64(self.videoBinary!.length), countStyle:NSByteCountFormatterCountStyle.File)
                    
                    print("\nVIDEO SIZE MB =  \(counter))")
                    print(self.savedFileURL?.absoluteString)
                    
                    dispatch_async(dispatch_get_main_queue()){
                        self.setupRedButton()
                        print("SETUPREDBUTTON2")
                    }
                }
            })
    
        }
        
        imagePicker.dismissViewControllerAnimated(true, completion: {
            self.state = State.VideoReady
            self.isVideoPresent = true
            self.view.autoresizesSubviews = false
            
            if self.state == State.VideoReady{
                //In VideoReady state we don't need to setupButtons
                print ("VideoReady state")
            }
            else{
                //Otherwise setup buttons
                self.setupButtons()
            }
            
        })
    }
    
    // Any tasks you want to perform after recording a video
    func videoWasSavedSuccessfully(video: String, didFinishSavingWithError error: NSError!, context: UnsafeMutablePointer<()>){
        print("Video saved")
        
        if let theError = error {
            print("An error happened while saving the video = \(theError)")
        } else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // What you want to happen
            })
        }
    }
    
    // Called when the user selects cancel
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("User canceled image")
        dismissViewControllerAnimated(true, completion: {
            // Anything you want to happen when the user selects cancel
        })
    }
    
    // Play the video recorded for the app
    @IBAction func playVideo(sender: AnyObject) {
        print("Play a video")
        
        let videoURL = NSURL(string: self.savedFileURL!.absoluteString!)
        let player = AVPlayer(URL: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        print(self.savedFileURL!.absoluteString)
        
        self.presentViewController(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    func deleteVideo(sender:UIButton) {
        
        videoBinary = nil
        isVideoPresent = false
        setupButtons()
    }
    
    // MARK: Utility methods for app
    // Utility method to display an alert to the user.
    func postAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ALERT_INTROCODE_CAMPS_ACTION", comment: "any comment"), style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "msgVideo_missatgesFeed" {
            
            SingletonVars.sharedInstance.initMenuHasToChange = true
            SingletonVars.sharedInstance.initDestination = .Mensajes
            
        }
    }
    
    
    func exportVideo(formatKey: String, extensionKey: String, completion:(exported:Bool) -> ())
    {
        let composition = AVMutableComposition()
        let asset = AVURLAsset(URL: self.savedFileURL!, options: nil)
        
        let track = asset.tracksWithMediaType(AVMediaTypeVideo)
        let videoTrack: AVAssetTrack = track[0] as AVAssetTrack
        let timerange = CMTimeRangeMake(kCMTimeZero, asset.duration)
        
        let compositionVideoTrack:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        
        do
        {
            try compositionVideoTrack.insertTimeRange(timerange, ofTrack: videoTrack, atTime: kCMTimeZero)
            compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        }
        catch
        {
            print(error)
        }
        
        let compositionAudioTrack:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        
        for audioTrack in asset.tracksWithMediaType(AVMediaTypeAudio)
        {
            do
            {
                try compositionAudioTrack.insertTimeRange(audioTrack.timeRange, ofTrack: audioTrack, atTime: kCMTimeZero)
            }
            catch
            {
                print(error)
            }
            
        }
        
        var size = videoTrack.naturalSize
        
        print("Video Track Natural Size: \(size)")
        
        if (orientationFromTransform(videoTrack.preferredTransform).isPortrait) {
            let temp = size.width
            size.width = size.height
            size.height = temp
        }
        
        
        let videolayer = CALayer()
        
        videolayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        print("Video Layer Frame: \(videolayer.frame)")
        
        let parentlayer = CALayer()
        parentlayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        parentlayer.addSublayer(videolayer)
        
        let layercomposition = AVMutableVideoComposition()
        layercomposition.frameDuration = CMTimeMake(1, 30)
        layercomposition.renderSize = size
        layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, inLayer: parentlayer)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration)
        let layerinstruction = videoCompositionInstructionForTrack(compositionVideoTrack, asset: asset)
        instruction.layerInstructions = [layerinstruction]
        layercomposition.instructions = [instruction]

        let fileNameString = String.init(format: "%@.%@", formatKey, extensionKey)
        let filePath = NSTemporaryDirectory() + self.fileNameToUse(fileNameString)
        let movieUrl = NSURL(fileURLWithPath: filePath)
        
        self.savedFileURL = movieUrl
        
        guard let assetExport = AVAssetExportSession(asset: composition, presetName:AVAssetExportPresetMediumQuality) else {return}
        
        
        print("Layer composition Reder Size: \(layercomposition.renderSize)")
        

        layercomposition.renderSize = size
        
        assetExport.videoComposition = layercomposition
        assetExport.outputFileType = formatKey
        assetExport.outputURL = movieUrl
        
        assetExport.exportAsynchronouslyWithCompletionHandler {
            
            var opSuccess: Bool = false
            
            switch assetExport.status
            {
            case AVAssetExportSessionStatus.Completed:
                print("exportVideo: success")
                
                dispatch_async(dispatch_get_main_queue()){
                    self.setupRedButton()
                    print("SETUPREDBUTTON1")
                }

                self.videoBinary = NSData(contentsOfURL: self.savedFileURL!)
                opSuccess = true
                break
            case AVAssetExportSessionStatus.Cancelled:
                print("exportVideo: cancelled")
                break
            case AVAssetExportSessionStatus.Exporting:
                print("exportVideo: exporting")
                break
            case AVAssetExportSessionStatus.Failed:
                print("exportVideo: failed -->  \(assetExport.error)")
                break
            case AVAssetExportSessionStatus.Unknown:
                print("exportVideo: unknown")
                break
            case AVAssetExportSessionStatus.Waiting:
                print("exportVideo: waiting")
                break
            }
    
            completion(exported: opSuccess)
    
        }
        
    }
    
    
    // MARK: Helpers
    
    // Method to obtain the final file name of the video to be exported
    func fileNameToUse(formatKey: String) -> String
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMddyyhhmmss"
        
        print(formatter.stringFromDate(NSDate()) + formatKey)
        
        return formatter.stringFromDate(NSDate()) + formatKey
    }
    
    
    // Upload Video
    func uploadMedia()
    {
        if self.savedFileURL == nil
        {
            print("\n\n**** VideoLocation is nil.\n")
            
            return
        }
        
        let url = NSURL(string: URL_UPLOAD_CONTENT)
        let request = NSMutableURLRequest(URL: url!)
        let boundary = self.generateBoundaryString()
        
        request.HTTPMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var movieData: NSData?
        
        do {
            movieData = try NSData(contentsOfFile: (self.savedFileURL?.relativePath)!, options: NSDataReadingOptions.DataReadingMappedAlways)
        } catch _ {
            movieData = nil
            return
        }
        
        let body = NSMutableData()
        
        // change file name
        let filename = "upload.mov"
        let mimetype = "video/mov"
        
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition:form-data; name=\"file\"; filename=\"\(filename)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Type: \(mimetype)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(movieData!)
        request.HTTPBody = body
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print(dataString)
        }
        
        task.resume()
    }
    
    // Generate Boundary, to be used by uploadMedia method
    func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().UUIDString)"
    }

    
    func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
        
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        
        let assetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0]
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform)
        
        if assetInfo.isPortrait {
            
            let scaleFactor = CGAffineTransformMakeScale(1, 1)
            instruction.setTransform(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor),
                                     atTime: kCMTimeZero)
        } else {
            
        }
        
        return instruction
    }
    
    func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
        var assetOrientation = UIImageOrientation.Up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .Right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .Left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .Up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .Down
        }
        return (assetOrientation, isPortrait)
    }

}

