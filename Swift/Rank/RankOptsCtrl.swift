//
//  RankOptsCtrl
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
class RankOptsCtrl: MYViewController {
    class func Instance () -> RankOptsCtrl {
        let sb = UIStoryboard.init(name: "Ranking", bundle: nil)
        return sb.instantiateViewController(withIdentifier: "RankOptsCtrl") as! RankOptsCtrl
    }
    var year = 0
    
    @IBOutlet var pickAreas: UIPickerView!
    @IBOutlet var pickCateg: UIPickerView!
    
    private var arrAreas = [JsonDict]()
    private var arrCateg = [JsonDict]()
    
    weak var delegate:DogsOptsCtrlDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAreas()
        loadCateg()
    }
    
    private func loadAreas() {
        let request =  MYHttpRequest.base("agility-dog/opens/list-areas")
        request.json = [
            "year": year,
        ]
        
        request.start() { (success, response) in
            if success {
                self.httpResponseArea(response)
            }
        }
    }
    private func httpResponseArea(_ response: JsonDict) {
        arrAreas = response.array("areas") as! [JsonDict]
        pickAreas.reloadAllComponents()
    }

    private func loadCateg() {
        let request =  MYHttpRequest.base("dogs/categories/list")
        request.json = [:]
        request.start() { (success, response) in
            if success {
                self.httpResponseCateg(response)
            }
        }
    }
    
    private func httpResponseCateg (_ response: JsonDict) {
        arrCateg = response.array("categories") as! [JsonDict]
        pickCateg.reloadAllComponents()
    }
    
    @IBAction func btnOk() {
        let rowAreas = pickAreas.selectedRow(inComponent: 0)
        let dicAreas = arrAreas[rowAreas]
        let areaId = dicAreas.int("AgilityDogOpenArea.id")
        let areaName = dicAreas.string("AgilityDogOpenArea.name")
        
        let rowCateg = pickCateg.selectedRow(inComponent: 0)
        let dicCateg = arrCateg[rowCateg]
        let cateId = dicCateg.int("AgilityDogCategory.id")
        let cateName = dicCateg.string("AgilityDogCategory.name")
        
        let ctrl = RankShowCtrl.Instance()
        ctrl.year = self.year
        ctrl.areaId = areaId
        ctrl.strAreaDesc = areaName
        ctrl.cateId = cateId
        ctrl.strCateDesc = cateName
        
        navigationController?.show(ctrl, sender: self)
    }
}

//MARK:- UIPickerViewDelegate

extension RankOptsCtrl: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (pickerView == pickCateg) ? arrCateg.count : arrAreas.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 45
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let myPickerCell = MyPickerCell()
        if pickerView == pickCateg {
            let dic = arrCateg[row]
            myPickerCell.text = dic.string("AgilityDogCategory.name")
        } else {
            let dic = arrAreas[row]
            myPickerCell.text = dic.string("AgilityDogOpenArea.name")
        }
        return myPickerCell
    }
}
