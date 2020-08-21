//
//  CommentInfo.swift
//  ShareLifeBoard
//
//  Created by 土師一哉 on 2020/08/15.
//  Copyright © 2020 土師一哉. All rights reserved.
//

import Foundation

struct CommentInfo {
    private var commentId:String = ""
    private var id:String = ""
    private var modifiedTime:Date?
    private var name:String = ""
    private var isMe:Bool = false
    private var photoLink:String = ""
    private var content:String = ""
    private var isReply:Bool = false
    private var isResolved:Bool = false
    
    var CommentId:String {
        get {
            return commentId
        }
        set {
            commentId = newValue
        }
    }
    
    var Id:String {
        get {
            return id
        }
        set {
            id = newValue
        }
    }
 /*
    var ModifiedTime:Date {
        get {
            return modifiedTime
        }
    }
 */
    var ModifiedTimeFormat:String {
        get {
            //日付のフォーマットを指定する。
            let format = DateFormatter()
            format.dateFormat = "yyyy/MM/dd, E, kk:mm:ss"
                    
            //日付をStringに変換する
            let sDate = format.string(from: modifiedTime!)
            return sDate
        }
        set {
            let formatter: DateFormatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let date = formatter.date(from: newValue) {
                self.modifiedTime = date
            }

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
    
    var IsMe:Bool {
        get {
            return isMe
        }
        set {
            isMe = newValue
        }
    }
    
    var PhotoLink:String {
        get {
            return photoLink
        }
        set {
            photoLink = newValue
        }
    }
    
    var Content:String {
        get {
            return content
        }
        set {
            content = newValue
        }
    }
    
    var IsReply:Bool {
        get {
            return isReply
        }
    }
    mutating func setReply() {
        self.isReply = true
    }
    
    var IsResolved:Bool {
        get {
            return isResolved
        }
        set {
            isResolved = newValue
        }
    }
}
