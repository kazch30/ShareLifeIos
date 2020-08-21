//
//  DriveAppAuth.swift
//  ShareLifeBoard
//
//  Created by 土師一哉 on 2020/08/10.
//  Copyright © 2020 土師一哉. All rights reserved.
//

import Foundation
import UIKit
import AppAuth
import GTMAppAuth

extension ListTableViewController {
    /**
     ブラウザ経由のGoogleDrive認証を行います。
     参考: https://github.com/google/GTMAppAuth
           http://qiita.com/doki_k/items/fc317dafd714967809cd
     */
    func authGoogleDriveInBrowser() {
        // issuerのURLを生成します。
        debugPrint("authGoogleDriveInBrowser()->")
        guard let issuer = URL(string: "https://accounts.google.com") else {
            // URLが生成できない場合、処理を終了します。
            // 念のためのチェックです。
            // 必要に応じてエラー処理を行っていください。
            return
        }

        // リダイレクト先URLを生成します。
        // <GoogleDriveのクライアントID>には、"SwiftでGoogleDrive APIを使用する準備を行う"で取得した
        // クライアントIDを設定してください。
//        let redirectUriString = String(format: "com.googleusercontent.apps.%@:/oauthredirect",
//          "605524033158-ll8bgjfprq934mecg48fps61nio42qdg")
        let redirectUriString = String(format: "com.googleusercontent.apps.%@:/oauth2redirect/google.",
          "605524033158-ll8bgjfprq934mecg48fps61nio42qdg")
        guard let redirectURI = URL(string: redirectUriString) else {
            // URLが生成できない場合、処理を終了します。
            // 念のためのチェックです。
            // 必要に応じてエラー処理を行っていください。
            debugPrint("<-authGoogleDriveInBrowser() redirectURI error!!!")
            return
        }

        debugPrint("OIDAuthorizationService.discoverConfiguration()->")
        // エンドポイントを検索します。
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in
            guard let configuration = configuration else {
                self.appDelegate.setGtmAuthorization(nil)
                debugPrint("<-OIDAuthorizationService.discoverConfiguration() error return!!!!")
            return
        }
        debugPrint("<-OIDAuthorizationService.discoverConfiguration()")

        debugPrint("OIDAuthorizationRequest.init()->")
        // 認証要求オブジェクトを作成します。
        let request = OIDAuthorizationRequest.init(
            configuration: configuration,
            clientId: "605524033158-ll8bgjfprq934mecg48fps61nio42qdg.apps.googleusercontent.com",
            scopes: ["https://www.googleapis.com/auth/drive"],
            redirectURL: redirectURI,
            responseType: OIDResponseTypeCode,
            additionalParameters: nil)

            self.appDelegate.googleDriveCurrentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: self) { authState, error in
                if let authState = authState {
                    let gauthorization: GTMAppAuthFetcherAuthorization = GTMAppAuthFetcherAuthorization(authState: authState)
                    self.appDelegate.setGtmAuthorization(gauthorization)
                    debugPrint("OIDAuthorizationRequest authState = authState OK")

                } else {
                    debugPrint("OIDAuthorizationRequest authState = authState Faild!")
                    debugPrint("eror = " + error!.localizedDescription)
                    self.appDelegate.setGtmAuthorization(nil)
                }

                if let authorizer = self.appDelegate.googleDriveServiceDrive.authorizer, let canAuth = authorizer.canAuthorize, canAuth {
                    // サインイン済みの場合
                    // 必要な処理を記述してください。
                    debugPrint("サイン済み")
                    self.fileCommon.getFolderId()
                }
            }
            debugPrint("<-OIDAuthorizationRequest.init()")

            debugPrint("<-authGoogleDriveInBrowser()")
        }

    }
    
    func signOut() {
        debugPrint("signOut()->")
        // GoogleDriveにサインイン済みかチェックします。
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let serviceDrive = appDelegate.googleDriveServiceDrive
        if let authorizer = serviceDrive.authorizer, let canAuth = authorizer.canAuthorize, canAuth {
            // GoogleDriveにサインイン済みの場合
            // GoogleDriveからサインアウトします。
            appDelegate.setGtmAuthorization(nil)
            let serviceDrive = appDelegate.googleDriveServiceDrive
            serviceDrive.authorizer = nil
        }
        debugPrint("<-signOut()")

    }

}
