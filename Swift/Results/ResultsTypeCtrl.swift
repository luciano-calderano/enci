//
//  BinomiCtrl.swift
//  EnciSport
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
class ResultsTypeCtrl: MYViewController {
    class func Instance () -> ResultsTypeCtrl {
        let sb = UIStoryboard.init(name: "Results", bundle: nil)
        return sb.instantiateViewController(withIdentifier: "ResultsTypeCtrl") as! ResultsTypeCtrl
    }
    
    var trialId = 0
    var openId = 0
    
    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        loadData()
    }
    
    // MARK:- IBAction
    
    @IBAction func btnHomologate() {
        openOptions(arrCateg: [])
    }
    
    // MARK:- private

    private func loadData(){
        tableView.reloadData()
    }
    
    private func getClasses (dict: JsonDict) {
        openId = dict.int("AgilityDogOpen.id")
        let request =  MYHttpRequest.base("agility-dog/opens/classes")
        
        request.json = [
            "trophy"      : dict.int("AgilityDogOpen.trophy"),
            "mixed_class" : dict.int("AgilityDogOpen.mixed_class"),
        ]
        request.start() { (success, response) in
            if success {
                self.httpResponse(response)
            }
        }
    }
    
    private func httpResponse (_ resultDict: JsonDict) {
        var array = [JsonDict]()
        for dict in resultDict.array("classes") as! [JsonDict] {
            array.append([
                "id"  : dict.string("AgilityDogClass.id"),
                "name": dict.string("AgilityDogClass.name")
                ])
        }
        openOptions(arrCateg: array)
    }
    
    private func openOptions (arrCateg: Array<JsonDict>) {
        let ctrl = ResultsOptsCtrl.Instance()
        ctrl.openId = openId
        ctrl.trialId = trialId
        ctrl.arrCate = arrCateg
        navigationController?.show(ctrl, sender: self)
    }
}

// MARK:- table view

extension ResultsTypeCtrl: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        cell.textLabel?.font = .withSize(20)
        cell.textLabel?.textColor = .myBlue
        cell.textLabel?.textAlignment = .center
        
        let dic = dataArray[indexPath.row] as! JsonDict
        cell.textLabel?.text = dic.string("AgilityDogOpen.title")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        getClasses(dict: dataArray[indexPath.row] as! JsonDict)
    }
}

