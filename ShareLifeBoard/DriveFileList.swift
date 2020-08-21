//
//  DriveFileList.swift
//  ShareLifeBoard
//
//  Created by 土師一哉 on 2020/08/10.
//  Copyright © 2020 土師一哉. All rights reserved.
//

import Foundation
import UIKit
import GoogleAPIClientForREST

extension ListTableViewController: FileCommonDelegate {
    
    func updateFileList() {
        debugPrint("updateFileList()->!!! num=\(shareFileList.count)")
        self.tableView.reloadData()
        
        self.fileCommon.SetThumbnailImage(self.shareFileList)
        
        debugPrint("<-updateFileList()")

    }
    
    func updateFileList(index: Int, image: UIImage) {
        debugPrint("appendFileList(index:info:)->")
        shareFileList[index].Thumbnail = image
        self.tableView.reloadData()
        debugPrint("<- appendFileList(index:info:)")
    }
    
    func appendFileList(_ info: ShareFileInfo) {
        debugPrint("appendFileList()->")
        shareFileList.append(info)
        debugPrint("<-appendFileList()")
    }
    
}
