//
//  DetailViewController.swift
//  ShareLifeBoard
//
//  Created by 土師一哉 on 2020/08/10.
//  Copyright © 2020 土師一哉. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST

class DetailViewController: CommentCommon {

    public var position = 0
    public var info:ShareFileInfo?
    let imageView = UIImageView()
    //テーブルビューインスタンス作成
    let tableView: UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard self.info != nil else {
            return
        }

        view.backgroundColor = UIColor.systemBackground
        
        debugPrint("FileId=" + info!.FileId)
        debugPrint("PngFileId=" + info!.PngFileId)
        debugPrint("OwnedByMe=\(info!.OwnedByMe)")
        
        // UIImageView 初期化
        //let imageView = UIImageView()
        // スクリーンの縦横サイズを取得
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        let rect:CGRect =
        CGRect(x:0, y:0, width:screenWidth, height:screenHeight/2)
        let rectTable:CGRect =
        CGRect(x:0, y:view.frame.size.height/2, width:screenWidth, height:screenHeight/2)

        imageView.backgroundColor = UIColor.systemBackground
        tableView.backgroundColor = UIColor.systemBackground
        
        // ImageView frame をCGRectで作った矩形に合わせる
        imageView.frame = rect
        tableView.frame = rectTable
        
        // sampleTableView の dataSource 問い合わせ先を self に
        tableView.delegate = self
        // sampleTableView の delegate 問い合わせ先を self に
        tableView.dataSource = self
        //cellに名前を付ける
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // UIImageViewのインスタンスをビューに追加
        self.view.addSubview(imageView)
        self.view.addSubview(tableView)

        
        DispatchQueue.main.async {
            self.getFileData(self.info!.FileId)
//            self.GetPermissionList(self.info!.FileId)
        }

    }
    
    override func LoardImgFile(_ source: URL) {
        debugPrint("LoardImgFile()->")
        if let image:UIImage = readimage(source) {
            // スクリーンの縦横サイズを取得
            let screenWidth:CGFloat = view.frame.size.width
            let screenHeight:CGFloat = view.frame.size.height / 2
            
            // 画像の縦横サイズを取得
            let imgWidth:CGFloat = image.size.width
            let imgHeight:CGFloat = image.size.height
            
            // 画像サイズをスクリーン幅に合わせる
            let scale:CGFloat = screenWidth / imgWidth
            let rect:CGRect =
                CGRect(x:0, y:0, width:imgWidth*scale, height:imgHeight*scale)
            
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect
            
            // 画像の中心を画面の中心に設定
            imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/2)
            
            imageView.image = image
        }
        
        DispatchQueue.main.async {
            self.GetCommentList(self.info!.FileId)
        }
        debugPrint("<-LoardImgFile()")
    }
    
    override func update() {
        debugPrint("update()->")
        tableView.reloadData()
        debugPrint("<-update()")
    }

}

extension DetailViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return commentList.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let info = commentList[indexPath.row]
        cell.textLabel?.text = info.Name
        cell.detailTextLabel?.text = info.ModifiedTimeFormat
        let fugafugaUIImage = UIImage()
        let url: URL? = URL(string: "https:" + info.PhotoLink)
        cell.imageView?.loadImageAsynchronously(url: url,cell: cell, defaultUIImage: fugafugaUIImage)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       debugPrint(" click indexPath.row = \(indexPath.row)")
/*        let vc = DetailViewController()
        vc.position = indexPath.row
        vc.info = shareFileList[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)*/
    }
    
    // Override to support editing the table view.
/*    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }*/
    
    //削除機能
    func tableView(_ sampleTableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
            sampleTableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteButton.backgroundColor = UIColor.red
        
        return [deleteButton]
    }
}

extension UIImageView {
    func loadImageAsynchronously(url: URL?, cell:UITableViewCell, defaultUIImage: UIImage? = nil) -> Void {
        debugPrint("loadImageAsynchronously()->")
        if url == nil {
            self.image = defaultUIImage
            return
        }

        DispatchQueue.global().async {
            do {
                let imageData: Data? = try Data(contentsOf: url!)
                DispatchQueue.main.async {
                    if let data = imageData {
                        self.image = UIImage(data: data)
                        cell.setNeedsLayout()
//                        self.isHidden = false
                        debugPrint("<-loadImageAsynchronously() success")
                    } else {
                        self.image = defaultUIImage
                        debugPrint("<-loadImageAsynchronously() data == nil")

                    }
                }
            }
            catch {
                DispatchQueue.main.async {
                    self.image = defaultUIImage
                    debugPrint("<-loadImageAsynchronously() failed")
                }
            }
        }
    }
}
