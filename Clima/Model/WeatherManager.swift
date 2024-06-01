import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=9fd03971484e8c609ed83a8853997001&units=imperial"
    
    // protocol is WeatherManagerDelgate and it declares a method didUpdateWeather(weather:) which is intended to be adopted by any class or struct that wants to act as delegate for WeatherManager.
    // ? optional because there might not always be a delegate assigned
    // The WeatherManager is responsible for fetching data, and the WeatherViewController is responsible for updating the user interface in response to data change. This is done through delegation.
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temp = decodedData.main.temp
            let weather = WeatherModel(conditionID: id, cityName: name, temperature: temp)
            return weather
            /**
            let conditionName = weather.conditionName
            let temperatureString = weather.temperatureString
            
            print("Description:", decodedData.weather[0].description, "\n",
                  "Weather Condition:", conditionName, "\n",
                  "Temperature:", temperatureString)
             */
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

/**
 // completionHandler - Creates a task that retrieves the contents of the specified URL, then calls a handler upon completion.
 */

/**
 Swift Deep Dive: Closures
 
 func calculator (n1: Int, n2: Int, operation: (Int, Int) -> Int) -> Int {
 return operation(n1, n2)
 }
 
 func add (no1: Int, no2: Int) -> Int {
 return no1 + no2
 }
 
 calculator(n1: 5, n2 : 6, operation: add)
 (output == 11)
 
 Closures:
 
 { (parameters) -> return type in
 statements
 }
 
 { (n1: Int, n2: Int) -> Int in
 return n1 + n2
 }
 
 calculator(n1: 5, n2 : 6, operation: { (n1: Int, n2: Int) -> Int in
 return n1 + n2
 })
 calculator(n1: 5, n2 : 6, operation: { (n1, n2) in n1 + n2 })
 calculator(n1: 5, n2 : 6, operation: {$0 * $1})
 calculator(n1: 5, n2 : 6) {$0 * $1}
 $0 - first parameter
 $1 - second parameter
 let result = calculator(n1: 5, n2 : 6) {$0 * $1}
 
 let array = [1, 2, 3, 4, 5]
 array.map{$0+1} // output -> [2, 3, 4, 5, 6]
 let newArray = array.map{"\($0)"} // output -> ["2", "3", "4", "5", "6"]
 */

/**
 JSON - JavaScript Object Notation
 */
