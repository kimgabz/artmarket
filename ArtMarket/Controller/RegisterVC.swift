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
            else {return}
        
        activityindicator.startAnimating()

        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in

            if let error = error {
                debugPrint(error)
                return
            }
            
            self.activityindicator.stopAnimating()
            print("Successfully registered new user")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}