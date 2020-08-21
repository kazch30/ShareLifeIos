//
//  PermissionCommon.swift
//  ShareLifeBoard
//
//  Created by 土師一哉 on 2020/08/12.
//  Copyright © 2020 土師一哉. All rights reserved.
//

import Foundation
import UIKit
import GoogleAPIClientForREST
/*import ObjectMapper

class Result: Mappable {
    var id: String?
    var type: String?
    var emailAddress: String?
    var role: String?
    var displayName: String?
    var photoLink: String?
    var deleted: String?

    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        type <- map["type"]
        emailAddress <- map["emailAddress"]
        role <- map["role"]
        displayName <- map["displayName"]
        photoLink <- map["photoLink"]
        deleted <- map["deleted"]
    }
}


class JSONObj: Mappable {
    var status:String?
    var results:Array<Result>?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        status <- map["status"]
        results <- map["results"]
    }
}
*/

class PermissionCommon: FileCommon {
    
    var permissionList = [PermissionInfo]()
    /// 次ページ取得用トークン
    private var nextPageToken: String?
    private var fid:String = ""

    
    func PermissionsGet(_ fileId: String) {
        debugPrint("PermissionsGet()->")
        
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let serviceDrive = appDelegate.googleDriveServiceDrive
//        let query = GTLRDriveQuery_PermissionsGet.query(withFileId: <#T##String#>, permissionId: <#T##String#>)
        
    }
    
    
    func GetPermissionList(_ fileId: String) {
        debugPrint("GetPermissionList()->")
        fid = fileId

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let serviceDrive = appDelegate.googleDriveServiceDrive
        let query = GTLRDriveQuery_PermissionsList.query(withFileId: fid)
        query.pageSize = 100
        query.fields = "nextPageToken, permissions(id, type, emailAddress, role, displayName, photoLink, deleted)"
        query.pageToken = nextPageToken
        query.executionParameters.shouldFetchNextPages = true
        nextPageToken = nil

        serviceDrive.executeQuery(query, delegate: self, didFinish: #selector(processPermissionList(ticket:finishedWithObject:error:))
        )
        debugPrint("<-GetPermissionList()")
    }
    
    @objc func processPermissionList(ticket: GTLRServiceTicket, finishedWithObject response : GTLRDriveQuery_PermissionsList,error : NSError?) {
        debugPrint("processPermissionList() ->")
        
        if let error = error {
            // エラーの場合、処理を終了します。
            // 必要に応じてエラー処理を行ってください。
            let str = error.localizedDescription
            debugPrint("<-processPermissionList() error!!! : " + str)
            return
        }
        
        debugPrint("result=\(response)")
        if let jsonobj = response.json {

            let dic_objc = NSMutableDictionary(dictionary: jsonobj)
            let dic = dic_objc as NSDictionary
            debugPrint("json= \(dic)")
            let itemsArray: NSArray?   = dic.object(forKey: "permissions") as? NSArray
            nextPageToken = dic.object(forKey: "nextPageToken") as? String
            
            if let itemsArray = itemsArray {

                let ids = itemsArray.value(forKey: "id") as! [String]
                let types = itemsArray.value(forKey: "type") as! [String]
                let emailAddresss = itemsArray.value(forKey: "emailAddress") as! [String]
                let roles = itemsArray.value(forKey: "role") as! [String]
                let displayNames = itemsArray.value(forKey: "displayName") as! [String]
                let photoLinks = itemsArray.value(forKey: "photoLink") as! [String]
                let deleteds = itemsArray.value(forKey: "deleted") as! [Bool]

            
                var i = 0
                for _ in itemsArray {
                    var info = PermissionInfo()

                    debugPrint("id[\(i)] =" + ids[i])
                    debugPrint("type[\(i)] =" + types[i])
                    debugPrint("emailAddress[\(i)] =" + emailAddresss[i])
                    debugPrint("role[\(i)] =" + roles[i])
                    debugPrint("displayName[\(i)] =" + displayNames[i])
                    debugPrint("photoLink[\(i)] =" + photoLinks[i])
                    debugPrint("deleted[\(i)] = \(deleteds[i])")

//                    if ((deleteds == nil || !deleteds[i]) && types[i] != "anyone") {
                    if (!deleteds[i] && types[i] != "anyone") {
                        info.PermissionId = ids[i]
                        info.UserType = types[i]
                        info.Address = emailAddresss[i]
                        info.Role = roles[i]
                        info.Name = displayNames[i]
                        info.PhotoLink = photoLinks[i]
                        
                        permissionList.append(info)
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
            GetPermissionList(fid)
        }

        
        debugPrint("<-processPermissionList()")
    }

}
