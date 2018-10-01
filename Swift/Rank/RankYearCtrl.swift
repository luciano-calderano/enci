//
//  BinomiCtrl.swift
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib

class RankYearCtrl: MYViewController {
    class func Instance () -> RankYearCtrl {
        let sb = UIStoryboard.init(name: "Ranking", bundle: nil)
        return sb.instantiateViewController(withIdentifier: "RankYearCtrl") as! RankYearCtrl
    }

    @IBOutlet var pickYear: UIPickerView!
    @IBOutlet var rankTypeSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rankTypeSegment.setTitle(Lng(rankTypeSegment.titleForSegment(at: 0)!), forSegmentAt: 0)
        rankTypeSegment.setTitle(Lng(rankTypeSegment.titleForSegment(at: 1)!), forSegmentAt: 1)
        loadData()
    }
    
    private func loadData() {
        let request = MYHttpRequest.base("agility-dog/opens/trophy-years")
        request.start() { (success, response) in
            if success {
                self.httpResponse(response)
            }
        }
    }
    
    private func httpResponse(_ response: JsonDict) {
        dataArray = response.array("enci_trophy_years") as! [JsonDict]
        pickYear.reloadAllComponents()
    }
    
    @IBAction func btnOk() {
        let row = pickYear.selectedRow(inComponent: 0)
        let dict = dataArray[row] as! JsonDict
        
        let ctrl = RankOptsCtrl.Instance()
        ctrl.year = dict.int("year")
        navigationController?.show(ctrl, sender: self)
    }

}

//MARK:- UIPickerViewDelegate

extension RankYearCtrl: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 45
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let myPickerCell = MyPickerCell()
        let dic = dataArray[row] as! JsonDict
        myPickerCell.text = dic.string("name")
        return myPickerCell
    }
}
