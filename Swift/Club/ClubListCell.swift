//
//  ClubListCell.swift
//  EnciSport
//
//  Created by Luciano Calderano on 26/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

protocol ClubListCellDelegate: class {
    func clubListCellDidPhoneTapped(value: String)
    func clubListCellDidEmailTapped(value: String)
}

class ClubListCell: UITableViewCell {
    class func dequeue (_ tableView: UITableView, indexPath: IndexPath) -> ClubListCell {
        return tableView.dequeueReusableCell(withIdentifier: "ClubListCell", for: indexPath) as! ClubListCell
    }
    
    var dicData = JsonDict() {
        didSet {
            self.showData(dicData.dictionary("Association"))
        }
    }    
    
    @IBOutlet private var business_name: UITextView!
    @IBOutlet private var address: UITextView!
    @IBOutlet private var city_name: UITextView!
    @IBOutlet private var phone: UITextView!
    @IBOutlet private var email: UITextView!
    @IBOutlet private var imageLogo: UIImageView!
    
    weak var delegate:ClubListCellDelegate?
    
    private func showData(_ dic: JsonDict) -> Void {
        business_name.text = dic.string("business_name")
        if (business_name.text.count == 0) {
            business_name.text = dic.string("username")
        }
        business_name.text = business_name.text.capitalized
        
        address.text = dic.string("address") + " " + dic.string("city").replacingOccurrences(of: "\n", with: " ")
        
        city_name.text = dic.string("city_name") + " " + dic.string("region_name")
        phone.text = dic.string("phone")
        email.text = dic.string("email")
        
        imageLogo.withUrl(dic.string("image"), placeHolder: UIImage (named: "logoBack")) {
            (result) in
            self.imageLogo.alpha = result ? 1 : 0.66
        }
    }
    
    @IBAction func btnPhone(_ sender: UIButton) {
        delegate?.clubListCellDidPhoneTapped(value: phone.text)
    }
    @IBAction func btnEmail(_ sender: UIButton) {
        delegate?.clubListCellDidEmailTapped(value: email.text)
    }
}
