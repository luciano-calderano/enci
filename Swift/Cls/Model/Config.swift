//
//  MYHttp.swift
//  Enci
//
//  Created by Luciano Calderano on 07/11/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib

typealias JsonDict = Dictionary<String, Any>
func openUrl(_ url: String) {
    UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
}

struct Config {
    struct Http {
        static let printJson = true
        struct Values {
            var url = ""
            var key = ""
        }
        static let base = Values.init(url: "http://sport.enci.it/mobile/",
                                      key: "DSF7234hsdsadDSsdaskdakjhsASDhdgfgv09#62")
        static let soft = Values.init(url: "http://sport.enci.it/api/",
                                      key: "SDAshadSD76320DSA-sadERYPOR3232323dsmcbghlDsa")
    }
    
    struct DateFmt {
        static let Db      = "dd-MM-yyyy HH:mm"
        static let DataOra = "dd/MM/yyyy HH:mm"
    }
    
    struct Wheel {
        static var backImage = UIImage.init(named: "logoBack")
    }
    
    struct Challenge {
        static let type = "challenge"
        static let desc = "agility_dog"
        static let name = Lng("eventName")
    }
}
