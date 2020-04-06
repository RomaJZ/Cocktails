//
//  FilterViewModel.swift
//  Coctails
//
//  Created by Roma Filipenko on 05.04.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import Foundation

class FilterViewModel {
    
    var categories: [Category]
    var selectedCategories: [Category] = []
    var previouslySelectedCategories: [Category] = []
    
    init(categories: [Category]) {
        self.categories = categories
    }
    
    //MARK: FilterView UI
    
    func numberOfRows() -> Int {
        guard !categories.isEmpty else { return 0 }
        return categories.count
    }
    
    func selectCategory(for indexPath: IndexPath) {
        selectedCategories.append(categories[indexPath.row])
    }
    
    func removeCategoryFromSelection(for indexPath: IndexPath) {
        
        guard let categoryIndexToRemove = selectedCategories.firstIndex(where: { $0 == categories[indexPath.row] }) else { return }
        
        selectedCategories.remove(at: categoryIndexToRemove)
    }
    
    //MARK: FilterViewCell UI
    
    func cellViewModel(for indexPath: IndexPath) -> FilterViewCellViewModel? {
        let category = categories[indexPath.row]
        return FilterViewCellViewModel(category: category)
    }
}
