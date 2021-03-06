//
//  TableViewController.swift
//  Coctails
//
//  Created by Roma Filipenko on 04.04.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import UIKit
import SnapKit
import MBProgressHUD

class TableViewController: UITableViewController {
    
    //MARK: Properties
    
    private let cellID = "cellID"
    private let filterButton = UIButton(type: .system)
    var filterDidChanged = false
    private var canFetchMore = true
    var sectionIndex = 0
    
    private let tableViewModel = TableViewModel()
    var filterViewModel: FilterViewModel?
    var selectedCategories: [Category] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showHUD(progressLabel: "Loading...")
        configureTableView()
        configureNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        updateTableView()
        
        if filterDidChanged {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIView.animate(withDuration: 1) {
                    self.scrollToTop()
                }
            }
            filterDidChanged = false
            sectionIndex = 0
        }
    }
    
    //MARK: Configure ProgressHUD
    
    func showHUD(progressLabel:String){
        DispatchQueue.main.async{
            let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            progressHUD.label.text = progressLabel
        }
    }

    func dismissHUD(isAnimated:Bool) {
        DispatchQueue.main.async{
            MBProgressHUD.hide(for: self.view, animated: isAnimated)
        }
    }
    
    //MARK: Scroll to top
    
    private func scrollToTop() {
        guard tableView.numberOfSections != 0 else { return }
        let topRow = IndexPath(row: 0, section: 0)
                               
        self.tableView.scrollToRow(at: topRow,
                                   at: .top,
                                   animated: true)
    }
    
    //MARK: Configure TableView
    
    private func loadingProgress() {
        
        tableViewModel.showLoading = {
            if !self.tableViewModel.isLoading {
                self.dismissHUD(isAnimated: true)
            }
        }
        tableViewModel.showError = { error in
            print(error)
        }
        tableViewModel.reloadData = {
            self.tableView.reloadData()
        }
    }
    
    private func configureTableView() {
        
        view.backgroundColor = .white
        tableView.register(TableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.rowHeight = 120
        
        tableViewModel.startLoadingData()
        loadingProgress()
    }
    
    //MARK: Update TableView
    
    private func updateTableView() {

        showHUD(progressLabel: "Loading...")
        
        if selectedCategories.isEmpty {
            filterButton.isSelected = false
            tableViewModel.selectedCocktails = [:]
        } else {
            filterButton.isSelected = true
        }
        tableViewModel.selectedCategories = selectedCategories
        loadingProgress()
    }
    
    //MARK: Configure NavigationBar
    
    private func configureNavigationBar() {
        
        navigationItem.title = "Drinks"
        
        filterButton.setImage(#imageLiteral(resourceName: "filter"), for: .normal)
        filterButton.setImage(#imageLiteral(resourceName: "filter"), for: .selected)
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        filterButton.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: filterButton)
    }
    
    //MARK: Segue to FilterVC
    
    @objc private func filterButtonTapped() {
        let filterVC = FilterViewController()
        if filterViewModel != nil {
            filterVC.filterViewModel = filterViewModel
        } else {
            filterVC.filterViewModel = tableViewModel.filterViewModel()
        }
        navigationController?.pushViewController(filterVC, animated: true)
    }

    // MARK: - TableView DataSource
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerLabel = UILabel()
        if selectedCategories.isEmpty {
            headerLabel.text = "   \(tableViewModel.categories[section].category)"
        } else {
            headerLabel.text = "   \(tableViewModel.sortedSelectedCategories[section].category)"
        }
        headerLabel.font = .some(UIFont(name: "AppleSDGothicNeo-Thin", size: 20)!)
        tableView.sectionHeaderHeight = 30
        headerLabel.backgroundColor = .some(UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1))
        return headerLabel
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewModel.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewModel.numberOfRows(in: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? TableViewCell
        
        guard let tableViewCell = cell else { return UITableViewCell() }
        
        let cellViewModel = tableViewModel.cellViewModel(for: indexPath)
        
        tableViewCell.tableCellViewModel = cellViewModel
        
        tableViewCell.selectionStyle = .none
        return tableViewCell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var categories: [Category] = []
        if selectedCategories.isEmpty {
            categories = tableViewModel.categories
        } else {
            categories = selectedCategories
        }
        
        if sectionIndex < categories.count {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            if offsetY > contentHeight - (2 * scrollView.frame.height) {
                if canFetchMore {
                    canFetchMore = false
                    tableViewModel.scrollBeginFetch(from: sectionIndex)
                    tableViewModel.reloadData = {
                        self.tableView.reloadData()
                        self.canFetchMore = true
                    }
                    sectionIndex += 1
                }
            }
        }
    }
}
