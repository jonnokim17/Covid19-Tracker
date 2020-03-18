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
        casesLabel.text = "Total Cases: \(covidData.cases.withCommas())"
        todaysCasesLabel.text = "Today's Cases: \(covidData.todayCases.withCommas())"
        deathsLabel.text = "Deaths: \(covidData.deaths.withCommas())"
        todaysDeathLabel.text = "Today's Death: \(covidData.todayDeaths.withCommas())"
        recoveredLabel.text = "Recovered: \(covidData.recovered.withCommas())"
        activeLabel.text = "Active: \(covidData.active.withCommas())"
        criticalCasesLabel.text = "Confirmed Cases: \(covidData.critical.withCommas())"
    }
}
