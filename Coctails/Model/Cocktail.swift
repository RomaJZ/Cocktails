//
//  Profile.swift
//  Coctails
//
//  Created by Roma Filipenko on 04.04.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import Foundation

struct Cocktail: Codable {
    let name: String
    let thumbUrl: URL
    
    enum CodingKeys: String, CodingKey {
        case name = "strDrink"
        case thumbUrl = "strDrinkThumb"
    }
}

struct CocktailResponce: Codable {
    let cocktails: [Cocktail]
    
    enum CodingKeys: String, CodingKey {
        case cocktails = "drinks"
    }
}
