//
//  BinomiCtrl.swift
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

protocol DogsOptsCtrlDelegate : class {
    func dogsOptsDidSelected(idCateg: Int, idClass: Int, idGender: String)
}

import UIKit
import LcLib

class DogsOptsCtrl: MYViewController {
    class func Instance () -> DogsOptsCtrl {
        let sb = UIStoryboard.init(name: "Dogs", bundle: nil)
        return sb.instantiateViewController(withIdentifier: "DogsOptsCtrl") as! DogsOptsCtrl
    }

    @IBOutlet var pickCate: UIPickerView!
    @IBOutlet var pickClas: UIPickerView!
    @IBOutlet var opzGender: UISegmentedControl!
    private var arrCate = [JsonDict]()
    private var arrClas = [JsonDict]()

    private let softCate = "AgilityDogCategory"
    private let softClas = "AgilityDogClass"
    
    weak var delegate:DogsOptsCtrlDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        opzGender.selectedSegmentIndex = 0
        opzGender.setTitle(Lng("all"),     forSegmentAt: 0)
        opzGender.setTitle(Lng("gender0"), forSegmentAt: 1)
        opzGender.setTitle(Lng("gender1"), forSegmentAt: 2)

        self.loadCateg()
        self.loadClasses()
    }
    func loadCateg(){
        let request =  MYHttpRequest.base("dogs/categories/list")
        request.json = [:]
        request.start() { (success, response) in
            if success {
                let dicAll = [self.softCate: ["id": "",  "name": Lng("all")]]
                self.arrCate = response.array("categories") as! [JsonDict]
                self.arrCate.insert(dicAll, at: 0)
                self.pickCate.reloadAllComponents()
            }
        }
    }
    func loadClasses(){
        let request =  MYHttpRequest.base("dogs/classes/list")
        request.json = [:]
        request.start() { (success, response) in
            if success {
                let dicAll = [self.softClas: ["id": "",  "name": Lng("all")]]
                self.arrClas = response.array("classes") as! [JsonDict]
                self.arrClas.insert(dicAll, at: 0)
                self.pickClas.reloadAllComponents()
            }
        }
    }
    
    @IBAction func btnOk() {
        let rowCate = pickCate.selectedRow(inComponent: 0)
        let dicCate = arrCate[rowCate]
        let idCateg = dicCate.int(softCate + ".id")
        
        let rowClas = pickClas.selectedRow(inComponent: 0)
        let dicClas = arrClas[rowClas]
        let idClass = dicClas.int(softClas + ".id")
        
        var idGender = ""
        switch opzGender.selectedSegmentIndex {
        case 1:
            idGender = "0"
        case 2:
            idGender = "1"
        default:
            break
        }
        delegate?.dogsOptsDidSelected(idCateg: idCateg, idClass: idClass, idGender: idGender)
        _ = navigationController?.popViewController(animated: true)
    }
}

//MARK:- UIPickerViewDelegate

extension DogsOptsCtrl: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (pickerView == pickClas) ? arrClas.count : arrCate.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 45
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let myPickerCell = MyPickerCell()
        if pickerView == pickClas {
            let dic = arrClas[row]
            myPickerCell.text = dic.string(self.softClas + ".name")
        } else {
            let dic = arrCate[row]
            myPickerCell.text = dic.string(self.softCate + ".name")
        }
        return myPickerCell
    }
}
