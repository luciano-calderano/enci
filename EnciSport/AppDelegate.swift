//
//  AppDelegate.swift
//  EnciSport
//
//  Created by Luciano Calderano on 17/11/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib

func Lng(_ key: String) -> String {
    return MYLang.value(key)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.backgroundColor = .myBlue
        self.registerNotification (application)
        MYLang.setup(langListCodes: ["en", "it"], langFileName: "Lang.txt")
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    //MARK:- *** Notification ***
    
    private func registerNotification(_ application: UIApplication) {
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let chars = Set("< >")
        let token = String(deviceToken.description.filter { chars.contains($0) == false })

        User.saveToken(token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        User.saveToken("[ Token simulatore ]")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        switch UIApplication.shared.applicationState {
        case .inactive:
            self.notificationTapped(userInfo)
        case .active:
            self.notificationReceived(userInfo)
        default:
            break
        }
    }

    //MARK: *** Notification action ***

    private func notificationReceived (_ userInfo: [AnyHashable : Any]) {
        let alert = UIAlertController(title:   "Enci Sport",
                                      message: "Nuova notifica",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            self.notificationTapped(userInfo)
        }))
        
        let ctrl = UIApplication.shared.keyWindow?.rootViewController
        ctrl!.present(alert, animated: true, completion: nil)
    }

    private func notificationTapped (_ userInfo: [AnyHashable : Any]) {
        let type = userInfo.string("aps.message_type")
        if type.isEmpty {
            return
        }

        let value = userInfo.string("aps.target_id")
        if value.isEmpty {
            return
        }
        switch type {
        case "news":
            let navController = self.window?.rootViewController as! UINavigationController
            let ctrl = NewsDettCtrl.Instance()
            ctrl.idNews = Int(value)!
            navController.pushViewController(ctrl, animated: true)
        case "event":
            let navController = self.window?.rootViewController as! UINavigationController
            let ctrl = EventsDettCtrl.Instance()
            ctrl.eventId = Int(value)!
            navController.pushViewController(ctrl, animated: true)
        default:
            break
        }
    }
}
