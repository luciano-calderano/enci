//
//  MYHttp.swift
//  Lc
//
//  Created by Luciano Calderano on 07/11/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import Alamofire

class MYHttpRequest {
    class func base (_ page: String) -> MYHttpRequest {
        let conf = Config.Http.base
        return MYHttpRequest.init(auth: conf.key, page: conf.url + page)
    }
    
    class func software (_ page: String) -> MYHttpRequest {
        let conf = Config.Http.soft
        return MYHttpRequest.init(auth: conf.key, page: conf.url + page)
    }
    
    var json = JsonDict()
    var type = HTTPMethod.post
    
    fileprivate var page = ""
    fileprivate var auth = ""
    fileprivate var myWheel:MYWheel?
    fileprivate var parameters: JsonDict {
        get {
            var parameters = self.json
            parameters["auth_code"] = self.auth
            return parameters
        }
    }

    init(auth: String, page: String) {
        self.page = page
        self.auth = auth
    }
    
    // MARK: - Start
    
    func start (_ showWheel: Bool = true, completion: ((Bool, JsonDict) -> ())? = nil) {
        if showWheel {
            startWheel(true)
        }
        printJson(self.json)
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 30
        
        manager.request(self.page, method: self.type, parameters: self.parameters).responseJSON {
            response in
            if response.result.isSuccess {
                completion! (response.result.isSuccess, response.result.value as! JsonDict)
                self.printJson(response.result.value as! JsonDict)
            }
            if showWheel {
                self.startWheel(false)
            }
        }
    }
    
    // MARK: - private
    
    fileprivate func printJson (_ json: JsonDict) {
        if Config.Http.printJson {
            print("\n[ \(self.page) ]\n\(json)\n------------")
        }
    }
    
    fileprivate func startWheel(_ start: Bool, show: Bool = true, inView: UIView = UIApplication.shared.keyWindow!) {
        guard show else {
            return
        }
        if start {
            myWheel = MYWheel()
            myWheel?.start(inView)
        } else {
            myWheel?.stop()
            myWheel = nil
        }
    }
    
}

