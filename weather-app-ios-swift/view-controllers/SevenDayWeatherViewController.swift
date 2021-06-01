//
//  SevenDayWeatherViewController.swift
//  weather-app-ios-swift
//
//  Created by Andrew Vo-Nguyen on 15/5/21.
//

import UIKit
import GooglePlaces

class SevenDayWeatherViewController: UIViewController {
    // IBOutlets
    @IBOutlet weak var VerticalStackViewContainer: UIStackView!
    
    // Global variables
    var weatherData: WeatherData? = nil
    
    // On initial load
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
    }
    
    func initializeUI() -> Void {
        // If page is called with no weatherDate from Segue
        if (weatherData == nil) {
            return
        }
        
        // Loop through each day of the 7 day forecast
        for day in weatherData!.daily {
            // Initialize inner containers
            let HorizontalContainer = UIStackView()
            HorizontalContainer.axis = .horizontal
            HorizontalContainer.alignment = .leading
            HorizontalContainer.distribution = .equalSpacing
            
            // Left Container
            let LeftContainer = UIStackView()
            LeftContainer.axis = .vertical
            
            // Day label
            let DayLabel = UILabel()
            let calenadar = Calendar.current
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMM d"
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+10")
            let date = Date(timeIntervalSince1970: Double(day.dt))
            let isToday = calenadar.isDateInToday(date)
            DayLabel.text = isToday ? "Today" : dateFormatter.string(from: date)
            DayLabel.textColor = UIColor.white
            DayLabel.font = UIFont.boldSystemFont(ofSize: 20)
            
            // Weather and Temp labels
            let WeatherLabel = UILabel()
            let TempLabel = UILabel()
            TempLabel.text = "\(String(format: "%.0f", day.temp.min) + "°C") - \(String(format: "%.0f", day.temp.max) + "°C")"
            TempLabel.textColor = UIColor.darkGray
            WeatherLabel.font = WeatherLabel.font.withSize(16)
            
            WeatherLabel.text = "\(day.weather[0].main)"
            WeatherLabel.textColor = UIColor.darkGray
            WeatherLabel.font = WeatherLabel.font.withSize(16)
            
            LeftContainer.addArrangedSubview(DayLabel)
            LeftContainer.addArrangedSubview(TempLabel)
            LeftContainer.addArrangedSubview(WeatherLabel)
            
            // Right Container
            let WeatherImageView = UIImageView()
            let WeatherIcon = UIImage(named: day.weather[0].icon)?.scalePreservingAspectRatio(targetSize: CGSize(width: 100, height: 100))
            WeatherImageView.frame.size.height = 500
            WeatherImageView.image = WeatherIcon
            
            // Add inner containers to Parent VerticalStackView
            HorizontalContainer.addArrangedSubview(LeftContainer)
            HorizontalContainer.addArrangedSubview(WeatherImageView)
            VerticalStackViewContainer.addArrangedSubview(HorizontalContainer)
        }
        
    }
    
    
}

// Helper Function to resize image while preserving aspect ratio
// Credit: https://www.advancedswift.com/resize-uiimage-no-stretching-swift/
extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        return scaledImage
    }
}
