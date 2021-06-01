//
//  ViewController.swift
//  weather-app-ios-swift
//
//  Created by Andrew Vo-Nguyen on 1/5/21.
//

import UIKit
import GooglePlaces

class SearchViewController: UIViewController, UITextFieldDelegate {
    // IBOutlets
    @IBOutlet weak var LocationTitleLabel: UILabel!
    @IBOutlet weak var LocationTextField: UITextField!
    @IBOutlet weak var SearchButton: UIButton!
    
    // IBActions
    @IBAction func locationTextFieldChangedHandler(_ sender: Any) {
        location = LocationTextField.text ?? ""
    }
    
    // Global variables
    var currentWeatherData: WeatherData? = nil
    var currentPlace: GMSPlace? = nil
    var location:String = "" {
        didSet {
            setButtonEnabled(enabled:  location.count > 0)
            LocationTextField.text = location
        }
    }
    
    // On page load
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeAPIKeys()
        initializeUI()
    }
    
    // Initialize google maps API
    func initializeAPIKeys() -> Void {
        let apiKey = API.getApiKey(api: "GOOGLE_PLACES")
        GMSPlacesClient.provideAPIKey(apiKey)
    }
    

    
    // Initialize UI components
    func initializeUI() -> Void {
        // Assign delegate of textfield to handle Google Search UI component
        LocationTextField.delegate = self
        LocationTitleLabel.textAlignment = .center
        LocationTitleLabel.text = "Search Location:"
        LocationTextField.addTarget(self, action: #selector(locationTextFieldPressHandler), for: .touchDown)
        
        // Set search button properties
        SearchButton.setTitle("Show me the weather!", for: UIControl.State.normal)
        SearchButton.layer.cornerRadius = 8
        SearchButton.layer.borderWidth = 1
        SearchButton.contentEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        SearchButton.setTitleColor(UIColor.white, for: .normal)
        SearchButton.setTitleColor(UIColor.lightGray, for: .disabled)
        
        // Disable search button by default until user selects a location
        setButtonEnabled(enabled: false)
    }
    
    // Set search button properties based on disabled or not
    func setButtonEnabled(enabled: Bool) -> Void {
        SearchButton.isEnabled = enabled
        if (enabled) {
            SearchButton.backgroundColor = UIColor.systemBlue
            SearchButton.layer.borderColor = UIColor.systemBlue.cgColor
        } else{
            SearchButton.backgroundColor = UIColor.systemGray5
            SearchButton.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    // Intercept input into Textfiel, and show Google UI Search modal instead
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        locationTextFieldPressHandler()
        return false
    }
    
    // Present the Autocomplete view controller when the button is pressed.
    @objc func locationTextFieldPressHandler() {
      let autocompleteController = GMSAutocompleteViewController()
      autocompleteController.delegate = self

      // Specify the place data types to return.
      let fields: GMSPlaceField = GMSPlaceField(rawValue:UInt(GMSPlaceField.name.rawValue) |
                                                    UInt(GMSPlaceField.placeID.rawValue) |
                                                    UInt(GMSPlaceField.coordinate.rawValue) |
                                                    GMSPlaceField.addressComponents.rawValue |
                                                    GMSPlaceField.formattedAddress.rawValue)
      autocompleteController.placeFields = fields

      // Specify a filter.
      let filter = GMSAutocompleteFilter()
    filter.type = .city
      
      autocompleteController.autocompleteFilter = filter

      // Display the autocomplete view controller.
      present(autocompleteController, animated: true, completion: nil)
    }
    
    //Navigate to current weather screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCurrentWeatherScreen" {
            let viewController = segue.destination as! CurrentWeatherViewController
            viewController.currentPlace = currentPlace
        }
    }
}

// Google Seearch Protocols (extensions)
extension SearchViewController: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    // Set global variable of currentPlace to use elsewhere
    currentPlace = place
    location = place.name!
    
    // Dismiss the Google Search UI element
    dismiss(animated: true, completion: nil)
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }
}
