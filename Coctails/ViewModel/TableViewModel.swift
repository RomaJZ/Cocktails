//
//  TableViewModel.swift
//  Coctails
//
//  Created by Roma Filipenko on 05.04.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import Foundation

class TableViewModel {
    
    //MARK: Properties
    
    private let fetcher = CocktailAPI()
    
    private(set) var categories: [Category] = [] {
        didSet {
            for category in categories {
                loadCocktails(from: category.category)
            }
        }
    }
    var selectedCategories: [Category] = [] {
        didSet {
            selectedCocktails = [:]
            for category in selectedCategories {
                selectedCocktails[category.category] = cocktails[category.category]
            }
        }
    }
    var selectedCocktails: [String:[Cocktail]] = [:]
    
    private var cocktails: [String:[Cocktail]] = [:]

    var isLoading: Bool = false {
        didSet {
            showLoading?()
        }
    }

    var showLoading: (() -> Void)?
    var reloadData: (() -> Void)?
    var showError: ((Error) -> Void)?
    let group = DispatchGroup()
    
    //MARK: Loading Data
    
    func startLoadingData() {
        
        isLoading = true
        loadCocktailCategories()
        
        group.notify(queue: .main) {
            self.isLoading = false
            self.reloadData?()
        }
    }
    
    //MARK: Loading Categories
    
    private func loadCocktailCategories() {
        
        group.enter()
        fetcher.fetchCocktailCategories { [weak self] result in
            
            switch result {
                
            case .success(let categories):
                self?.categories = categories
                
            case .failure(let error):
                self?.showError?(error)
            }
            self?.group.leave()
        }
    }
    
    //MARK: Loading Cocktails
    
    private func loadCocktails(from category: String) {
        
        guard !categories.isEmpty else { return }
        
        group.enter()
        fetcher.fetchCocktails(category: category) { [weak self] result in
            
            switch result {
                
            case .success(let cocktails):
                self?.cocktails[category] = cocktails
                
            case .failure(let error):
                self?.showError?(error)
            }
            self?.group.leave()
        }
    }
    
    //MARK: TableView UI
    
    func numberOfSections() -> Int {
        guard !selectedCategories.isEmpty else { return categories.count }
        return selectedCategories.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        if selectedCocktails.isEmpty {
            guard !cocktails.isEmpty else { return 0 }
            let category = categories[section].category
            guard let categoryCocktails = cocktails[category] else { return 0 }
            return categoryCocktails.count
        } else {
            let category = selectedCategories[section].category
            guard let selectedCategoryCocktails = selectedCocktails[category] else { return 0 }
            return selectedCategoryCocktails.count
        }
    }
    
    //MARK: TableViewCell UI
    
    func cellViewModel(for indexPath: IndexPath) -> TableViewCellViewModel? {
        if selectedCocktails.isEmpty {
            let category = categories[indexPath.section].category
            guard !cocktails.isEmpty, let categoryCocktails = cocktails[category] else { return nil }
            let cocktail = categoryCocktails[indexPath.row]
            return TableViewCellViewModel(cocktail: cocktail)
        } else {
            let category = selectedCategories[indexPath.section].category
            guard let selectedCategoryCocktails = selectedCocktails[category] else { return nil }
            let cocktail = selectedCategoryCocktails[indexPath.row]
            return TableViewCellViewModel(cocktail: cocktail)
        }
    }
    
    //MARK: FilterView UI
    
    func filterViewModel() -> FilterViewModel {
        let filterCategories = categories
        return FilterViewModel(categories: filterCategories)
    }
}
