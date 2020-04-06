//
//  CocktailService.swift
//  Coctails
//
//  Created by Roma Filipenko on 05.04.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import Foundation
import Moya

private let url: String = "https://www.thecocktaildb.com/api/json/v1/1/"

enum CocktailService {
    case loadCocktailsCategories
    case loadCocktailsByCategory(category: String)
}

extension CocktailService: TargetType {
    
    var baseURL: URL {
        return URL(string: url)!
    }
    
    var path: String {
        switch self {
            
        case .loadCocktailsCategories:
            return "list.php"
            
        case .loadCocktailsByCategory(_):
            return "filter.php"
        }
    }
    
    var method: Moya.Method {
        switch self {
            
        case .loadCocktailsCategories, .loadCocktailsByCategory(_):
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
            
        case .loadCocktailsCategories:
            return .requestParameters(
                parameters: ["c" : "list"],
                encoding: URLEncoding.default)
        
        case .loadCocktailsByCategory(let category):
            return .requestParameters(
                parameters: ["c" : "\(category)"],
                encoding: URLEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
