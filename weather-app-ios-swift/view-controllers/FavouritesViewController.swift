//
//  FavouritesViewControllwe.swift
//  weather-app-ios-swift
//
//  Created by Andrew Vo-Nguyen on 2/5/21.
//

import UIKit
import GooglePlaces


class FavouritesViewController: UIViewController {
    @IBOutlet weak var myTableView: UITableView!
    var faveCities = [String]()
    var favePlaceID = [String]()
    var currentPlace: GMSPlace? = nil
    
    // On page load
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeAPIKeys()
        let nib = UINib(nibName: "customTableViewCell", bundle: nil)
        myTableView.register(nib, forCellReuseIdentifier: "customTableViewCell")
        myTableView.delegate = self
        myTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Reload data for the View
        super.viewWillAppear(animated)
        faveCities = [String]()
        favePlaceID = [String]()
        let favourites = getFavourites()
        for (placeID, city) in (Array(favourites).sorted {$0.1 < $1.1}) {
            favePlaceID.append(placeID)
            faveCities.append(city)
        }
        myTableView?.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        myTableView.reloadData()
    }
    
    func initializeAPIKeys() -> Void {
        //Intialize API keys for google place service
        let apiKey = API.getApiKey(api: "GOOGLE_PLACES")
        GMSPlacesClient.provideAPIKey(apiKey)
    }
    
    //Get GMS place from place ID
    func getGMSPlace(placeId: String) -> GMSPlace? {
        //Get the CurrentWeather Controller
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "CurrentWeatherViewController") as! CurrentWeatherViewController
        //Move to current weather page
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
        //Get GMS Place with parameter city name from Google API to pass this GMSPlace as a input parameter for current weather screen
        let placesClient = GMSPlacesClient.shared()
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) |
            UInt(GMSPlaceField.coordinate.rawValue))
        let placeFound:GMSPlace? = nil
        placesClient.fetchPlace(fromPlaceID: placeId, placeFields: fields, sessionToken: nil, callback: {
            (place: GMSPlace?, error: Error?) in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            if let place = place {
                nextViewController.currentPlace = place
            }
        })
        return placeFound
    }
    
    func getFavourites() -> [String:String] {
        //Get list favourite cities from the UserDefaults
        let defaults = UserDefaults.standard
        let favourites: [String:String] = defaults.object(forKey: "favourites") as? [String:String] ?? [:]
        return favourites
    }
    
    func getFavourite(placeID: String) -> [String:Any] {
        //Get favourite city from the UserDefaults
        let defaults = UserDefaults.standard
        let favourite: [String:Any] = defaults.object(forKey: placeID) as? [String:Any] ?? [:]
        return favourite
    }
}

extension FavouritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favePlaceID.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Display cells on the favorite view
        let cell = myTableView.dequeueReusableCell(withIdentifier: "customTableViewCell", for: indexPath) as! customTableViewCell
        cell.nameLabel.text = faveCities[indexPath.row]
        return cell
    }
}

extension FavouritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let placeId = favePlaceID[indexPath.row]
        //After click a record, move to the current weather place with the corresponding city
        _ = getGMSPlace(placeId: placeId)
    }
}
