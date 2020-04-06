//
//  TableViewCell.swift
//  Coctails
//
//  Created by Roma Filipenko on 04.04.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage

class TableViewCell: UITableViewCell {
    
    private var photoImageView = UIImageView()
    private var photoTitleLabel = UILabel()

    weak var tableCellViewModel: TableViewCellViewModel? {
        willSet(viewModel) {
            guard let viewModel = viewModel else { return }
            photoTitleLabel.text = viewModel.name
            let url = viewModel.imageURL
            photoImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "imagePlaceholder"), options: .highPriority)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(photoImageView)
        contentView.addSubview(photoTitleLabel)
        
        configurePhotoImageView()
        configurePhotoTitleLable()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configurePhotoImageView() {
        photoImageView.snp.makeConstraints { make in
            make.height.width.equalTo(100)
            make.centerY.equalTo(contentView)
            make.leading.equalTo(contentView).offset(20)
        }
    }
    
    private func configurePhotoTitleLable() {
        
        photoTitleLabel.numberOfLines = 0
        photoTitleLabel.font = .boldSystemFont(ofSize: 15)
        
        photoTitleLabel.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.centerY.equalTo(contentView)
            make.leading.equalTo(photoImageView.snp.trailing).offset(20)
            make.trailing.equalTo(contentView).inset(20)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animate(isHighlighted: true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animate(isHighlighted: false)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animate(isHighlighted: false)
    }

    private func animate(isHighlighted: Bool, completion: ((Bool) -> Void)?=nil) {
        let animationOptions: UIView.AnimationOptions = [.allowUserInteraction]
        if isHighlighted {
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 6,
                           options: animationOptions, animations: {
                            self.transform = .init(scaleX: 0.9, y: 0.9)
            }, completion: completion)
        } else {
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 6,
                           options: animationOptions, animations: {
                            self.transform = .identity
            }, completion: completion)
        }
    }
}
