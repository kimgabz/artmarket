//
//  Constants.swift
//  ArtMarket
//
//  Created by Kim Harold Gabiana on 4/10/19.
//  Copyright © 2019 Kim Harold Gabiana. All rights reserved.
//

import Foundation
import UIKit

struct Storyboard {
    static let LoginStoryboard = "LoginStoryBoard"
}

struct StoryboardId {
    static let LoginVC = "loginVC"
}

struct AppImages {
    static let greenCheck = "green_check"
    static let redCheck = "red_check"
}

struct AppColors {
    static let Blue = #colorLiteral(red: 0, green: 0.3450980484, blue: 0.8156862855, alpha: 1)
    static let Red = #colorLiteral(red: 0.8739202619, green: 0.4776076674, blue: 0.385545969, alpha: 1)
    static let OffWhite = #colorLiteral(red: 0.9626371264, green: 0.959995091, blue: 0.9751287103, alpha: 1)
}

struct Identifiers {
    static let CategoryCell = "CategoryCell"
    static let ProductCell = "ProductCell"
    
}

struct Segues {
    static let ToProducts = "toProductsVC"
    static let ToAddEditCategory = "ToAddEditCategory"
    static let toEditCategory = "toEditCategory"
    static let toAddEditProduct = "toAddEditProduct"
}
