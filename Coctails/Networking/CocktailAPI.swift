//
//  CocktailAPI.swift
//  Coctails
//
//  Created by Roma Filipenko on 05.04.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import Foundation
import Moya

//MARK: APIError

enum APIError: Error {
    
    case badResponce, jsonDecoder
}

class CocktailAPI {
    
    //MARK: Properties
    
    private let cocktailProvider = MoyaProvider<CocktailService>()
    
    //MARK: Categories Fetching
    
    func fetchCocktailCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        
        cocktailProvider.request(.loadCocktailsCategories) { result in
            
            switch result {
            case .success(let responce):
                
                guard let response = responce.response, 200..<300 ~= response.statusCode else {
                    completion(.failure(APIError.badResponce))
                    return
                }
                
                guard let categoriesResponce = try? JSONDecoder().decode(CategoryResponce.self, from: responce.data) else {
                    completion(.failure(APIError.jsonDecoder))
                    return
                }
                
                DispatchQueue.main.async {
                    completion(.success(categoriesResponce.categories))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    //MARK: Cocktails Fetching
    
    func fetchCocktails(category: String, completion: @escaping (Result<[Cocktail], Error>) -> Void) {
        
        cocktailProvider.request(.loadCocktailsByCategory(category: category)) { result in
            
            switch result {
            case .success(let responce):
                
                guard let response = responce.response, 200..<300 ~= response.statusCode else {
                    completion(.failure(APIError.badResponce))
                    return
                }
                
                guard let cocktailsResponce = try? JSONDecoder().decode(CocktailResponce.self, from: responce.data) else {
                    completion(.failure(APIError.jsonDecoder))
                    return
                }
                
                DispatchQueue.main.async {
                    completion(.success(cocktailsResponce.cocktails))
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
