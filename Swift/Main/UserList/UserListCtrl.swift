//
//  UserListCtrl
//  Enci
//
//  Created by Luciano Calderano on 28/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit
import LcLib

enum UserListType: String {
    case regionAndCity
    case cities
    case countries
    case affiliates
    case regionsOnly
}

protocol UserListDelegate {
    func userListDelegate(type: UserListType, id: String, name: String)
}

class UserListCtrl: MYViewController {
    class func Instance () -> UserListCtrl {
        let sb = UIStoryboard.init(name: "UserList", bundle: nil)
        return sb.instantiateViewController(withIdentifier: "UserListCtrl") as! UserListCtrl
    }
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var srchBar: UISearchBar!
    
    var delegate: UserListDelegate?
    var listType = UserListType.regionAndCity

    private var subClass: List?
    private var totalArray = [JsonDict]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        selectClass()
        
        srchBar!.placeholder = Lng("srch")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        loadData()
    }
    
    private func selectClass() {
        switch listType {
        case .countries :
            subClass = Country()
        case .regionAndCity, .regionsOnly :
            subClass = Region()
        case .cities :
            subClass = City()
        case .affiliates :
            subClass = Affiliated()
        }
        headerTitle = subClass?.title
    }
    
    private func loadData() {
        let request =  MYHttpRequest.base((subClass?.page)!)
        request.json = (subClass?.json())!
        
        request.start() { (success, response) in
            if success {
                self.totalArray = (self.subClass?.response(response))!
            }
            self.dataArray = self.totalArray
            self.tableView.reloadData()
        }
    }
    
    //MARK:-
    
    class List  {
        var title = ""
        var page = ""
        var keyName = ""
        var keyId = ""
        var regionId = ""
        
        func json () -> JsonDict {
            return [:]
        }
        func response(_ resultDict: JsonDict) -> [JsonDict] {
            return [[ : ]]
        }
    }
    
    class Country: List {
        override init() {
            super.init()
            title = Lng("seleNazi")
            page = "list-countries"
            keyName = "Country.name"
            keyId = "Country.id"
        }
        override func response(_ resultDict: JsonDict) -> [JsonDict] {
            return resultDict.array("countries") as! [JsonDict]
        }
    }
    
    class Region: List {
        override init() {
            super.init()
            title = Lng("seleRegi")
            page = "list-regions"
            keyName = "Region.name"
            keyId = "Region.id"
        }
        
        override func response(_ resultDict: JsonDict) -> [JsonDict] {
            return resultDict.array("regions") as! [JsonDict]
        }
    }
    
    class City: List {
        override init() {
            super.init()
            title = Lng("seleCity")
            page = "list-cities"
            keyName = "City.name"
            keyId = "City.id"
        }
        override func json () -> Dictionary <String, Any> {
            return [ "region_id": regionId ]
        }
        override func response(_ resultDict: JsonDict) -> [JsonDict] {
            return resultDict.array("cities") as! [JsonDict]
        }
    }
    
    class Affiliated: List {
        override init() {
            super.init()
            title = Lng("affiList")
            page = "list-enci-associations"
            keyName = "Association.business_name"
            keyId = "Association.id"
        }
        func json (filter: String) -> Dictionary <String, Any> {
            return  [ "business_name": filter ]
        }
        override func response(_ resultDict: JsonDict) -> [JsonDict] {
            return resultDict.array("enci_groups") as! [JsonDict]
        }
    }

}
    // MARK: table view
    
extension UserListCtrl: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        cell.textLabel?.font = .withSize(20)
        cell.textLabel?.textColor = .myBlue
        cell.textLabel?.textAlignment = .center
        
        let dic = dataArray[indexPath.row] as! JsonDict
        cell.textLabel?.text = dic.string((subClass?.keyName)!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let dic = dataArray[indexPath.row] as! JsonDict
        delegate?.userListDelegate(type: listType,
                                        id: dic.string((subClass?.keyId)!),
                                        name: dic.string((subClass?.keyName)!))

        switch listType {
        case .regionAndCity :
            listType = .cities
            selectClass()
            subClass?.regionId = dic.string(Region().keyId)
            loadData()
            return
        default :
            break
        }
        _ = navigationController?.popViewController(animated: true)
    }
}

    // MARK:- Search

extension UserListCtrl {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            dataArray = totalArray
        } else {
            let field = subClass?.keyName
            let predicate = NSPredicate.init(format: "%K contains[cd] %@", field!, srchBar.text!)
            dataArray = totalArray.filter { predicate.evaluate(with: $0) };
        }
        tableView.reloadData()
    }
}

