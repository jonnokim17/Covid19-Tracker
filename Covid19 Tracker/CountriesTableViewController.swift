//
//  ViewController.swift
//  Covid19 Tracker
//
//  Created by Jonathan Kim on 3/17/20.
//  Copyright © 2020 jonno. All rights reserved.
//

import UIKit

class CountriesTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!    
    var covidDataArray = [CovidData]()
    var filteredCountries = [CovidData]()
    
    lazy var searchController: UISearchController = {
        let s = UISearchController(searchResultsController: nil)
        s.searchResultsUpdater = self
        s.obscuresBackgroundDuringPresentation = false
        s.searchBar.placeholder = "Search Countries"
        s.searchBar.sizeToFit()
        s.searchBar.searchBarStyle = .prominent
//        s.searchBar.scopeButtonTitles = ["All", "Most Cases", "Most Deaths", "Most Recovered"]
        s.searchBar.delegate = self
        
        return s
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)

        tableView.refreshControl = refreshControl
                
        getCovidDataAndRefreshData()
    }
    
    @objc private func refreshTableView() {
        getCovidDataAndRefreshData()
    }
    
    private func getCovidDataAndRefreshData() {
        CovidDataClient.shared.getCovidData { [weak self] (result) in
            switch result {
            case .success(let covidDataArray):
                self?.covidDataArray = covidDataArray
            case .failure(let error):
                print(error)
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    private func filteredContentForSearchedText(searchText: String, scope: String = "All") {
        filteredCountries = covidDataArray.filter({ (covidData: CovidData) -> Bool in
            let doesCategoryMatch = (scope == "All")
            
            if isSearchBarEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && covidData.country.lowercased().contains(searchText.lowercased())
            }
        })
        
        tableView.reloadData()
    }
    
    private func isSearchBarEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func isFiltering() -> Bool {
//        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!isSearchBarEmpty())
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "countryDetailSegue" {
            guard let detailVC = segue.destination as? CountryDetailViewController else { return }
            
            if let data = sender as? [String: Any] {
                if let covidData = data["selectedCountry"] as? CovidData {
                    detailVC.covidData = covidData
                }
            }
        }
    }
}

extension CountriesTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredCountries.count
        }
        return covidDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath)
        
        let currentData: CovidData
        
        if isFiltering() {
            currentData = filteredCountries[indexPath.row]
        } else {
            currentData = covidDataArray[indexPath.row]
        }
        
        cell.textLabel?.text = currentData.country
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentData: CovidData
        if isFiltering() {
            currentData = filteredCountries[indexPath.row]
        } else {
            currentData = covidDataArray[indexPath.row]
        }
        
        let senderData: [String : Any] = ["selectedCountry": currentData]
        performSegue(withIdentifier: "countryDetailSegue", sender: senderData)
    }
}

extension CountriesTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let searchText = searchBar.text else { return }
//        guard let scopes = searchBar.scopeButtonTitles else { return }
        filteredContentForSearchedText(searchText: searchText)
    }
}

extension CountriesTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
//        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        
        guard let searchText = searchController.searchBar.text else { return }
        filteredContentForSearchedText(searchText: searchText)
    }
}
