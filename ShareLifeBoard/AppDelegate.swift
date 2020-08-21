//
//  AppDelegate.swift
//  ShareLifeBoard
//
//  Created by 土師一哉 on 2020/08/01.
//  Copyright © 2020 土師一哉. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import AppAuth
import GTMAppAuth

#if !DEBUG
func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    // なにもしない
    
}
#endif


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
        /// GoogleDriveサービスドライブ
        let googleDriveServiceDrive = GTLRDriveService()
        
        /// 認証オブジェクト
        var googleDriveAuthorization: GTMAppAuthFetcherAuthorization?

        /// 現在の認証フローオブジェクト
    //    var googleDriveCurrentAuthorizationFlow: OIDAuthorizationFlowSession?
        var googleDriveCurrentAuthorizationFlow: OIDExternalUserAgentSession?
        
    var IsSignIn = false
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // GoogleDriveの初期化を行います。
        initGoogleDrive()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    
        func application(_ app: UIApplication,
                         open url: URL,
                         options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
          // Sends the URL to the current authorization flow (if any) which will
          // process it if it relates to an authorization response.
        debugPrint("call back->")

          if let authorizationFlow = self.googleDriveCurrentAuthorizationFlow,
                                     authorizationFlow.resumeExternalUserAgentFlow(with: url) {
            self.googleDriveCurrentAuthorizationFlow = nil
            debugPrint("<-call back true")

            return true
          }

          // Your additional URL handling (if any)

          debugPrint("<-call back false")
          return false
        }

        
        /**
         GoogleDriveの初期化を行います。
         */
        func initGoogleDrive() {
            // GoogleDriveのサインイン状態をキーチェーンからロードします。
            debugPrint("initGoogleDrive()->")
    //        if let authorization = GTMAppAuthFetcherAuthorization(fromKeychainForName: "<キーチェーンのキー名>") {
            if let authorization = GTMAppAuthFetcherAuthorization(fromKeychainForName: "com.x0.ShareLife-token") {
                //
                // GTM認証結果を設定します。
                self.setGtmAuthorization(authorization)
            }
            debugPrint("<-initGoogleDrive()")

        }

        
        /**
         GTM認証結果を設定します。

         - Parameter authorization: 認証結果
         */
        func setGtmAuthorization(_ authorization: GTMAppAuthFetcherAuthorization?) {
            debugPrint("setGtmAuthorization()->")
            if googleDriveAuthorization == authorization {
                // 認証済みのオブジェクトの場合、処理を終了します。
                debugPrint("<-setGtmAuthorization 認証済み!!()")
                return
            }
            
            // クロージャーで返却されたオブジェクトをインスタンス変数に保存します。
            googleDriveAuthorization = authorization
            googleDriveServiceDrive.authorizer = googleDriveAuthorization
                    
            //GoogleDriveサインイン状態を変更する。
            googleDriveSignInStateChanged()
            debugPrint("<-setGtmAuthorization()")
        }
        
        /**
         GoogleDriveサインイン状態を変更します。
         */
        func googleDriveSignInStateChanged() {
            // GoogleDriveのサインイン状態を保存します。
            saveGoogleDriveSignInState()
        }
        
        /**
         GoogleDriveのサインイン状態を保存します。
         */
        func saveGoogleDriveSignInState() {
        debugPrint("saveGoogleDriveSignInState()->")

    //        let keychainItemName = "＜キーチェーンに保存しておく任意キー名>"
            let keychainItemName = "com.x0.ShareLife-token"
            if let authorization = googleDriveAuthorization, authorization.canAuthorize() {
                // サインイン状態の場合
                debugPrint("サインイン状態の場合")
                GTMAppAuthFetcherAuthorization.save(authorization, toKeychainForName: keychainItemName)
                IsSignIn = true

            } else {
                // サインアウトの場合
                GTMAppAuthFetcherAuthorization.removeFromKeychain(forName: keychainItemName)
                debugPrint("サインアウトの場合")
            }
            debugPrint("<-saveGoogleDriveSignInState()")

        }


}

