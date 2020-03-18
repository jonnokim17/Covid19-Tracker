//
//  CountryDetailViewController.swift
//  Covid19 Tracker
//
//  Created by Jonathan Kim on 3/17/20.
//  Copyright © 2020 jonno. All rights reserved.
//

import UIKit

class CountryDetailViewController: UIViewController {
    
    @IBOutlet weak var casesLabel: UILabel!
    @IBOutlet weak var todaysCasesLabel: UILabel!
    @IBOutlet weak var deathsLabel: UILabel!
    @IBOutlet weak var todaysDeathLabel: UILabel!
    @IBOutlet weak var recoveredLabel: UILabel!
    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var criticalCasesLabel: UILabel!
    
    var covidData: CovidData!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        title = covidData.country        
        casesLabel.text = "Total Cases: \(covidData.cases.withCommas())"
        todaysCasesLabel.text = "Today's Cases: \(covidData.todayCases.withCommas())"
        deathsLabel.text = "Deaths: \(covidData.deaths.withCommas())"
        todaysDeathLabel.text = "Today's Death: \(covidData.todayDeaths.withCommas())"
        recoveredLabel.text = "Recovered: \(covidData.recovered.withCommas())"
        activeLabel.text = "Active: \(covidData.active.withCommas())"
        criticalCasesLabel.text = "Confirmed Cases: \(covidData.critical.withCommas())"
        
        if CovidDataClient.shared.watchlistData.contains(where: { $0.country == covidData.country }) {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @IBAction func onAddToWatchlist(_ sender: UIBarButtonItem) {
        if CovidDataClient.shared.watchlistData.isEmpty {
            CovidDataClient.shared.watchlistData = [covidData]
        } else {
            var currentWatchlist = CovidDataClient.shared.watchlistData
            currentWatchlist.append(covidData)
            CovidDataClient.shared.watchlistData = currentWatchlist
        }
        
        let alertController = UIAlertController(title: "Added to Watchlist", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
