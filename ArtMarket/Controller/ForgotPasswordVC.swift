//
//  ForgotPasswordVC.swift
//  ArtMarket
//
//  Created by Kim Harold Gabiana on 7/10/19.
//  Copyright © 2019 Kim Harold Gabiana. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordVC: UIViewController {

    // Outlets
    @IBOutlet weak var emailTx: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func cancelBt(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetBt(_ sender: Any) {
        guard let email = emailTx.text, email.isNotEmpty else {
            simpleAlert(title: "Error", msg: "Please enter email")
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                Auth.auth().handleFireAuthError(error: error, vc: self)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }

    }
}
