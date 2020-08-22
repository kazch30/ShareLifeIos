//
//  FileCommon.swift
//  ShareLifeBoard
//
//  Created by 土師一哉 on 2020/08/11.
//  Copyright © 2020 土師一哉. All rights reserved.
//

import Foundation
import UIKit
import GoogleAPIClientForREST
import ZIPFoundation

public let THUMBNAIL_FOLDER_NAME = "thumbnail"
public let TEMP_FOLDER_NAME = "work"
public let CACHES_FOLDER_NAME = "Library/Caches"
public let SOURCE_FILE_NAME = "sharelife.zip"
public let APP_NAME = "Share Life"
public let OWNED_BY_OTHER = "owned by other"
public let THUMBNAIL_WIDTH = 44

protocol FileCommonDelegate {

    func updateFileList()
    func updateFileList(index: Int, image: UIImage)
    func appendFileList(_ info: ShareFileInfo)
}

extension FileCommonDelegate {

    // デフォルト実装
    // プロトコル適合先で実装しなくてもエラーにならなくなる
    func updateFileList() {
        debugPrint("updateFileList() default call.")
    }
    func appendFileList(_ info: ShareFileInfo) {
        debugPrint("appendFileList() default call.")
    }
}

class FileCommon: UIViewController {

    /// 次ページ取得用トークン
    private var nextPageToken: String?
    /// 「Share Life」フォルダID
    var ShareLifeDirId: String?
    var delegate: FileCommonDelegate?  // 処理を任せる相手を保持する
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var index = 0
    var fileId: String = ""
    var pngFileId: String = ""
    var imgName: String = ""
    
    // リソース数を指定してセマフォキューを作成
//    let semaphoreQueue = DispatchSemaphore(value: 100)
    let semaphoreQueue = DispatchSemaphore(value:0)

    func LoardImgFile(_ source: URL) {
        debugPrint("LoardImgFile() default call.")
    }
    
    func readimage(_ source: URL) -> UIImage?  {
        debugPrint("readimage()->")
        debugPrint("fileURL=" + source.path)
        
        debugPrint("<-readimage()")
        return UIImage(contentsOfFile: source.path)
    }
    
    private func deleteFile(_ path: String) {
        debugPrint("deleteFile()-> path=" + path)
        let fileManager = FileManager()
        
        if fileManager.fileExists(atPath: path) {

            do {
                try fileManager.removeItem(atPath: path)
            } catch {
                debugPrint("removeItem() failed with error:\(error)")
            }
        }
        debugPrint("<-deleteFile()")

    }
    
    private func saveThumbnail(data:Data?) {
        debugPrint("saveThumbnail()->")
        let homeDirectory = NSHomeDirectory()

        let fileManager = FileManager()
        
        let fileName = self.fileId + ".png"
        var destinationURL = URL(fileURLWithPath: homeDirectory)
        destinationURL.appendPathComponent(CACHES_FOLDER_NAME)
        destinationURL.appendPathComponent(fileName)
        debugPrint("destinationURL=" + destinationURL.path)
        
        if !fileManager.fileExists(atPath: destinationURL.path) {
            if let data = data {
                fileManager.createFile(atPath: destinationURL.path, contents: data, attributes: nil)
            }
        }
        debugPrint("<-saveThumbnail()")
    }
    
    private func loardThumbnail(id:String) -> UIImage? {
        debugPrint("loardThumbnail()->")
        let homeDirectory = NSHomeDirectory()
        var image:UIImage?

        let fileManager = FileManager()
        
        let fileName = id + ".png"
        var sourceURL = URL(fileURLWithPath: homeDirectory)
        sourceURL.appendPathComponent(CACHES_FOLDER_NAME)
        sourceURL.appendPathComponent(fileName)
        debugPrint("destinationURL=" + sourceURL.path)
        let size = CGSize(width: THUMBNAIL_WIDTH, height: THUMBNAIL_WIDTH)
        if let data:Data = fileManager.contents(atPath: sourceURL.path) {
            image = data.toImage()
            if let image = image?.resize(size: size) {
                return image
            }
        }

        debugPrint("<-loardThumbnail()")
        return image
    }
    
    private func deleteThumbnail(id:String) {
        debugPrint("deleteThumbnail()->")
        let homeDirectory = NSHomeDirectory()

        let fileManager = FileManager()
        
        let fileName = id + ".png"
        var destinationURL = URL(fileURLWithPath: homeDirectory)
        destinationURL.appendPathComponent(CACHES_FOLDER_NAME)
        destinationURL.appendPathComponent(fileName)
        debugPrint("destinationURL=" + destinationURL.path)
        
        if fileManager.fileExists(atPath: destinationURL.path) {
            do {
                try fileManager.removeItem(atPath: destinationURL.path)
            } catch {
                debugPrint("removeItem() failed with error:\(error)")
            }
        }
        debugPrint("<-deleteThumbnail()")

    }
    
   /**
    ディレクトリか判定します。

    - Parameter file: ファイルオブジェクト
    - Returns: true:ディレクトリ / false:ファイル
    */
    private func isDir(_ file: GTLRDrive_File) -> Bool {
        var result = false
        if let mimeType = file.mimeType {
            let mimeTypes = mimeType.components(separatedBy: ".")
            let lastIndex = mimeTypes.count - 1
            let type = mimeTypes[lastIndex]
            if type == "folder" {
                result = true
            }
        }
        return result
    }

   /**
    削除済みか判定します。

    - Parameter file: ファイルオブジェクト
    - Returns: true:削除済み / false:削除されていない
    */
    private func isTrashed(_ file: GTLRDrive_File) -> Bool {
        if let trashed = file.trashed, trashed == 1 {
            return true
        }
        return false
    
    }

    func getFolderId() {
        debugPrint("getFolderId()->")
        debugPrint("Current thread \(Thread.current)")
        let query = GTLRDriveQuery_FilesList.query()

        // 2．クエリオブジェクトに検索条件を設定します。
        query.pageSize = 100
        query.fields = "nextPageToken, files(id, name, mimeType, parents)"
        query.q = "trashed = false and name contains '" + APP_NAME + "' and mimeType='application/vnd.google-apps.folder'"
        query.orderBy = "folder,name"
        query.pageToken = nextPageToken
        nextPageToken = nil

        // 2-6. クエリを実行した結果を処理するコールバックメソッドを登録します。
        let selector = #selector(GetFolderResultWithTicket(_:finishedWithObject:error:))
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let serviceDrive = appDelegate.googleDriveServiceDrive
        
        // 3. クエリを実行します。
        DispatchQueue.global().async {
            serviceDrive.executeQuery(query, delegate: self, didFinish: selector)
        }

        debugPrint("<-getFolderId()")
    }

     /**
     4. GoogleDriveフォルダ情報を取得します。

     - Parameter ticket: チケット
     - Parameter response: レスポンス
     - Parameter error: エラー情報
     */
    @objc func GetFolderResultWithTicket(_ ticket: GTLRServiceTicket, finishedWithObject response: GTLRDrive_FileList, error: Error?) {
        debugPrint("GetFolderResultWithTicket() ->")
        debugPrint("Current thread \(Thread.current)")
        if let error = error {
            // エラーの場合、処理を終了します。
            // 必要に応じてエラー処理を行ってください。
            let str = error.localizedDescription
            debugPrint("<-GetFolderResultWithTicket() error!!! : " + str)
            return
        }

        // 今回取得した分のファイルリストを取得します。
        var tempDriveFileList = [GTLRDrive_File]()
        if let driveFiles = response.files, !driveFiles.isEmpty {
            tempDriveFileList = driveFiles
        }

        // 全ファイル情報分繰り返します。
        for driveFile in tempDriveFileList {
            // 名称を取得します。
            guard let name = driveFile.name else {
                // 名称が取得できない場合、次のファイルを処理します。
                continue
            }

            debugPrint("name=" + name)
            if name != APP_NAME {
                continue
            }
            // IDを取得します。
            guard let id = driveFile.identifier else {
                // IDが取得できない場合、次のファイルを処理します。
                continue;
            }
            
            debugPrint("id=" + id)

            // 削除済みか判定します。
            let isTrashed = self.isTrashed(driveFile)
            if isTrashed {
                // 削除済みの場合、次のファイルを処理します。
                continue
            }

            if self.isDir(driveFile) {
                // ディレクトリの場合
                ShareLifeDirId = id
                debugPrint("ShareLifeDirId = " + ShareLifeDirId!)
                
                // [Share Life]フォルダ情報を取得します。
                self.getFileInfoList()
            }
        }

        debugPrint("<-GetFolderResultWithTicket()")
    }

        
        
    /**
     GoogleDrive APIで、「Share Life」ファイル情報リストを取得します。
     */
    func getFileInfoList() {
        debugPrint("getFileInfoList()->")
        debugPrint("Current thread \(Thread.current)")

        // 1.　クエリオブジェクトを取得します。
        let query = GTLRDriveQuery_FilesList.query()

        // 2．クエリオブジェクトに検索条件を設定します。

        // 2-1. 1回の検索で取得する件数を指定します。
        //    ドキュメントには1000件まで指定できるとあります。
        //    しかし実際1000に指定して実行しても、1回で1000件は取得できませんでした。
        //    そのためデフォルトの100を指定して、何回かに分けて取得するようにしました。
        query.pageSize = 100
        
        // 2-2. 検索で取得する項目を指定します。
        
//            query.fields = "nextPageToken, files(id, name, size, mimeType, fileExtension, createdTime, modifiedTime, starred, trashed, iconLink, parents, properties, permissions)"
        query.fields = "nextPageToken, files(id, name, modifiedTime, iconLink, ownedByMe)"
        
        // 2-3. 検索するディレクトリのIDを指定します。
        // ルートディレクトリの場合は"root"を指定してください。
        // サブディレクトリの場合は、ファイル一覧取得処理で取得したディレクトリのIDを指定してください。
        // ディレクトリのIDは後述の"driveFile.identifier"で取得できます。
        //query.q = "'\(id)' in parents"
        // (5-1) ルートディレクトリ直下のファイル/フォルダを取得対象にする (ルートディレクトリ以外を指定する場合は、rootではなく対象ディレクトリのIDを指定する)
//            query.q = "'root' in parents"
//        query.q = "'\(id)' in parents"
//            query.q = "'1epMDeTKm8nLwxvlDSFa3ElBshkmQL37y' in parents"
        query.q = "trashed = false and name contains '" + APP_NAME + "' and mimeType='application/vnd.google-apps.document'"

        // 2-4．取得順を指定します。
        query.orderBy = "modifiedTime"
        
        // 2-5. 次ページのトークンをセットします。
        //    nextPageTokenがnilならば、無視されます。
        query.pageToken = nextPageToken
        query.executionParameters.shouldFetchNextPages = true
        nextPageToken = nil

        // 2-6. クエリを実行した結果を処理するコールバックメソッドを登録します。
        let selector = #selector(displayResultWithTicket(_:finishedWithObject:error:))
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let serviceDrive = appDelegate.googleDriveServiceDrive
        
        // 3. クエリを実行します。
        DispatchQueue.global().async {
            serviceDrive.executeQuery(query, delegate: self, didFinish: selector)
        }

        debugPrint("<-getFileInfoList()")
    }

    /**
     4. GoogleDriveファイルの取得結果を表示します。

     - Parameter ticket: チケット
     - Parameter response: レスポンス
     - Parameter error: エラー情報
     */
    @objc func displayResultWithTicket(_ ticket: GTLRServiceTicket, finishedWithObject response: GTLRDrive_FileList, error: Error?) {
        debugPrint("displayResultWithTicket() ->")
        debugPrint("Current thread \(Thread.current)")
        if let error = error {
            // エラーの場合、処理を終了します。
            // 必要に応じてエラー処理を行ってください。
            let str = error.localizedDescription
            debugPrint("<-displayResultWithTicket() error!!! : " + str)
            return
        }

        // GoogleDriveファイルリストを更新します。
        // 今回取得した分のファイルリストを取得します。
        var tempDriveFileList = [GTLRDrive_File]()
        if let driveFiles = response.files, !driveFiles.isEmpty {
            tempDriveFileList = driveFiles
        }

        // 全ファイル情報分繰り返します。
        for driveFile in tempDriveFileList {
            // 名称を取得します。
            guard var name = driveFile.name else {
                // 名称が取得できない場合、次のファイルを処理します。
                continue
            }

            // IDを取得します。
            guard let id = driveFile.identifier else {
                // IDが取得できない場合、次のファイルを処理します。
                continue;
            }
            
            // 削除済みか判定します。
            let isTrashed = self.isTrashed(driveFile)
            if isTrashed {
                // 削除済みの場合、次のファイルを処理します。
                continue
            }

            var info = ShareFileInfo()

            debugPrint("id=" + id)
            info.FileId = id
            
            if let i = name.firstIndex(of: "-") {
                info.PngFileId = String(name[name.index(i, offsetBy: 1)...])
                name = String(name[..<i])
                debugPrint("PngFileId=" + info.PngFileId)

            }
            
            if let ownedByMe = driveFile.ownedByMe {
                info.OwnedByMe = ownedByMe.boolValue
                debugPrint("ownedByMe= \(info.OwnedByMe)")
                if !info.OwnedByMe {
                    name = name + " ( " + OWNED_BY_OTHER + " )"
                }
            }
            
            info.Name = name
            debugPrint("Name=" + info.Name)

            if let link = driveFile.iconLink {
                info.iconLink = link
                debugPrint("iconLink =" + info.iconLink)
            }
            
            if let time = driveFile.modifiedTime {
                info.ModifiedTime = time.date
                debugPrint("ModifiedTime =" + info.ModifiedTimeFormat)
            }

            // キャッシュファイルのチェックとサムネイル設定
            if let image = loardThumbnail(id:info.FileId) {
                info.Thumbnail = image
            }
            
            //shareFileList.append(info)
            if let delegate = delegate {
                delegate.appendFileList(info)
            }
            
        }

        // 次ページのトークンがある場合
        if let token = response.nextPageToken {
            // 次ページのファイル一覧を取得します。
            debugPrint("nextPageToken !!")
            nextPageToken = token
            getFileInfoList()
        }
        
        if let delegate = delegate {
            delegate.updateFileList()
        }

        debugPrint("<-displayResultWithTicket()")

    }

    func getFileData(_ fileId: String) {
        debugPrint("getFileData()->")
        
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let serviceDrive = self.appDelegate.googleDriveServiceDrive
        let query = GTLRDriveQuery_FilesExport.queryForMedia(withFileId: fileId, mimeType: "application/zip")
        
        serviceDrive.executeQuery(query,
                                  delegate: self,
                                  didFinish: #selector(processDownloadedzip(ticket:finishedWithObject:error:))
        )
        
        
        debugPrint("<-getFileData()")
    }
    
    @objc func processDownloadedzip(ticket: GTLRServiceTicket, finishedWithObject file: GTLRDataObject, error : NSError?) {
        debugPrint("processDownloadedzip() ->")
        debugPrint("Current thread \(Thread.current)")

        if let error = error {
            let str = error.localizedDescription
            debugPrint("<-processDownloadedzip() error!!! : " + str)
            return
        }

        let tmpDirectory = NSTemporaryDirectory()

        let fileManager = FileManager()
        var sourceURL = URL(fileURLWithPath: tmpDirectory)
        sourceURL.appendPathComponent(THUMBNAIL_FOLDER_NAME)
        sourceURL.appendPathComponent(SOURCE_FILE_NAME)
        var destinationURL = URL(fileURLWithPath: tmpDirectory)
        destinationURL.appendPathComponent(THUMBNAIL_FOLDER_NAME)
        debugPrint("destinationURL=" + destinationURL.path)

        deleteFile(destinationURL.path)

        do {
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            fileManager.createFile(atPath: sourceURL.path, contents: file.data, attributes: nil)
            try fileManager.unzipItem(at: sourceURL, to: destinationURL)
        } catch {
            debugPrint("Extraction of ZIP archive failed with error:\(error)")
            return
        }
        
        guard let fileNames = try? FileManager.default.contentsOfDirectory(atPath: destinationURL.path) else {
            return
        }
        
        var imageFolder = ""
        
        for file in fileNames {
            debugPrint("dir = " + file)
            guard file.firstIndex(of: ".") != nil else {
                imageFolder = file
                break
            }
        }

        if !imageFolder.isEmpty {
            destinationURL.appendPathComponent(imageFolder)

            guard let fileNames = try? FileManager.default.contentsOfDirectory(atPath: destinationURL.path) else {
                return
            }
            for file in fileNames {
                debugPrint("file = " + file)

                if let i = file.firstIndex(of: ".") {
                    let ext = String(file[file.index(i, offsetBy: 1)...])
                    if (ext == "png") {
                        destinationURL.appendPathComponent(file)
                        LoardImgFile(destinationURL)
                        break
                    }
                }
            }

        }
                
        debugPrint("<-processDownloadedzip()")
    }
    
    func getFileDataForThumbnail(_ fileId: String) {
        debugPrint("getFileDataForThumbnail()->")
        
        let serviceDrive = self.appDelegate.googleDriveServiceDrive
        let query = GTLRDriveQuery_FilesExport.queryForMedia(withFileId: fileId, mimeType: "application/zip")
        
        serviceDrive.executeQuery(query,
                                  delegate: self,
                                  didFinish: #selector(DownloadedzipForThumbnail(ticket:finishedWithObject:error:))
        )
        
        
        debugPrint("<-getFileDataForThumbnail()")
    }

    @objc func DownloadedzipForThumbnail(ticket: GTLRServiceTicket, finishedWithObject file: GTLRDataObject, error : NSError?) {
        debugPrint("DownloadedzipForThumbnail() ->")
        debugPrint("Current thread \(Thread.current)")

        if let error = error {
            let str = error.localizedDescription
            debugPrint("<-DownloadedzipForThumbnail() error!!! : " + str)
            semaphoreQueue.signal()
            return
        }

        let tmpDirectory = NSTemporaryDirectory()

        let fileManager = FileManager()
        var sourceURL = URL(fileURLWithPath: tmpDirectory)
        sourceURL.appendPathComponent(TEMP_FOLDER_NAME)
        sourceURL.appendPathComponent(SOURCE_FILE_NAME)
        var destinationURL = URL(fileURLWithPath: tmpDirectory)
        destinationURL.appendPathComponent(TEMP_FOLDER_NAME)
        debugPrint("destinationURL=" + destinationURL.path)

        deleteFile(destinationURL.path)

        do {
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            fileManager.createFile(atPath: sourceURL.path, contents: file.data, attributes: nil)
            try fileManager.unzipItem(at: sourceURL, to: destinationURL)
        } catch {
            debugPrint("Extraction of ZIP archive failed with error:\(error)")
            semaphoreQueue.signal()
            return
        }
        
        guard let fileNames = try? FileManager.default.contentsOfDirectory(atPath: destinationURL.path) else {
            semaphoreQueue.signal()
            return
        }
        
        var imageFolder = ""
        
        for file in fileNames {
            debugPrint("dir = " + file)
            guard file.firstIndex(of: ".") != nil else {
                imageFolder = file
                break
            }
        }
        
        var pngURL = destinationURL

        if !imageFolder.isEmpty {
            pngURL.appendPathComponent(imageFolder)

            guard let fileNames = try? FileManager.default.contentsOfDirectory(atPath: pngURL.path) else {
                semaphoreQueue.signal()
                return
            }
            for file in fileNames {
                debugPrint("file = " + file)

                if let i = file.firstIndex(of: ".") {
                    let ext = String(file[file.index(i, offsetBy: 1)...])
                    if (ext == "png") {
                        pngURL.appendPathComponent(file)
                        if let data:Data = fileManager.contents(atPath: pngURL.path) {
                            let size = CGSize(width: THUMBNAIL_WIDTH, height: THUMBNAIL_WIDTH)
                            let image = data.toImage()
                            if let image = image.resize(size: size) {
                                if let delegate = delegate {
                                    delegate.updateFileList(index: self.index, image: image)
                                }
                                
                                saveThumbnail(data:image.pngData())
                            }
                        }
                        break
                    }
                }
            }

        }

        deleteFile(destinationURL.path)

        semaphoreQueue.signal()

        debugPrint("<-DownloadedzipForThumbnail()")
    }

    func SetThumbnailImage(_ fileList: [ShareFileInfo]) {
        debugPrint("SetThumbnailImage() ->")

        let tmpDirectory = NSTemporaryDirectory()

        var destinationURL = URL(fileURLWithPath: tmpDirectory)
        destinationURL.appendPathComponent(THUMBNAIL_FOLDER_NAME)
        debugPrint("destinationURL=" + destinationURL.path)

        DispatchQueue.global().async {
            debugPrint("Current thread \(Thread.current)")
            self.index = 0
            for info in fileList {

                self.fileId = info.FileId
                self.pngFileId = info.PngFileId
                self.imgName = ""
            
                if info.Thumbnail == nil {
                    self.getFileDataForThumbnail(self.fileId)
                    debugPrint("semaphoreQueue.wait() ->")
                    self.semaphoreQueue.wait()
                    debugPrint("<- semaphoreQueue.wait()")
                }
                self.index += 1
            }
        }
        debugPrint("<- SetThumbnailImage()")

    }
    
}

/// Data拡張(イメージ)
extension Data {

    // MARK: Public Methods

    /// データ→イメージに変換する
    ///
    /// - Returns: 変換後のイメージ
    func toImage() -> UIImage {
        guard let image = UIImage(data: self) else {
            debugPrint("データをイメージに変換できませんでした。")
            return UIImage()
        }

        return image
    }

}

extension UIImage {
    func resize(size _size: CGSize) -> UIImage? {
        let widthRatio = _size.width / size.width
        let heightRatio = _size.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio

        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0) // 変更
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }
}

