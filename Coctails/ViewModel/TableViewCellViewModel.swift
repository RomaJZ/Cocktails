//
//  TableViewCellViewModel.swift
//  Coctails
//
//  Created by Roma Filipenko on 05.04.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import UIKit

class TableViewCellViewModel {
    
    private var cocktail: Cocktail
    
    var name: String {
        return cocktail.name
    }
    
    var imageURL: URL {
        return cocktail.thumbUrl
    }
    
    init(cocktail: Cocktail) {
        self.cocktail = cocktail
    }
}
