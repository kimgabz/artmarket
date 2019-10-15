//
//  CartItemCell.swift
//  ArtMarket
//
//  Created by Kim Harold Gabiana on 14/10/19.
//  Copyright © 2019 Kim Harold Gabiana. All rights reserved.
//

import UIKit

protocol CartItemDelegate : class {
    func removeItem(product: Product)
}

class CartItemCell: UITableViewCell {

    // Outlet
    @IBOutlet weak var productImg: RoundedImageView!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var trashBtn: UIButton!
    
    // Variables
    private var item: Product!
    weak var delegate : CartItemDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func trashBt(_ sender: Any) {
        delegate?.removeItem(product: item)
    }
    
    func configureCell(product: Product, delegate: CartItemDelegate) {
        self.delegate = delegate
        self.item = product

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency

        if let price = formatter.string(from: product.price as NSNumber) {
            productLabel.text = "\(product.name) \(price)"
        }

        if let url = URL(string: product.imageUrl) {
            productImg.kf.setImage(with: url)
        }
        
    }

}
