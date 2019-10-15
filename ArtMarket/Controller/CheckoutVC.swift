//
//  CheckoutVC.swift
//  ArtMarket
//
//  Created by Kim Harold Gabiana on 13/10/19.
//  Copyright © 2019 Kim Harold Gabiana. All rights reserved.
//

import UIKit
import Stripe
import FirebaseFunctions

class CheckoutVC: UIViewController, CartItemDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var paymentMethodBt: UIButton!
    @IBOutlet weak var shippingMethodBt: UIButton!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var processFeeLabel: UILabel!
    @IBOutlet weak var shippingCostLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Variables
    var paymentContext: STPPaymentContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        initPaymentInfo()
        setupStripeConfig()
    }
    
    fileprivate func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Identifiers.CartItemCell, bundle: nil), forCellReuseIdentifier: Identifiers.CartItemCell)
    }
    
    fileprivate func initPaymentInfo() {
        subtotalLabel.text = StripeCart.subtotal.penniesToFormattedCurrency()
        processFeeLabel.text = StripeCart.processingFees.penniesToFormattedCurrency()
        shippingCostLabel.text = StripeCart.shippingFees.penniesToFormattedCurrency()
        totalLabel.text = StripeCart.total.penniesToFormattedCurrency()
    }

    func setupStripeConfig() {
        let config = STPPaymentConfiguration.shared()
//        config.createCardSources = true
        config.requiredBillingAddressFields = .none
        config.requiredShippingAddressFields = [.postalAddress]

        let customerContext = STPCustomerContext(keyProvider: StripeApi)
        paymentContext = STPPaymentContext(customerContext: customerContext, configuration: config, theme: .default())

        paymentContext.paymentAmount = StripeCart.total
        paymentContext.delegate = self
        paymentContext.hostViewController = self
    }

    @IBAction func placeOrderBt(_ sender: Any) {
        paymentContext.requestPayment()
        activityIndicator.startAnimating()
    }

    @IBAction func paymentBt(_ sender: Any) {
        paymentContext.pushPaymentOptionsViewController()
    }

    @IBAction func shippingBt(_ sender: Any) {
        paymentContext.pushShippingViewController()
    }
    
    func removeItem(product: Product) {
        StripeCart.removeItemFromCart(item: product)
        tableView.reloadData()
        initPaymentInfo()
        paymentContext.paymentAmount = StripeCart.total
    }
}

extension CheckoutVC : STPPaymentContextDelegate {
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        let idempotency = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        
        let data: [String: Any] = [
            "total": StripeCart.total,
            "customerId": userService.user.stripeId,
            "idempotency": idempotency
        ]
        Functions.functions().httpsCallable("createCharge").call(data) { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "Error", msg: "Unable to make charge")
                completion(.error,error)
                return
            }
            
            StripeCart.clearCart()
            self.tableView.reloadData()
            self.initPaymentInfo()
            completion(.error, nil)
        }
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        // updating the selected payment method
        if let paymentMethod = paymentContext.selectedPaymentOption {
            paymentMethodBt.setTitle(paymentMethod.label, for: .normal)
        }
        else {
            paymentMethodBt.setTitle("Select Method", for: .normal)
        }
        // updating the selected shipping method
        if let shippingMethod = paymentContext.selectedShippingMethod {
            shippingMethodBt.setTitle(shippingMethod.label, for: UIControl.State.normal)
            StripeCart.shippingFees = Int(Double(truncating: shippingMethod.amount) * 100)
            initPaymentInfo()
        }
        else {
            shippingMethodBt.setTitle("Select Method", for: UIControl.State.normal)
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        activityIndicator.stopAnimating()
        
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        let retry = UIAlertAction(title: "Retry", style: UIAlertAction.Style.default) { (action) in
            self.paymentContext.retryLoading()
        }
        
        alertController.addAction(cancel)
        alertController.addAction(retry)
        present(alertController, animated: true, completion: nil)
    }
    
    // Deprecated
//    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
//
//        let idempotency = UUID().uuidString.replacingOccurrences(of: "-", with: "")
//
//        let data: [String: Any] = [
//            "total": StripeCart.total,
//            "customerId": userService.user.stripeId,
//            "idempotency": idempotency
//        ]
//        Functions.functions().httpsCallable("makeCharge").call(data) { (result, error) in
//            if let error = error {
//                debugPrint(error.localizedDescription)
//                self.simpleAlert(title: "Error", msg: "Unable to make charge")
//                completion(error)
//                return
//            }
//
//            StripeCart.clearCart()
//            self.tableView.reloadData()
//            self.initPaymentInfo()
//            completion(nil)
//        }
//    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        let title: String
        let message: String

        activityIndicator.stopAnimating()

        switch  status {
        case .error:
            title = "Error"
            message = error?.localizedDescription ?? ""
        case .success:
            title = "Success!"
            message = "Thank you for your purchase"
        case .userCancellation:
            return
        default:
            return
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        let upsGround = PKShippingMethod()
        upsGround.amount = 0
        upsGround.label = "UPS Ground"
        upsGround.detail = "Arrives in 3-5 days"
        upsGround.identifier = "ups_ground"
        
        let fedEx = PKShippingMethod()
        fedEx.amount = 6.99
        fedEx.label = "FedEx"
        fedEx.detail = "Arrives tomorrow"
        fedEx.identifier = "fedex"
        
        if address.country == "US" {
            completion(.valid, nil, [upsGround, fedEx], fedEx)
        }
        else {
            completion(.invalid, nil, nil, nil)
        }
    }
    

}

extension CheckoutVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StripeCart.cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.CartItemCell, for: indexPath) as? CartItemCell {
            
            let product = StripeCart.cartItems[indexPath.row]
            cell.configureCell(product: product, delegate: self)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
