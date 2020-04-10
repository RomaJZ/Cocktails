//
//  DetailViewController.swift
//  Coctails
//
//  Created by Roma Filipenko on 04.04.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import UIKit
import SnapKit

class FilterViewController: UIViewController {

    //MARK: Properties
    
    private let cellID = "cellID"
    var filterViewModel: FilterViewModel?
    private let tableView = UITableView()
    private let applyFilterButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureFilterButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        guard filterViewModel != nil else { return }
        tableView.reloadData()
    }
    
    //MARK: Configure TableView
    
    private func configureTableView() {
        
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.register(FilterViewCell.self, forCellReuseIdentifier: cellID)
        tableView.rowHeight = 50
        tableView.allowsMultipleSelection = true
        
        tableView.snp.makeConstraints { make in
            make.width.centerX.top.equalTo(view)
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    //MARK: Configure FilterButton
    
    private func configureFilterButton() {
        
        view.addSubview(applyFilterButton)
        applyFilterButton.backgroundColor = .white
        applyFilterButton.setTitle("Apply Filters", for: .normal)
        applyFilterButton.setTitleColor(.black, for: .normal)
        applyFilterButton.setTitleColor(.lightGray, for: .disabled)
        applyFilterButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        applyFilterButton.layer.cornerRadius = 10
        applyFilterButton.layer.borderWidth = 1
        applyFilterButton.layer.borderColor = UIColor.black.cgColor
        applyFilterButton.addTarget(self, action: #selector(applyFilterButtonTapped(button:)), for: .touchUpInside)
        
        applyFilterButton.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(50)
            make.top.equalTo(tableView.snp.bottom).offset(50)
            make.bottom.centerX.equalTo(view).inset(30)
        }
    }
    
    //MARK: FilterButton Animation
    
    private func configureAnimationForButton(button: UIButton) {
        
        button.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        UIView.animate(withDuration: 0.5,
                       delay: 0.5,
                       usingSpringWithDamping: CGFloat(0.5),
                       initialSpringVelocity: CGFloat(6.0),
                       options: .allowUserInteraction,
                       animations: {
                            button.transform = CGAffineTransform.identity
                       } )
    }
    
    //MARK: Segue to TableVC
    
    @objc private func applyFilterButtonTapped(button: UIButton) {
        configureAnimationForButton(button: button)
        
        guard let filterViewModel = filterViewModel else { return }
        filterViewModel.previouslySelectedCategories = filterViewModel.selectedCategories
        
        guard let tableViewController = navigationController?.viewControllers.first as? TableViewController else { return }
        
        tableViewController.filterDidChanged = applyFilterButton.isEnabled
        tableViewController.selectedCategories = filterViewModel.selectedCategories
        tableViewController.filterViewModel = filterViewModel
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - TableView DataSource
    
extension FilterViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let filterViewModel = filterViewModel else { return 0 }
        return filterViewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? FilterViewCell
        
        guard let filterViewCell = cell, let filterViewModel = filterViewModel else { return UITableViewCell() }
        
        let filterCellViewModel = filterViewModel.cellViewModel(for: indexPath)
        
        filterViewCell.filterCellViewModel = filterCellViewModel
        
        filterViewCell.selectionStyle = .none
        return filterViewCell
    }
}

// MARK: - TableView Delegate

extension FilterViewController: UITableViewDelegate {
    
    func checkApplyButtonState() {
        guard let filterViewModel = filterViewModel else { return }
        if filterViewModel.previouslySelectedCategories != filterViewModel.selectedCategories{
            applyFilterButton.isEnabled = true
        } else {
            applyFilterButton.isEnabled = false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let filterViewModel = filterViewModel else { return }
        
        filterViewModel.selectCategory(for: indexPath)
        checkApplyButtonState()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let filterViewModel = filterViewModel else { return }
        
        filterViewModel.removeCategoryFromSelection(for: indexPath)
        checkApplyButtonState()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let filterViewModel = filterViewModel else { return }
        guard !filterViewModel.previouslySelectedCategories.isEmpty else {                                                   applyFilterButton.isEnabled = true
                                                                  return }
        
        if filterViewModel.previouslySelectedCategories.contains(filterViewModel.categories[indexPath.row]) {
            applyFilterButton.isEnabled = false
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
}
