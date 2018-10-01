//
//  MyViewController.swift
//  Enci
//
//  Created by Luciano Calderano on 26/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

class MYViewController: UIViewController, MYNavigationBarDelegate {
    var myNavigationBar:MYNavigationBar?
    
    @IBInspectable var headerTitle:String?
    @IBInspectable var headerImage:UIImage?
    @IBInspectable var optionImage:UIImage?

    var dataArray: Array = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myNavigationBar = navigationController?.navigationBar as! MYNavigationBar?
        self.myNavigationBar?.setBackgroundImage(UIImage.init(), for: UIBarMetrics.default)
        self.myNavigationBar?.shadowImage = nil
        
        self.view.backgroundColor = UIColor.white
        self.tabBarController?.navigationItem.hidesBackButton = true
        
        self.navigationItem.setHidesBackButton(true, animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.myNavigationBar?.isHidden = false
        self.myNavigationBar?.myDelegate = self
        self.myNavigationBar?.header(ctrl: self)
    }
    
    func myNavigationBarBackButtonTapped() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func myNavigationBarOptionButtonTapped () {
        print("MyNavigationBarOptionButtonTapped")
    }
}
