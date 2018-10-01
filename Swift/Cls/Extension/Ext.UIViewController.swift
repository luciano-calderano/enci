//
//  JsonDictExtension.swift
//  Lc
//
//  Created by Luciano Calderano on 26/10/16.
//  Copyright © 2016 Kanito. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert (_ title:String, message: String,
                    cancelBlock:((UIAlertAction) -> ())? = nil,
                    okBlock:((UIAlertAction) -> ())?) {
        
        let alert = UIAlertController(title: title as String, message: message as String, preferredStyle: .alert)
        if cancelBlock != nil {
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: cancelBlock))
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: okBlock))
        
        present(alert, animated: true, completion: nil)
    }
}
