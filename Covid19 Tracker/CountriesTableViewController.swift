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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
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
        return covidDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath)
        let covidData = covidDataArray[indexPath.row]
        
        cell.textLabel?.text = covidData.country
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCountry = covidDataArray[indexPath.row]
        let senderData: [String : Any] = ["selectedCountry": selectedCountry]
        performSegue(withIdentifier: "countryDetailSegue", sender: senderData)
    }
}

