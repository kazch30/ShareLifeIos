//
//  ShareFileInfo.swift
//  ShareLifeBoard
//
//  Created by 土師一哉 on 2020/08/09.
//  Copyright © 2020 土師一哉. All rights reserved.
//

import Foundation
import UIKit

struct ShareFileInfo {
    var fileId:String = ""
    var pngFileId:String = ""
    var modifiedTime:Date?
    var name:String = ""
    var iconLink:String = ""
    var ownedByMe:Bool = true
    var thumbnail:UIImage?
        
    var FileId:String {
        get {
            return fileId
        }
        set {
            fileId = newValue
        }
    }
    
    var PngFileId:String {
        get {
            return pngFileId
        }
        set {
            pngFileId = newValue
        }
    }
    
    var ModifiedTime:Date {
        get {
            return modifiedTime!
        }
        set {
            modifiedTime = newValue
        }
    }
    
    var ModifiedTimeFormat:String {
        get {
            //日付のフォーマットを指定する。
            let format = DateFormatter()
            format.dateFormat = "yyyy/MM/dd, E, kk:mm:ss"
                    
            //日付をStringに変換する
            let sDate = format.string(from: modifiedTime!)
            return sDate
        }
    }
    
    var Name:String {
        get {
            return name
        }
        set {
            name = newValue
        }
    }
    
    var IconLink:String {
        get {
            return iconLink
        }
        set {
            iconLink = newValue
        }
    }
    
    var OwnedByMe:Bool {
        get {
            return ownedByMe
        }
        set {
            ownedByMe = newValue
        }
    }
    
    var Thumbnail:UIImage {
        get {
            return thumbnail ?? UIImage()
        }
        set {
            thumbnail = newValue
        }
    }
    
}
