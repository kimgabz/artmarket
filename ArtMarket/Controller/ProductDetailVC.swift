//
//  ProductDetailVC.swift
//  ArtMarket
//
//  Created by Kim Harold Gabiana on 9/10/19.
//  Copyright © 2019 Kim Harold Gabiana. All rights reserved.
//

import UIKit

class ProductDetailVC: UIViewController {
    
    // Outlet
    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var productTItle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productDesc: UILabel!
    @IBOutlet weak var bgView: UIVisualEffectView!
    
    // variable
    var product : Product!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        productTItle.text = product.name
        productDesc.text = product.productDescription
        
        if let url = URL(string: product.imageUrl) {
            productImg.kf.setImage(with: url)
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let price = formatter.string(from: product.price as NSNumber) {
            productPrice.text = price
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(keepShopBt(_:)))
        tap.numberOfTapsRequired = 1
        bgView.addGestureRecognizer(tap)
    }

    @objc func dismissProduct() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func addCartBt(_ sender: Any) {
        if userService.isGuest {
            self.simpleAlert(title: "Error", msg: "Please log-in to buy this product")
            return
        }

        // add product to cart
        StripeCart.addItemToCart(item: product)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func keepShopBt(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
