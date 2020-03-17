//
//  CovidDataClient.swift
//  Covid19 Tracker
//
//  Created by Jonathan Kim on 3/17/20.
//  Copyright © 2020 jonno. All rights reserved.
//

import Foundation

struct CovidData {
    let country: String
    let cases: Int
    let todayCases: Int
    let deaths: Int
    let todayDeaths: Int
    let recovered: Int
    let active: Int
    let critical: Int
    
    init(json: [String: Any]) {
        let country = json["country"] as? String ?? ""
        let cases = json["cases"] as? Int ?? 0
        let todayCases = json["todayCases"] as? Int ?? 0
        let deaths = json["deaths"] as? Int ?? 0
        let todayDeaths = json["todayDeaths"] as? Int ?? 0
        let recovered = json["recovered"] as? Int ?? 0
        let active = json["active"] as? Int ?? 0
        let critical = json["critical"] as? Int ?? 0
        
        self.country = country
        self.cases = cases
        self.todayCases = todayCases
        self.deaths = deaths
        self.todayDeaths = todayDeaths
        self.recovered = recovered
        self.active = active
        self.critical = critical
    }
}

class CovidDataClient {
    static let shared = CovidDataClient()
    
    func getCovidData(completion: @escaping (Result<[CovidData], Error>) -> Void ) {
        let urlString = "https://coronavirus-19-api.herokuapp.com/countries"
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "", code: -1, userInfo: nil)
            return completion(.failure(error))
        }
        
        let request = setupRequest(method: "GET", url: url, bodyData: nil)
        getData(request: request, completion: completion)
    }
    
    fileprivate func setupRequest(method: String, url: URL, bodyData: Data?) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method
        request.httpBody = bodyData
        return request
    }
    
    fileprivate func getData(request: URLRequest, completion: @escaping (Result<[CovidData], Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            var covidDataArray: [CovidData] = []
            let error = NSError(domain: "", code: -1, userInfo: nil)
            guard let response = response as? HTTPURLResponse else {
                return completion(.failure(error))
            }
            
            guard let data = data else {
                return
            }
            
            do {
                guard (200 ..< 300) ~= response.statusCode else {
                    switch response.statusCode {
                    case 400:
                        return completion(.failure(error))
                    case 401:
                        return completion(.failure(error))
                    default:
                        return completion(.failure(error))
                    }
                }
                
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    for dict in jsonArray {
                        covidDataArray.append(CovidData(json: dict))
                    }
                }
                
                completion(.success(covidDataArray))
                
            } catch let error {
                print(error)
                return
            }
        }
        task.resume()
    }
}
