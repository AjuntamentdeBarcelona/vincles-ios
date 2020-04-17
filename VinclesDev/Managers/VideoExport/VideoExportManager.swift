//
//  VideoExportManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import NextLevelSessionExporter
import Photos

class VideoExportManager {

    func exportVideo(url: URL, completionHandler: @escaping (_ result: Data?, _ error: String?) -> Void){
        
        let asset = AVAsset(url: url)
        let track = asset.tracks(withMediaType: AVMediaType.video).first!
        
        let size = track.naturalSize.applying(track.preferredTransform)
        let size2 = CGSize(width: fabs(size.width), height: fabs(size.height))

        var max = CGFloat(480)
        var width = CGFloat(0)
        var height = CGFloat(0)
        
        if size2.width >= size2.height{
            // LANDSCAPE
            let ratio = size2.height / size2.width
            
            // PORTRAIT
            if size2.width >= max{
                width = 480
            }
            else{
                width = size.width
            }
            
            height = width * ratio
        }
        else{
            let ratio = size2.width / size2.height
            
            // PORTRAIT
            if size2.height >= max{
                height = 480
            }
            else{
                height = size.height
            }
            
            width = height * ratio
        }
        
        let exporter = NextLevelSessionExporter(withAsset: asset)
        exporter.outputFileType = AVFileType.mp4
        let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(ProcessInfo().globallyUniqueString)
            .appendingPathExtension("mp4")
        exporter.outputURL = tmpURL
        
        let compressionDict: [String: Any] = [
            AVVideoAverageBitRateKey: NSNumber(integerLiteral: 300000),
            AVVideoProfileLevelKey: AVVideoProfileLevelH264MainAutoLevel as String,
        ]
        exporter.videoOutputConfiguration = [
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: NSNumber(integerLiteral: Int(width)),
            AVVideoHeightKey: NSNumber(integerLiteral: Int(height)),
            AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill,
            AVVideoCompressionPropertiesKey: compressionDict
        ]
        exporter.audioOutputConfiguration = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVEncoderBitRateKey: NSNumber(integerLiteral: 96000),
            AVNumberOfChannelsKey: NSNumber(integerLiteral: 2),
            AVSampleRateKey: NSNumber(value: Float(44100))
        ]
        
        do {
            try exporter.export(progressHandler: { (progress) in
                print(progress)
            }, completionHandler: { (status) in
                switch status {
                case .completed:
                    print("NextLevelSessionExporter, export completed, \(exporter.outputURL?.description ?? "")")
                    let videoData = try! Data(contentsOf: exporter.outputURL!)

                    completionHandler(videoData, nil) // return data & close

                    break
                case .cancelled:
                    print("NextLevelSessionExporter, export cancelled")
                    break
                case .failed:
                    completionHandler(nil, "error") // return data & close
                    break
                case .exporting:
                    fallthrough
                case .waiting:
                    fallthrough
                default:
                    print("NextLevelSessionExporter, did not complete")
                    break
                }
            })
        } catch {
            print("NextLevelSessionExporter, failed to export")
        }
        
        
    }
    
    private func saveVideo(withURL url: URL, completionHandler: @escaping (_ result: Data?, _ error: String?) -> Void){
        PHPhotoLibrary.shared().performChanges({
            let albumAssetCollection = self.albumAssetCollection(withTitle: "Next Level")
            if albumAssetCollection == nil {
                let changeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "Next Level")
                let _ = changeRequest.placeholderForCreatedAssetCollection
            }}, completionHandler: { (success1: Bool, error1: Error?) in
                if let albumAssetCollection = self.albumAssetCollection(withTitle: "Next Level") {
                    PHPhotoLibrary.shared().performChanges({
                        if let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url) {
                            let assetCollectionChangeRequest = PHAssetCollectionChangeRequest(for: albumAssetCollection)
                            let enumeration: NSArray = [assetChangeRequest.placeholderForCreatedAsset!]
                            assetCollectionChangeRequest?.addAssets(enumeration)
                        }
                    }, completionHandler: { (success2: Bool, error2: Error?) in
                        if success2 == true {
                            // prompt that the video has been saved
                            let alertController = UIAlertController(title: "Video Saved!", message: "Saved to the camera roll.", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                         //    self.present(alertController, animated: true, completion: nil)
                            let data = Data()
                            completionHandler(data, nil) // return data & close
                        } else {
                            // prompt that the video has been saved
                            let alertController = UIAlertController(title: "Something failed!", message: "Something failed!", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            completionHandler(nil, "Error") // return data & close
                        }
                    })
                }
        })
    }
    
    private func albumAssetCollection(withTitle title: String) -> PHAssetCollection? {
        let predicate = NSPredicate(format: "localizedTitle = %@", title)
        let options = PHFetchOptions()
        options.predicate = predicate
        let result = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
        if result.count > 0 {
            return result.firstObject
        }
        return nil
    }
}
