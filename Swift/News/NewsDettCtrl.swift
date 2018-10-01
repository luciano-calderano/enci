//
//  NewsDettCtrl.swift
//  Enci
//
//  Created by Luciano Calderano on 03/11/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib

class NewsDettCtrl: MYViewController {
    class func Instance () -> NewsDettCtrl {
        let sb = UIStoryboard.init(name: "News", bundle: nil)
        return sb.instantiateViewController(withIdentifier: "NewsDettCtrl") as! NewsDettCtrl
    }

    var idNews = 0
    
    @IBOutlet private var web:UIWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    private func loadData(){
        let request =  MYHttpRequest.base("articles/details")
        request.json = [
            "article_id" : self.idNews,
            "img_width"  : 256,
            "img_height" : 256,
            "img_crop"   : 2,
            "img_bg"     : "FFFFFF",
        ]
        request.start() { (success, response) in
            if success {
                self.httpResponse(response)
            }
        }
    }
    
    private func httpResponse(_ resultDict: JsonDict) {
        let wheel = MYWheel(true)
//        wheel.start()
        let dict = resultDict.dictionary("article.Article")
        
        var str = "<p align=left><font face='Dosis, Arial, Helvetica, sans-serif' color='#01509D' size='3'><b>"
        str += dict.string("title")
        str += "<br>"
        str += "<p align=left><font size='2'><b>"
        if dict.string("author").isEmpty == false {
            str += Lng("newsAuth") + ": " + dict.string("author") + "<br>"
        }
        if dict.string("publishing_datetime").isEmpty == false {
            str += Lng("newsPubl") + ": " + dict.string("publishing_datetime").left(lenght: 10) + "<br>"
        }

        str += "</font></p>"
        str += "<hr>"
        str += "<p align=center><img src='" + dict.string("image") + "'></p>"
        str += "<hr>"
        str += dict.string("description")

        self.web?.loadHTMLString(str, baseURL: URL.init(string: "http://www.csencinofilia.it"))
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            wheel.stop()
        }
    }
}
