//
//  RegisterVC.swift
//  ArtMarket
//
//  Created by Kim Harold Gabiana on 4/10/19.
//  Copyright © 2019 Kim Harold Gabiana. All rights reserved.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {

    // Outlets
    @IBOutlet weak var usernameTx: UITextField!
    @IBOutlet weak var emailTx: UITextField!
    @IBOutlet weak var pswdTx: UITextField!
    @IBOutlet weak var confirmPswdTx: UITextField!
    @IBOutlet weak var activityindicator: UIActivityIndicatorView!
    @IBOutlet weak var pswdCheckImg: UIImageView!
    @IBOutlet weak var confirmpswdCheckImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pswdTx.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        confirmPswdTx.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        // Do any additional setup after loading the view.
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let passTx = pswdTx.text else { return }
        
        if textField == confirmPswdTx {
            pswdCheckImg.isHidden = false
            confirmpswdCheckImg.isHidden = false
        }
        else {
            if passTx.isEmpty {
                pswdCheckImg.isHidden = true
                confirmpswdCheckImg.isHidden = true
                confirmPswdTx.text = ""
            }
        }
        
        if pswdTx.text == confirmPswdTx.text {
            pswdCheckImg.image = UIImage(named: AppImages.greenCheck)
            confirmpswdCheckImg.image = UIImage(named: AppImages.greenCheck)
        }
        else {
            pswdCheckImg.image = UIImage(named: AppImages.redCheck)
            confirmpswdCheckImg.image = UIImage(named: AppImages.redCheck)
        }
    }

    @IBAction func registerClicked(_ sender: Any) {
        guard let email = emailTx.text, email.isNotEmpty,
            let userName = usernameTx.text, userName.isNotEmpty,
            let password = pswdTx.text, password.isNotEmpty
        else {
            simpleAlert(title: "Error", msg: "Please fill out all fields")
            return
        }
        
        guard let confirmPass = confirmPswdTx.text, confirmPass == password else {
            simpleAlert(title: "Error", msg: "Passwords do not match")
            return
        }

        activityindicator.startAnimating()

//        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
//            if let error = error {
//                debugPrint(error.localizedDescription)
//                Auth.auth().handleFireAuthError(error: error, vc: self)
//                self.activityindicator.stopAnimating()
//                return
//            }
//
//            guard let fireUser = result?.user else { return }
//            let artUser = User.init(id: fireUser.uid, email: email, username: userName, stripeId: "")
//            // upload to Firestore
//            self.createFirestoreUser(user: artUser)
//        }

        guard let authUser = Auth.auth().currentUser else {
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        authUser.link(with: credential) { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                Auth.auth().handleFireAuthError(error: error, vc: self)
                self.activityindicator.stopAnimating()
                return
            }
            
            guard let fireUser = result?.user else { return }
            let artUser = User.init(id: fireUser.uid, email: email, username: userName, stripeId: "")
            // upload to Firestore
            self.createFirestoreUser(user: artUser)
        }

    }
    
    func createFirestoreUser(user: User) {
        // create document
        let newUserRef = Firestore.firestore().collection("users").document(user.id)
        
        // create model data
        let data = User.modelToData(user: user)
        
        // upload to Firestore
        newUserRef.setData(data, merge: true) { (error) in
            if let error = error {
                Auth.auth().handleFireAuthError(error: error, vc: self)
                debugPrint("Error signing in: \(error.localizedDescription)")
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        self.activityindicator.stopAnimating()
    }

}
