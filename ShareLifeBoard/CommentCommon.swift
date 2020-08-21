//
//  CommentCommon.swift
//  ShareLifeBoard
//
//  Created by 土師一哉 on 2020/08/14.
//  Copyright © 2020 土師一哉. All rights reserved.
//

import Foundation
import UIKit
import GoogleAPIClientForREST


class CommentCommon: PermissionCommon {
    
    var commentList = [CommentInfo]()
    /// 次ページ取得用トークン
    private var nextPageToken: String?
    private var fid:String = ""
    
    func update() { }
    
    func GetCommentList(_ fileId: String) {
        debugPrint("GetCommentList()->")
        fid = fileId
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let serviceDrive = appDelegate.googleDriveServiceDrive
        let query = GTLRDriveQuery_CommentsList.query(withFileId: fid)
        query.pageSize = 100
        query.fields = "nextPageToken, comments(id, modifiedTime, author, content, resolved, replies(id, modifiedTime, author, content))"
        query.pageToken = nextPageToken
        query.executionParameters.shouldFetchNextPages = true
        nextPageToken = nil

        serviceDrive.executeQuery(query, delegate: self, didFinish: #selector(processCommentList(ticket:finishedWithObject:error:))
        )
        debugPrint("<-GetCommentList()")
    }
    
    @objc func processCommentList(ticket: GTLRServiceTicket, finishedWithObject response : GTLRDriveQuery_PermissionsList,error : NSError?) {
        debugPrint("processCommentList() ->")
        
        if let error = error {
            // エラーの場合、処理を終了します。
            // 必要に応じてエラー処理を行ってください。
            let str = error.localizedDescription
            debugPrint("<-processCommentList() error!!! : " + str)
            return
        }
        
        debugPrint("result=\(response)")
        
        if let jsonobj = response.json {

            let dic_objc = NSMutableDictionary(dictionary: jsonobj)
//            let dic = dic_objc as NSDictionary
            debugPrint("json= \(dic_objc)")
            let itemsArray: NSArray?   = dic_objc.object(forKey: "comments") as? NSArray
            nextPageToken = dic_objc.object(forKey: "nextPageToken") as? String
            
            if let itemsArray = itemsArray {

                var ids = [String]()
                var modifiedTimes = [String]()
                var displayNames = [String]()
                var mes = [Bool]()
                var photoLinks = [String]()
                var contents = [String]()
                var resolveds = [Bool]()

                if let _id = itemsArray.value(forKey: "id") as? Array<Array<String>> {
                    ids = _id[0]
                        
                } else if let _id = itemsArray.value(forKey: "id") as? Array<String> {
                    ids = _id
                }
                
                let authors: NSArray? = itemsArray.value(forKey: "author") as? NSArray
                
                if let _modifiedTimes = itemsArray.value(forKey: "modifiedTime") as? Array<Array<String>> {
                    modifiedTimes = _modifiedTimes[0]
                        
                } else if let _modifiedTimes = itemsArray.value(forKey: "modifiedTime") as? Array<String> {
                    modifiedTimes = _modifiedTimes
                }

                if let authors = authors {
                    if let _displayNames = authors.value(forKey: "displayName") as? Array<Array<String>> {
                        displayNames = _displayNames[0]
                            
                    } else if let _displayNames = authors.value(forKey: "displayName") as? Array<String> {
                        displayNames = _displayNames
                    }
                    
                    if let _mes = authors.value(forKey: "me") as? Array<Array<Bool>> {
                        mes = _mes[0]
                            
                    } else if let _mes = authors.value(forKey: "me") as? Array<Bool> {
                        mes = _mes
                    }
                    
                    if let _photoLinks = authors.value(forKey: "photoLink") as? Array<Array<String>> {
                        photoLinks = _photoLinks[0]
                            
                    } else if let _photoLinks = authors.value(forKey: "photoLink") as? Array<String> {
                        photoLinks = _photoLinks
                    }
                }

                if let _contents = itemsArray.value(forKey: "content") as? Array<Array<String>> {
                    contents = _contents[0]
                        
                } else if let _contents = itemsArray.value(forKey: "content") as? Array<String> {
                    contents = _contents
                }
                
                if let _resolveds = itemsArray.value(forKey: "resolved") as? Array<Array<Bool>> {
                    resolveds = _resolveds[0]
                        
                } else if let _resolveds = itemsArray.value(forKey: "resolved") as? Array<Bool> {
                    resolveds = _resolveds
                }

                let replies: NSArray? = itemsArray.value(forKey: "replies") as? NSArray

                var i = 0
                for _ in ids {
                    var info = CommentInfo()
                    if !ids.isEmpty {
                        debugPrint("id[\(i)] =" + ids[i])
                        info.CommentId = ids[i]
                        info.Id = ids[i]
                    }
                    if !modifiedTimes.isEmpty {
                        debugPrint("modifiedTime[\(i)] =" + modifiedTimes[i])
                        info.ModifiedTimeFormat = modifiedTimes[i]
                    }
                    if !displayNames.isEmpty {
                        debugPrint("displayName[\(i)] =" + displayNames[i])
                        info.Name = displayNames[i]
                    }
                    if !mes.isEmpty {
                        debugPrint("me[\(i)]=\(mes[i])")
                        info.IsMe = mes[i]
                    }
                    if !photoLinks.isEmpty {
                        debugPrint("photoLink[\(i)] =" + photoLinks[i])
                        info.PhotoLink = photoLinks[i]
                    }
                    if !contents.isEmpty {
                        debugPrint("content[\(i)] =" + contents[i])
                        info.Content = contents[i]
                    }
                    if !resolveds.isEmpty {
                        debugPrint("resolved[\(i)] =\(resolveds[i])")
                        info.IsResolved = resolveds[i]
                    }
                    commentList.append(info)

                    if let replies = replies {
                        var ids = [String]()
                        var displayNames = [String]()
                        var mes = [Bool]()
                        var photoLinks = [String]()
                        var modifiedTimes = [String]()
                        var contents = [String]()

                        if let _id = replies.value(forKey: "id") as? Array<Array<String>> {
                            ids = _id[0]
                                
                        } else if let _id = replies.value(forKey: "id") as? Array<String> {
                            ids = _id
                        }
                        let authors: NSArray? = replies.value(forKey: "author") as? NSArray
                        if let authors = authors {
                            if let _displayNames = authors.value(forKey: "displayName") as? Array<Array<String>> {
                                displayNames = _displayNames[0]

                            } else if let _displayNames = authors.value(forKey: "displayName") as? Array<String> {
                                displayNames = _displayNames
                            }
                            
                            if let _mes = authors.value(forKey: "me") as? Array<Array<Bool>> {
                                mes = _mes[0]
                            } else if let _mes = authors.value(forKey: "me") as? Array<Bool> {
                                mes = _mes
                            }
                            if let _photoLinks = authors.value(forKey: "photoLink") as? Array<Array<String>> {
                                photoLinks = _photoLinks[0]
                            } else if let _photoLinks = authors.value(forKey: "photoLink") as? Array<String> {
                                photoLinks = _photoLinks
                            }
                        }

                        if let _modifiedTimes = replies.value(forKey: "modifiedTime") as? Array<Array<String>> {
                            modifiedTimes = _modifiedTimes[0]
                                
                        } else if let _modifiedTimes = replies.value(forKey: "modifiedTime") as? Array<String> {
                            modifiedTimes = _modifiedTimes
                        }
                        
                        if let _contents = replies.value(forKey: "content") as? Array<Array<String>> {
                            contents = _contents[0]
                                
                        } else if let _contents = replies.value(forKey: "content") as? Array<String> {
                            contents = _contents
                        }

                        var n = 0
                        for _ in ids {
                            var replyinfo = CommentInfo()
                            
                            replyinfo.setReply()
                            
                            if !ids.isEmpty {
                                debugPrint("rep id[\(n)] =" + ids[n])
                                replyinfo.CommentId = info.CommentId
                                replyinfo.Id = ids[n]
                            }
                            if !displayNames.isEmpty {
                                debugPrint("rep displayName[\(n)] =" + displayNames[n])
                                replyinfo.Name = displayNames[n]
                            }
                            if !mes.isEmpty {
                                debugPrint("rep me[\(n)]=\(mes[n])")
                                replyinfo.IsMe = mes[n]
                            }
                            if !photoLinks.isEmpty {
                                debugPrint("rep photoLink[\(n)] =" + photoLinks[n])
                                replyinfo.PhotoLink = photoLinks[n]
                            }
                            if !modifiedTimes.isEmpty {
                                debugPrint("rep modifiedTime[\(n)] =" + modifiedTimes[n])
                                replyinfo.ModifiedTimeFormat = modifiedTimes[n]
                            }
                            if !contents.isEmpty {
                                debugPrint("rep content[\(n)] =" + contents[n])
                                replyinfo.Content = contents[n]
                            }
                            
                            commentList.append(replyinfo)

                            n+=1
                        }
                    }
                    
                    i+=1
                }
            }
            

        }
        
        // 次ページのトークンがある場合
        if let token = nextPageToken {
            // 次ページのファイル一覧を取得します。
            debugPrint("nextPageToken !!")
            nextPageToken = token
            GetCommentList(fid)
        }
        
        update()

        debugPrint("<- processCommentList()")
    }
    
    
    
}

class DateUtils {
    class func dateFromString(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }

    class func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
