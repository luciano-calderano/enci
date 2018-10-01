//
//  BinomiCtrl.swift
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib

class EventsDettSubView: UIView, UIWebViewDelegate {
    @IBOutlet private var lblType: MYLabel!
    @IBOutlet private var lblDay: MYLabel!
    @IBOutlet private var lblMonth: MYLabel!
    @IBOutlet private var lblEventTitle: MYLabel!
    @IBOutlet private var lblPlace: MYLabel!
    @IBOutlet private var lblAddress: MYLabel!
    @IBOutlet private var lblSport: MYLabel!
    @IBOutlet private var lblTrofeo: MYLabel!
    @IBOutlet private var lblSubIni: MYLabel!
    @IBOutlet private var lblSubFin: MYLabel!
    @IBOutlet private var lblRegolamento: MYLabel!
    @IBOutlet private var lblBus: MYLabel!
    
    @IBOutlet private var imvLocandina: UIImageView!
    @IBOutlet private var webView: UIWebView!
    
    private let rectLocandina = CGRect.zero
    private var mainScrollView: UIScrollView?
    
    var dicData = JsonDict() {
        didSet {
            self.showData(dicData)
        }
    }
    
    class func addToScrollView(_ scrollView: UIScrollView) -> EventsDettSubView {
        let classPath = NSStringFromClass(self).components(separatedBy: ".")
        let className = classPath.last
        let me = Bundle.main.loadNibNamed(className!, owner: self, options: nil)?.first as! EventsDettSubView
        scrollView.addSubview(me)
        scrollView.contentSize = me.bounds.size
        me.mainScrollView = scrollView
        me.frame = scrollView.frame
        scrollView.contentSize = me.frame.size
        return me
    }

    override func awakeFromNib() {
        lblType.layer.masksToBounds = true
        lblType.layer.cornerRadius = 5
        lblPlace.text = ""
        lblDay.text =  ""
        lblMonth.text = ""
        lblRegolamento.text = ""
        lblBus.text = ""
        lblAddress.text = ""
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.delegate = self
        
        imvLocandina.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.locandinaTap))
        imvLocandina.addGestureRecognizer(tap)
    }
    
    @objc func locandinaTap() {
        let ctrl = UIApplication.shared.keyWindow?.rootViewController
        
        let imvLocandinaFull = UIImageView(image: imvLocandina.image!)
        imvLocandinaFull.frame = CGRect(x: ctrl!.view.center.x, y: ctrl!.view.center.y, width: 0, height: 0)
        imvLocandinaFull.isUserInteractionEnabled = true
        imvLocandinaFull.tag = 100
        imvLocandinaFull.backgroundColor = UIColor.init(r: 244, g: 244, b: 244)
        imvLocandinaFull.contentMode = UIView.ContentMode.scaleAspectFit
        
        ctrl!.view.addSubview(imvLocandinaFull)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.closePic))
        imvLocandinaFull.addGestureRecognizer(tap)
        
        imvLocandinaFull.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            imvLocandinaFull.frame = ctrl!.view.bounds
        })
    }
    
    @objc func closePic() {
        let ctrl = UIApplication.shared.keyWindow?.rootViewController
        
        let imv = ctrl!.view.viewWithTag(100)
        UIView.animate(withDuration: 0.3, animations: {
            imv!.frame = CGRect(x: ctrl!.view.center.x, y: ctrl!.view.center.y, width: 0, height: 0)
            
        }, completion: { (true) in
            imv?.removeFromSuperview()
        })
    }
    
    private func showData(_ dic: JsonDict) -> Void {
//        imvLocandina.imageFromUrl(dic.string("image"))
        let placeHolder = UIImage.init(named: "logoBack")
        imvLocandina.withUrl(dic.string("image"), placeHolder: placeHolder) {
            (result) in
            self.imvLocandina.alpha = result ? 1 : 0.5
        }

        lblEventTitle.text = dic.string("title")
        lblBus.text = dic.string("association_business_name")
        
        var s = dic.string("type") + " " + dic.string("agility_dog_category").capitalized
        lblRegolamento.text = s.replacingOccurrences(of: "_", with: " ")
        
        lblSport.text = dic.string("challenge_sport")
        s = dic.string("agility_dog_category")
        if s.isEmpty == false {
            lblSport.text = lblSport.text! + " / " + s
        }
        s = dic.string("agility_dog_extra")
        if s.isEmpty == false {
            lblSport.text = lblSport.text! + " / " + s
        }
        
        let sino = (dic.string("enci_trophy") == "No") ? "NO" : "SI"
        lblTrofeo.text = Lng(sino)

        var date = dic.string("event_start").toDate(withFormat: Config.DateFmt.Db)
        lblDay.text = date!.toString(withFormat: "dd")
        lblMonth.text = date!.toString(withFormat: "MMM")
        
        lblPlace.text = dic.string("place")
        lblAddress.text = dic.string("address")
        
        s = dic.string("city_name")
        if s.isEmpty == false {
            lblAddress.text = lblAddress.text! + " (" + s + ")"
        }
        lblType.text = Config.Challenge.name

        date = dic.string("subscription_start").toDate(withFormat: Config.DateFmt.Db)
        lblSubIni.text = date!.toString(withFormat: Config.DateFmt.DataOra)
        date = dic.string("subscription_end").toDate(withFormat: Config.DateFmt.Db)
        lblSubFin.text = date!.toString(withFormat: Config.DateFmt.DataOra)

        webView.loadHTMLString(dic.string("description"), baseURL: nil)
    }
    
    func  webViewDidFinishLoad(_ webView: UIWebView) {
        var rect = webView.frame;
        rect.origin.x = 0
        rect.size.height = 1
        rect.size.width = self.frame.size.width;
        webView.frame = rect
        
        let fittingSize = webView.sizeThatFits(CGSize.zero)
        rect.size = fittingSize;
        webView.frame = rect;
        
        var rectSelfView = self.frame
        rectSelfView.size.height = rect.origin.y + rect.size.height + 80;
        self.frame = rectSelfView;
        
        mainScrollView?.contentSize = self.frame.size
    }
}

