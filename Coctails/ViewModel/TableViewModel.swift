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
                let category = categories[0].category
                group.enter()
                loadCocktails(from: category) { [weak self] cocktails in
                    self?.cocktails[category] = cocktails
                }
        }
    }
    var selectedCategories: [Category] = [] {
        didSet {
            selectedCocktails = [:]
            scrollBeginFetch(from: 0)
        }
    }
    var sortedSelectedCategories: [Category] {
        
        var indecies: [Int] = []
        for category in selectedCategories {
            indecies.append(categories.firstIndex(of: category)!)
        }
        return zip(selectedCategories, indecies).sorted(by: { $0.1 < $1.1 }).map( {$0.0} )
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
    
    private func loadCocktails(from category: String, completion: @escaping ([Cocktail]) -> Void) {
        
        guard !categories.isEmpty else { return }

        fetcher.fetchCocktails(category: category) { [weak self] result in
            
            switch result {
                
            case .success(let cocktails):
                completion(cocktails)
                
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
            let category = sortedSelectedCategories[section].category
            guard let selectedCategoryCocktails = selectedCocktails[category] else { return 0 }
            return selectedCategoryCocktails.count
        }
    }
    
    func scrollBeginFetch(from section: Int) {
        
        DispatchQueue.global(qos: .background).async(group: group) {
            guard !self.categories.isEmpty else { return }
            var category: String
            if self.selectedCategories.isEmpty == true {
                category = self.categories[section].category
                if self.cocktails.contains(where: { $0.key == category }) == false {
                    self.group.enter()
                    self.loadCocktails(from: category) { [weak self] cocktails in
                        self?.cocktails[category] = cocktails
                    }
                }
            } else {
                category = self.sortedSelectedCategories[section].category
                if self.cocktails.contains(where: { $0.key == category }) == false {
                    self.group.enter()
                    self.loadCocktails(from: category) { [weak self] cocktails in
                        self?.selectedCocktails[category] = cocktails
                    }
                } else {
                    self.selectedCocktails[category] = self.cocktails[category]
                }
            }
        }
        group.notify(queue: .main) {
            self.isLoading = false
            self.reloadData?()
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
            let category = sortedSelectedCategories[indexPath.section].category
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
