//
//  ListTableViewController.swift
//  ShareLifeBoard
//
//  Created by 土師一哉 on 2020/08/10.
//  Copyright © 2020 土師一哉. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST


class ListTableViewController: UITableViewController {

    public var shareFileList = [ShareFileInfo]()
    var fileCommon = FileCommon()
    
    /// 次ページ取得用トークン
    var nextPageToken: String?
    /// 「Share Life」フォルダID
    var ShareLifeDirId: String?
    
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        fileCommon.delegate = self

        if (!self.appDelegate.IsSignIn) {
            DispatchQueue.main.async {
                debugPrint("DispatchQueue.main.async->")
                self.authGoogleDriveInBrowser()
                debugPrint("<-DispatchQueue.main.async")
            }
        } else {
            // [Share Life]フォルダ情報を取得します。
            debugPrint("Current thread \(Thread.current)")
//            DispatchQueue.global().async {
                self.fileCommon.getFolderId()
//            }

        }

    }
/*
    func updateFileList() {
        debugPrint("updateFileList()->!!! num=\(shareFileList.count)")
        self.tableView.reloadData()
        debugPrint("<-updateFileList()")
    }
*/

    // MARK: - Table view data source
/*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
*/
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shareFileList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let info = shareFileList[indexPath.row]
        cell.textLabel?.text = info.Name
        cell.detailTextLabel?.text = info.ModifiedTimeFormat
//        debugPrint("imageViewSize=\(cell.frame.size.height)" )
        if info.thumbnail != nil {
            cell.imageView?.image = info.Thumbnail
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       debugPrint(" click indexPath.row = \(indexPath.row)")
        let vc = DetailViewController()
        vc.position = indexPath.row
        vc.info = shareFileList[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
