//
// WeatherViewController.swift
// Clima
// Raymond Kim
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        weatherManager.delegate = self
        locationManager.delegate = self
        // pop-up on screen asking for location permission
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            // already requestLocation() at the launch of app. Calling it second time with locationPressed() means there was no didUpdateLocation (we use cityName for updating in the app). So we use stopUpdatingLocation() to be able to trigger this again to current location.
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}

//MARK: - UITextFieldDelegate

// UITextFieldDelegate - manages the editing and validation of texts in a textfield property
extension WeatherViewController: UITextFieldDelegate {
    
    // search icon pressed
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    // user pressed the return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    // when .endEditing(true) is called from either of the above functions, this function is triggered to validate it before callig textFieldDidEndEditing for additional actions.
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something!"
            return false
        }
    }
    
    // clear search field. Using a delegate so that we don't have to add the same code to both the searchPressed and textFieldShouldReturn functions.
    func textFieldDidEndEditing(_ textField: UITextField) {
        // if there is a string
        if let city = searchTextField.text {
            weatherManager.fetchWeather(cityName: city)
        }
        searchTextField.text = ""
    }
    
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        // Without dispatch queue, there would be error because we are trying to update a UI from inside a Completion Handler.
        // For example, if the network was down and could not get the weatherModel, then it would look like the UI is frozen.
        DispatchQueue.main.async {
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.temperatureLabel.text = weather.temperatureString
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
}
