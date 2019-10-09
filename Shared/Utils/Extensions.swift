//
//  Extensions.swift
//  ArtMarket
//
//  Created by Kim Harold Gabiana on 4/10/19.
//  Copyright © 2019 Kim Harold Gabiana. All rights reserved.
//

//import Foundation
import UIKit
import Firebase

extension String {
    var isNotEmpty : Bool {
        return !isEmpty
    }
}

extension UIViewController {
    
    func simpleAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
