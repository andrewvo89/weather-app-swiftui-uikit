//
//  CurrentWeatherViewController.swift
//  weather-app-ios-swift
//
//  Created by Ethan Nguyen on 12/5/21.
//
import UIKit
import GooglePlaces

class CurrentWeatherViewController: UIViewController {
    // IBOutlets
    @IBOutlet weak var LoadingSpiiner: UIActivityIndicatorView!
    @IBOutlet weak var CurrentWeatherView: UIView!
    @IBOutlet weak var CityNameLabel: UILabel!
    @IBOutlet weak var CurrentWeatherIcon: UIImageView!
    @IBOutlet weak var WeatherConditionLabel: UILabel!
    @IBOutlet weak var DegreeLabel: UILabel!
    @IBOutlet weak var SunriseTimeLabel: UILabel!
    @IBOutlet weak var SunetTimeLabel: UILabel!
    @IBOutlet weak var FavouritesButton: UIBarButtonItem!
    @IBOutlet weak var SevenDaysButton: UIButton!
    @IBOutlet weak var NavigationItem: UINavigationItem!
    
    // IBActions
    // Add current location to favourites
    @IBAction func favouritesPressHandler(_ sender: UIBarButtonItem) {
        // Extract variables from currentPlace
        let city: String = (currentPlace?.name)!
        let lat: Double = (currentPlace?.coordinate.latitude)!
        let lon: Double = (currentPlace?.coordinate.longitude)!
        let placeID: String = (currentPlace?.placeID)!
        
        // Get user defauls
        let defaults = UserDefaults.standard
        var favourites: [String:String] = getFavourites()

        if(favourites[placeID] != nil){
            // Remove from favourites
            favourites[placeID] = nil
            defaults.removeObject(forKey: placeID)
                        
            let alert = UIAlertController(title: "Favourites", message: "\(city) has been removed from your favourites.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            
            favourites[placeID] = city
            
            let faveObj: [String:Any] = [
                "city": city,
                "longitude": lon,
                "latitude": lat
            ]
            
            defaults.set(faveObj, forKey: placeID)
            
            let alert = UIAlertController(title: "Favourites", message: "\(city) added to favourites!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
            
        defaults.set(favourites, forKey: "favourites")
        
        handleFavouritesBtnIcon()
        
    }
    
    // Global variables
    var weatherData: WeatherData? = nil {
        didSet {
            // Dispatch UI updates back to the Main thread as this didSet{} is triggered by Async background thread
            DispatchQueue.main.async {
                // Initialize sunrise and sunset dates
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                //use device default?
                //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+10")
                let sunriseDate = Date(timeIntervalSince1970: Double(self.weatherData!.current.sunrise))
                let sunsetDate = Date(timeIntervalSince1970: Double(self.weatherData!.current.sunset))
                // Initialize all label texts
                self.CityNameLabel.text = self.currentPlace?.name
                self.WeatherConditionLabel.text = self.weatherData?.current.weather[0].main
                self.DegreeLabel.text = String(format: "%.0f", self.weatherData!.current.temp) + "°C"
                self.CurrentWeatherIcon.image = UIImage(named: (self.weatherData?.current.weather[0].icon)!)
                self.SunriseTimeLabel.text = dateFormatter.string(from: sunriseDate)
                self.SunetTimeLabel.text = dateFormatter.string(from: sunsetDate)
                self.CurrentWeatherView.isHidden = false
                // Stop spinner -> element will hide automatically
                self.LoadingSpiiner.stopAnimating()
            }
        }
    }
    
    var currentPlace: GMSPlace? = nil {
        didSet {
            // Everytime currentPlace gets changed, getWeather() from API
            handleFavouritesBtnIcon()
            getWeather()
        }
    }
    
    // On initial load
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
    }
    
    func initializeUI() {
        // Hide the View initially and only display Loading Spinner
        CurrentWeatherView.isHidden = true
        
        SevenDaysButton.setTitle("Show me the next 7 days!", for: UIControl.State.normal)
        SevenDaysButton.layer.cornerRadius = 8
        SevenDaysButton.contentEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    }
    
    // Get favourites from UserDefaults
    func getFavourites() -> [String:String] {
        let defaults = UserDefaults.standard
        let favourites: [String:String] = defaults.object(forKey: "favourites") as? [String:String] ?? [:]
        return favourites
    }
    
    func handleFavouritesBtnIcon() {
        let favourites: [String:String] = getFavourites()
        
        let placeID: String = (currentPlace?.placeID)!
        
        if(favourites[placeID] != nil){
            NavigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: UIBarButtonItem.SystemItem.trash,
                target: self,
                action: #selector(favouritesPressHandler)
            )
        } else {
            NavigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: UIBarButtonItem.SystemItem.add,
                target: self,
                action: #selector(favouritesPressHandler)
            )
        }
    }

    
    // Get weather information from API call
    func getWeather() {
        let lat: Double = (currentPlace?.coordinate.latitude)!
        let lon: Double = (currentPlace?.coordinate.longitude)!
        
        // Read Open weather Api Key from api-keys.plist
        let apiKey = API.getApiKey(api: "OPEN_WEATHER")
    
        // Form API url
        let url = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&exclude=minutely,hourly,alerts&appid=\(apiKey)&units=metric"
        
        performRequest(urlString: url)
    }
    
    func performRequest(urlString: String) {
        // step1: create URL
        if let url = URL(string: urlString) {
            // step 2: create a URL session
            let session = URLSession(configuration: .default)
            
            // step 3: give URLSession a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let safeData = data {
//                    let dataString = String(data: safeData, encoding: .utf8)
//                    print(dataString!)
                    self.parseJSON(data: safeData)
                }
            }
            
            // step 4: start a task
            task.resume()
        }
    }
        
    func parseJSON(data: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: data)
//            print(decodedData)
            // Set global variable to use to display weather
            weatherData = decodedData
        } catch {
            print(error)
        }
    }
    //Navigate to seven day weather screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSevenDayWeatherScreen" {
            let viewController = segue.destination as! SevenDayWeatherViewController
            viewController.weatherData = weatherData
        }
    }
}
