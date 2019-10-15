//
//  LoginVC.swift
//  ArtMarket
//
//  Created by Kim Harold Gabiana on 4/10/19.
//  Copyright © 2019 Kim Harold Gabiana. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    @IBOutlet weak var emailTx: UITextField!
    @IBOutlet weak var pswdTx: UITextField!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func forgotPswdBt(_ sender: Any) {
        let vc = ForgotPasswordVC()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)

    }

    @IBAction func loginBt(_ sender: Any) {
        guard let email = emailTx.text, email.isNotEmpty,
            let password = pswdTx.text, password.isNotEmpty
        else {
                simpleAlert(title: "Error", msg: "Please fill out all fields")
                return
        }

        activityIndicator.startAnimating()
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in

            if let error = error {
                debugPrint(error.localizedDescription)
                Auth.auth().handleFireAuthError(error: error, vc: self)
                self.activityIndicator.stopAnimating()
                return
            }
            self.activityIndicator.stopAnimating()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func newUserBt(_ sender: Any) {
    }
    
    @IBAction func contGuestBt(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
