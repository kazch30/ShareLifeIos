//
//  PermissionInfo.swift
//  ShareLifeBoard
//
//  Created by 土師一哉 on 2020/08/13.
//  Copyright © 2020 土師一哉. All rights reserved.
//

import Foundation

struct PermissionInfo {
    
    var permissionId:String = ""
    var type:String = ""
    var address:String = ""
    var name:String = ""
    var role:String = ""
    var photoLink:String = ""
    
    var PermissionId:String {
        get {
            return permissionId
        }
        set {
            permissionId = newValue
        }
    }
    
    var UserType:String {
        get {
            return type
        }
        set {
            type = newValue
        }
    }
    
    var Address:String {
        get {
            return address
        }
        set {
            address = newValue
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

    var Role:String {
        get {
            return role
        }
        set {
            role = newValue
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


}
