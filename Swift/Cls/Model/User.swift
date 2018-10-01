//
//  User.swift
//  Enci
//
//  Created by Luciano Calderano on 02/11/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import Foundation
import LcLib

class User {
    static let shared = User()
    enum UserType: String {
        case None = ""
        case Athl = "athlete"
        case Club = "sport_association"
    }

    private let userKey = "User"
    private let tokenKey = "Token"
    private let profileKey = "Profile"

    class func saveToken (_ token: String) {
        User.shared.saveToken(token)
    }
    
    var userProfile:JsonDict {
        get {
            return getUserProfile()
        }
    }
    var userId:Int {
        get {
            return getId()
        }
    }
    var userType:UserType {
        get {
            return getUserType()
        }
    }

    private func getId () -> Int {
        let dict = self.getUserProfile()
        switch dict.string("user.User.type") {
        case UserType.Athl.rawValue:
            return dict.int("user.Athlete.id")
        case UserType.Club.rawValue:
            return dict.int("user.Association.id")
        default:
            break
        }
        return 0
    }
    
    private func getUserType() -> UserType {
        let dict = self.getUserProfile()
        switch dict.string("user.User.type") {
        case UserType.Athl.rawValue:
            return UserType.Athl
        case UserType.Club.rawValue:
            return UserType.Club
        default:
            break
        }
        return UserType.None
    }

    private func getUserProfile() -> JsonDict {
        let dict = UserDefaults.standard.object(forKey: userKey)  as? JsonDict
        guard dict != nil else {
            return [:]
        }
        return dict!.dictionary(profileKey)
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: userKey)
    }
    
    func saveUser(_ dict:JsonDict, name:String, pass:String) {
        UserDefaults.standard.setValue([
            "UserName" : name,
            "Password" : pass,
            profileKey : dict
            ], forKey: userKey)
        
        sendUserToken()
    }
    
    func saveToken (_ token: String) {
        UserDefaults.standard.setValue(token, forKey: tokenKey)
        print ("Token: ", token)
    }
    
    private func sendUserToken() {
        let token = UserDefaults.standard.object(forKey: tokenKey) as! String
        if token.isEmpty {
            return;
        }
        
        let user = self.getUserProfile()
        let request =  MYHttpRequest.base("push/apple/save-device-token")
        request.json = [
            "account_id"   : user.string("Account.id"),
            "device_token" : token
        ]
        request.start(false)
    }
    
    private func removeUserToken() {
        let token = UserDefaults.standard.object(forKey: tokenKey) as! String
        if token.isEmpty {
            return;
        }
        
        let request =  MYHttpRequest.base("push/apple/remove-device-token")
        request.json = [
            "device_token" : token
        ]
        request.start(false)
    }
}
