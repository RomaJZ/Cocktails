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
            selectedCocktails = []
            for category in selectedCategories {
                guard let index = categories.firstIndex(where: { $0.category == category.category }) else { return }
                selectedCocktails.append(cocktails[index])
            }
        }
    }
    var selectedCocktails: [[Cocktail]] = []
    
    private var cocktails: [[Cocktail]] = []

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
                self?.cocktails.append(cocktails)
                
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
        guard !cocktails.isEmpty else { return 0 }
        guard !selectedCocktails.isEmpty else { return cocktails[section].count }
        return selectedCocktails[section].count
    }
    
    //MARK: TableViewCell UI
    
    func cellViewModel(for indexPath: IndexPath) -> TableViewCellViewModel? {
        
        if selectedCocktails.isEmpty {
            let cocktail = cocktails[indexPath.section][indexPath.row]
            return TableViewCellViewModel(cocktail: cocktail)
        } else {
            let cocktail = selectedCocktails[indexPath.section][indexPath.row]
            return TableViewCellViewModel(cocktail: cocktail)
        }
    }
    
    //MARK: FilterView UI
    
    func filterViewModel() -> FilterViewModel {
        let filterCategories = categories
        return FilterViewModel(categories: filterCategories)
    }
}
