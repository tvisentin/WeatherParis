//
//  HomeTableViewController.swift
//  Meteo Paris
//
//  Created by Thomas VISENTIN on 8/17/17.
//  Copyright © 2017 Thomas VISENTIN. All rights reserved.
//

import Foundation
import UIKit

enum HomeCell {
    case Loading
    case Error
    case Home
}

class HomeTableViewController: UITableViewController {
    
    @IBOutlet weak var titleNavigationItem: UINavigationItem!
    
    let oauthApi = Oauth.sharedInstance
    var allWeatherInfo = [[WeatherInfo]]()
    var homeCell : HomeCell = .Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide empty cell on tableView
        tableView.tableFooterView = UIView()
        
        // Register custom cell Loading and Error (no need for prototype cell)
        tableView.register(UINib.init(nibName: "LoadingTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadingTableViewCell")
        tableView.register(UINib.init(nibName: "ErrorTableViewCell", bundle: nil), forCellReuseIdentifier: "ErrorTableViewCell")
        
        oauthApi.getInfoToApi { (hasSucceed, error, weather) in
            if hasSucceed {
                print("Get Weather Info is a success")
                self.allWeatherInfo = weather!
                self.homeCell = .Home
                self.tableView.reloadData()
            } else {
                self.homeCell = .Error
                print("Error (viewDidLoad/getInfoToApi)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if homeCell == .Home {
            return allWeatherInfo.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if homeCell == .Home {
            var tmpWeather = WeatherInfo()
            
            // Get 12h00 if exist or first hour
            for weather in allWeatherInfo[indexPath.row] {
                if weather.hour == "12:00" {
                    tmpWeather = weather
                }
            }
            if tmpWeather.hour == "" {
                tmpWeather = allWeatherInfo[indexPath.row].first!
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomePrototypeCellID") as! HomePrototypeCell
            cell.selectionStyle = .none
            cell.imageViewCell.image = UIImage(named: tmpWeather.icon!)
            cell.dayLabelCell?.text = tmpWeather.date
            cell.degreeLabelCell.text = tmpWeather.degree
            cell.degreeNightLabelCell.text = allWeatherInfo[indexPath.row].last?.degree
            cell.backgroundColor = UIColor.changeBackgroundColor(icon: tmpWeather.icon!)
            return cell
        } else if homeCell == .Loading {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingTableViewCell", for: indexPath) as! LoadingTableViewCell
            cell.selectionStyle = .none
            cell.loadingIndicatorView.startAnimating()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ErrorTableViewCell") as! ErrorTableViewCell
            cell.selectionStyle = .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if homeCell == .Home {
            let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewControllerID") as! DetailViewController
            detailVC.dayWeatherInfo = allWeatherInfo[indexPath.row]
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if homeCell == .Home {
            return CGFloat(70)
        } else {
            return UIScreen.main.bounds.height
        }
    }
}
