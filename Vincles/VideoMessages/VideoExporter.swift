/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import AVKit
import AVFoundation

class VideoExporter
{

    static let assetKeysRequiredToPlay = ["playable","hasProtectedContent"]

    var fileLocation: NSURL?
    var videoLocation: NSURL?
    
    func exportWithQuickTime() -> NSData
    {
        return self.exportWithText(AVFileTypeQuickTimeMovie, extensionKey: "mov")
    }
    
    func exportWithMPEG4() -> NSData
    {
        return self.exportWithText(AVFileTypeMPEG4, extensionKey: "mp4")
    }
    
    func exportWithM4V() -> NSData
    {
        return self.exportWithText(AVFileTypeAppleM4V, extensionKey: "m4v")
    }

    func exportWithText(formatKey: String, extensionKey: String) -> NSData
    {
        let composition = AVMutableComposition()
        let asset = AVURLAsset(URL: self.fileLocation!, options: nil)
        
        let track = asset.tracks
        let videoTrack:AVAssetTrack = track[0] as AVAssetTrack
        let timerange = CMTimeRangeMake(kCMTimeZero, asset.duration)
        
        let compositionVideoTrack:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        
        do {
            try compositionVideoTrack.insertTimeRange(timerange, ofTrack: videoTrack, atTime: kCMTimeZero)
            compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        } catch {
            print(error)
        }
        
        let compositionAudioTrack:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        
        for audioTrack in asset.tracksWithMediaType(AVMediaTypeAudio)
        {
            do {
                try compositionAudioTrack.insertTimeRange(audioTrack.timeRange, ofTrack: audioTrack, atTime: kCMTimeZero)
            } catch {
                print(error)
            }
            
        }
        
        let size = videoTrack.naturalSize
        
        
        let textLayer = CATextLayer()
        
        let formatString = asset.availableMediaCharacteristicsWithMediaSelectionOptions.description
        
        print("Available Formats: \n\(asset.availableMediaCharacteristicsWithMediaSelectionOptions.count)\n\(asset.availableMediaCharacteristicsWithMediaSelectionOptions.description)")
        
        let textString = String.init(format: "%@\n\n%@", formatKey, formatString)
        
        textLayer.string = textString
        textLayer.font = UIFont(name: "Helvetica", size: 35)
        textLayer.shadowOpacity = 0.5
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.frame = CGRect(x: 0, y:50, width: size.width, height: size.height / 6)
        
        let videolayer = CALayer()
        videolayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let parentlayer = CALayer()
        parentlayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        parentlayer.addSublayer(videolayer)
        parentlayer.addSublayer(textLayer)
        
        let layercomposition = AVMutableVideoComposition()
        layercomposition.frameDuration = CMTimeMake(1, 30)
        layercomposition.renderSize = size
        layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, inLayer: parentlayer)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration)
        let videotrack = composition.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack
        let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videotrack)
        instruction.layerInstructions = [layerinstruction]
        layercomposition.instructions = [instruction]
        
        let fileNameString = String.init(format: "%@.%@", formatKey, extensionKey)
        let filePath = NSTemporaryDirectory() + self.fileName(fileNameString)
        let movieUrl = NSURL(fileURLWithPath: filePath)
        
        self.videoLocation = movieUrl
        
        guard let assetExport = AVAssetExportSession(asset: composition, presetName:AVAssetExportPresetMediumQuality) else {return NSData()}
        assetExport.videoComposition = layercomposition
        assetExport.outputFileType = formatKey
        assetExport.outputURL = movieUrl
        
        assetExport.exportAsynchronouslyWithCompletionHandler {
            
            switch assetExport.status
            {
            case AVAssetExportSessionStatus.Completed:
                print("success")
                break
            case AVAssetExportSessionStatus.Cancelled:
                print("cancelled")
                break
            case AVAssetExportSessionStatus.Exporting:
                print("exporting")
                break
            case AVAssetExportSessionStatus.Failed:
                print("failed: \(assetExport.error)")
                break
            case AVAssetExportSessionStatus.Unknown:
                print("unknown")
                break
            case AVAssetExportSessionStatus.Waiting:
                print("waiting")
                break
            }
        }
        
        return NSData(contentsOfURL: self.videoLocation!)!
    }
    
    
    // MARK: Helpers
    func fileName(formatKey: String) -> String
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMddyyhhmmss"
        
        print(formatter.stringFromDate(NSDate()) + formatKey)
        
        return formatter.stringFromDate(NSDate()) + formatKey
    }
    
    
    // upload Video
    func uploadMedia()
    {
        if self.videoLocation == nil
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
            movieData = try NSData(contentsOfFile: (self.videoLocation?.relativePath)!, options: NSDataReadingOptions.DataReadingMappedAlways)
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
    
    func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
}
