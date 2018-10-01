//
//  BinomiCtrl.swift
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
class ResultsOptsCtrl: MYViewController {
    class func Instance () -> ResultsOptsCtrl {
        let sb = UIStoryboard.init(name: "Results", bundle: nil)
        return sb.instantiateViewController(withIdentifier: "ResultsOptsCtrl") as! ResultsOptsCtrl
    }
    
    var trialId = 0
    var openId = 0
    
    @IBOutlet var pickCate: UIPickerView!
    @IBOutlet var pickSize: UIPickerView!

    private var arrSize = [JsonDict]()
    var arrCate = [JsonDict]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrSize = [
            [ "id" : "3", "name" : "Small"  ],
            [ "id" : "4", "name" : "Medium" ],
            [ "id" : "5", "name" : "Large"  ],
        ]

        guard arrCate.count == 0 else {
            return
        }
        arrCate = [
            [ "id" : "4", "name" : "Debuttanti"  ],
            [ "id" : "1", "name" : "1° Assoluti" ],
            [ "id" : "2", "name" : "2° Assoluti" ],
            [ "id" : "3", "name" : "3° Assoluti" ],
        ]
    }

    @IBAction func btnOk() {
        let rowCate = pickCate.selectedRow(inComponent: 0)
        let dicCate = arrCate[rowCate]

        let rowSize = pickSize.selectedRow(inComponent: 0)
        let dicSize = arrSize[rowSize]
        
        let ctrl = ResultsShowCtrl.Instance()
        ctrl.openId = openId
        ctrl.trialId = trialId
        ctrl.classId = dicCate.int("id")
        ctrl.categId = dicSize.int("id")
        ctrl.titleSelection = dicCate.string("name") + " " + dicSize.string("name")
        navigationController?.show(ctrl, sender: self)
    }
}

//MARK: - UIPickerViewDelegate

extension ResultsOptsCtrl: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (pickerView == pickSize) ? arrSize.count : arrCate.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 45
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let myPickerCell = MyPickerCell()
        if pickerView == pickSize {
            let dic = arrSize[row]
            myPickerCell.text = dic.string("name")
        } else {
            let dic = arrCate[row]
            myPickerCell.text = dic.string("name")
        }
        return myPickerCell
    }
}

