//
//  Categorie.swift
//  Coctails
//
//  Created by Roma Filipenko on 04.04.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import Foundation

struct Category: Codable, Equatable {
    let category: String
    
    enum CodingKeys: String, CodingKey {
        case category = "strCategory"
    }
}

struct CategoryResponce: Codable {
    let categories: [Category]
    
    enum CodingKeys: String, CodingKey {
        case categories = "drinks"
    }
}
