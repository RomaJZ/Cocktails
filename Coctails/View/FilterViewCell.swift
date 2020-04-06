//
//  FilterViewCell.swift
//  Coctails
//
//  Created by Roma Filipenko on 04.04.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import UIKit
import SnapKit

class FilterViewCell: UITableViewCell {

    private var categoryNameLabel = UILabel()
    
    weak var filterCellViewModel: FilterViewCellViewModel? {
        didSet {
            guard let filterCellViewModel = filterCellViewModel else { return }
            categoryNameLabel.text = filterCellViewModel.name
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
       super.setSelected(selected, animated: animated)
        
        accessoryType = selected ? .checkmark : .none
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(categoryNameLabel)
        configureCategoryNameLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCategoryNameLabel() {
        
        categoryNameLabel.numberOfLines = 0
        categoryNameLabel.font = .boldSystemFont(ofSize: 20)
        
        categoryNameLabel.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.centerY.equalTo(contentView)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).inset(20)
        }
    }
}
