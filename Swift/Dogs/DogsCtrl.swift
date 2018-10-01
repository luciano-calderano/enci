//
//  BinomiCtrl.swift
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib

class DogsCtrl: MYViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var txtSrch: UITextField!
    
    var numPage = 1
    var maxRecords = 25
    var lastPage = false
    
    var idGender = ""
    var idCateg = 0
    var idClass = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtSrch!.placeholder = Lng("srch")
        loadData()
    }
    
    override func myNavigationBarOptionButtonTapped() {
        let ctrl = DogsOptsCtrl.Instance()
        ctrl.delegate = self
        navigationController?.show(ctrl, sender: self)
    }
    
    private func loadData(){
        let request =  MYHttpRequest.base("dogs/list")
        request.json = [
            "page"       : numPage,
            "maxrecords" : maxRecords,
            "src"        : txtSrch.text!,
            "gender"     : idGender,
            "category_id": idCateg,
            "class_id"   : idClass,
        ]
        request.start() { (success, response) in
            if success {
                self.httpResponse(response)
            }
        }
    }
    
    private func httpResponse(_ resultDict: JsonDict) {
        let arr = resultDict.array("dogs")
        
        lastPage = (arr.count < maxRecords) ? true : false
        if (numPage == 1) {
            dataArray = []
        }
        dataArray += arr
        tableView.reloadData()
    }
    
    // MARK: Search
    
    @IBAction func btnSrch() {
        numPage = 1
        loadData()
        txtSrch?.resignFirstResponder()
    }
}

// MARK:- table view

extension DogsCtrl: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = DogsCell.dequeue(tableView, indexPath: indexPath)
        cell.dicData = dataArray[indexPath.row] as! JsonDict
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK:- UIScrollViewDelegate

extension DogsCtrl: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if lastPage {
            return
        }
        let lastRow = (tableView.indexPath(for: tableView.visibleCells.last!)?.row)! + 1
        if lastRow == self.numPage * self.maxRecords {
            numPage += 1
            loadData()
        }
    }
}

// MARK:- DogsOptsCtrlDelegate

extension DogsCtrl: DogsOptsCtrlDelegate {
    func dogsOptsDidSelected(idCateg: Int, idClass: Int, idGender: String) {
        self.idClass = idClass
        self.idCateg = idCateg
        self.idGender = idGender
        loadData()
    }
}

