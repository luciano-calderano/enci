//
//  MYExt.ImageView.swift
//  LcLib
//
//  Created by utente on 23/03/18.
//  Copyright © 2018 luciano. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

extension UIImageView {
    func withUrl(_ url: String, placeHolder: UIImage?, result:@escaping (Bool) -> ()) {
        guard let imgUrl = URL.init(string: url) else {
            self.image = placeHolder
            result (false)
            return
        }
        
        af_setImage(withURL: imgUrl,
                    placeholderImage: placeHolder,
                    filter: nil,
                    progress: nil,
                    progressQueue: DispatchQueue.main,
                    imageTransition: .noTransition,
                    runImageTransitionIfCached: false) {
                        (response) in
                        result (response.result.value != nil)
        }
    }
}

