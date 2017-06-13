/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import Foundation
import UIKit

class FileSaveHelper {
  
  // MARK:- Error Types
  private enum FileErrors:ErrorType {
    case JsonNotSerialized
    case FileNotSaved
    case ImageNotConvertedToData
    case FileNotRead
    case FileNotFound
  }
  
  // MARK:- File Extension Types
  enum FileExtension:String {
    case TXT = ".txt"
    case JPG = ".jpg"
    case JSON = ".json"
  }
  
  // MARK:- Private Properties
  private let directory:NSSearchPathDirectory
  private let directoryPath: String
  private let fileManager = NSFileManager.defaultManager()
  private let fileName:String
  private let filePath:String
  private let fullyQualifiedPath:String
  private let subDirectory:String
  
  // MARK:- Public Properties
  var fileExists:Bool {
    get {
      return fileManager.fileExistsAtPath(fullyQualifiedPath)
    }
  }
  
  var directoryExists:Bool {
    get {
      var isDir = ObjCBool(true)
      return fileManager.fileExistsAtPath(filePath, isDirectory: &isDir )
    }
  }
  
  // MARK:- Initializers
  convenience init(fileName:String, fileExtension:FileExtension){
    self.init(fileName:fileName, fileExtension:fileExtension, subDirectory:"", directory:.DocumentDirectory)
  }
  
  convenience init(fileName:String, fileExtension:FileExtension, subDirectory:String){
    self.init(fileName:fileName, fileExtension:fileExtension, subDirectory:subDirectory, directory:.DocumentDirectory)
  }
  
  init(fileName:String, fileExtension:FileExtension, subDirectory:String, directory:NSSearchPathDirectory){
    self.fileName = fileName + fileExtension.rawValue
    self.subDirectory = "/\(subDirectory)"
    self.directory = directory
    self.directoryPath = NSSearchPathForDirectoriesInDomains(directory, .UserDomainMask, true)[0]
    self.filePath = directoryPath + self.subDirectory
    self.fullyQualifiedPath = "\(filePath)/\(self.fileName)"
    createDirectory()
  }

  private func createDirectory(){
    if !directoryExists {
      do {
        try fileManager.createDirectoryAtPath(filePath, withIntermediateDirectories: false, attributes: nil)
      }
      catch {
        print("An Error was generated creating directory")
      }
    }
  }
  
  // MARK:- File saving methods
  func saveFile(string fileContents:String) throws{

    do {
      try fileContents.writeToFile(fullyQualifiedPath, atomically: true, encoding: NSUTF8StringEncoding)
    }
    catch  {
      throw error
    }
  }

  func saveFile(image image:UIImage) throws {
    guard let data = UIImageJPEGRepresentation(image, 1.0) else {
      throw FileErrors.ImageNotConvertedToData
    }
    if !fileManager.createFileAtPath(fullyQualifiedPath, contents: data, attributes: nil){
      throw FileErrors.FileNotSaved
    }
  }
  
  func saveFile(dataForJson dataForJson:AnyObject) throws{
    do {
    let jsonData = try convertObjectToData(dataForJson)
      if !fileManager.createFileAtPath(fullyQualifiedPath, contents: jsonData, attributes: nil){
        throw FileErrors.FileNotSaved
      }
    } catch {
      print(error)
      throw FileErrors.FileNotSaved
    }
    
  }
  
  func getContentsOfFile() throws -> String {
    guard fileExists else {
      throw FileErrors.FileNotFound
    }
    
    var returnString:String
    do {
       returnString = try String(contentsOfFile: fullyQualifiedPath, encoding: NSUTF8StringEncoding)
    } catch {
      throw FileErrors.FileNotRead
    }
    return returnString
  }
  
  func getImage() throws -> UIImage {
    guard fileExists else {
      throw FileErrors.FileNotFound
    }
    
    guard let image = UIImage(contentsOfFile: fullyQualifiedPath) else {
      throw FileErrors.FileNotRead
    }
    
    return image
    
  }
  
  func getJSONData() throws -> NSDictionary {
    guard fileExists else {
      throw FileErrors.FileNotFound
    }
    do {
      let data = try NSData(contentsOfFile: fullyQualifiedPath, options: NSDataReadingOptions.DataReadingMappedIfSafe)
      let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
      return jsonData
    } catch {
      throw FileErrors.FileNotRead
    }
    
  }

  // MARK:- Json Converting
  private func convertObjectToData(data:AnyObject) throws -> NSData {
    
    do {
      let newData = try NSJSONSerialization.dataWithJSONObject(data, options: .PrettyPrinted)
      return newData
    }
    catch {
      print("Error writing data: \(error)")
    }
    throw FileErrors.JsonNotSerialized
  }
  
  
}
