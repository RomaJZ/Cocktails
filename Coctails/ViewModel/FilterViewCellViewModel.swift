//
//  FilterViewCellViewModel.swift
//  Coctails
//
//  Created by Roma Filipenko on 05.04.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import Foundation

class FilterViewCellViewModel {
    
    private let category: Category
    
    var name: String {
        return category.category
    }
    
    init(category: Category) {
        self.category = category
    }
}
