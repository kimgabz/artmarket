//
//  TableViewCell.swift
//  ArtMarket
//
//  Created by Kim Harold Gabiana on 7/10/19.
//  Copyright © 2019 Kim Harold Gabiana. All rights reserved.
//

import UIKit
import Kingfisher

class ProductCell: UITableViewCell {

    // Outlet
    @IBOutlet weak var productImg: RoundedImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var favoriteBt: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    func configureCell(product: Product) {
        productTitle.text = product.name
        
        if let url = URL(string: product.imageUrl) {
            productImg.kf.setImage(with: url)
        }
    }
    @IBAction func addToCartBt(_ sender: Any) {
    }
    
    @IBAction func favoriteBt(_ sender: Any) {
    }
    
}
