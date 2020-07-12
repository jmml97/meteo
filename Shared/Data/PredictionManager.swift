//
//  PredictionManager.swift
//  Meteo
//
//  Created by José María Martín Luque on 10/07/2020.
//

import Foundation

/// Manages fetching predictions
class PredictionManager: NSObject, ObservableObject {
    
    let keyFileName = "key"
    let keyFileExtension = "plist"
    
    var townID: String? = nil
    var apiKey: String? = nil
    
    @Published var hourlyPredictionsContainer: AEMETHourlyPredictionContainer? = nil
    @Published var dailyPredictionsContainer: AEMETDailyPredictionContainer? = nil
    
    override init() {
        super.init()
        loadApiKey()
    }
    
    /// Loads `apiKey` from a file
    func loadApiKey() {
        
        guard let path = Bundle.main.path(forResource: keyFileName, ofType: keyFileExtension) else {
            fatalError("Could not find the keys file in bundle.")
        }
        
        guard let keys = NSDictionary(contentsOfFile: path) else {
            fatalError("Could not load keys from file.")
        }
        
        guard let key = keys["apiKey"] as? String else {
            fatalError("Could not load API key from file.")
        }
        
        self.apiKey = key
    }
    
    /// Fetches JSON data from `url` and decodes to a `Decodable` container of type `Container.Type`.
    /// - Parameter url: url used to fetch JSON data for decoding.
    /// - Parameter toContainer: container type used to decode data
    func requestDataAndDecode<Container>(from url: URL, toContainer: Container.Type, completion: @escaping (Container?) -> ()) where Container : Decodable {
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        
        session.dataTask(with: url) { data, response, error in
            
            guard let data = data else {
                fatalError("Could not obtain any data from url \(url).")
            }
                    
            guard error == nil else {
                fatalError("There was an error obtaining data from url \(url): \(error!).")
            }
            
            // AEMET returns data in windowsCP1252 encoding and we must change it to UTF-8.
            let dataUTF8 = Data(String(data: data, encoding: String.Encoding.windowsCP1252)!.utf8)

            do {
                let response = try JSONDecoder().decode(Container.self, from: dataUTF8)
                
                DispatchQueue.main.async {
                    completion(response)
                }
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
                    
        }.resume()
        
    }
    
    /// Loads hourly predictions into `hourlyPredictionsContainer`
    func loadHourlyPredictions() {
        
        guard let townID = self.townID, let apiKey = self.apiKey else {
            fatalError("API key or town ID are not set, can't fetch data without them.")
        }
        
        let url = URL(string: "https://opendata.aemet.es/opendata/api/prediccion/especifica/municipio/horaria/\(townID)/?api_key=\(apiKey)")!
        
        self.requestDataAndDecode(from: url, toContainer: GenericAEMETResponse.self) { response in
            guard let predictionURLString = response?.data else {
                fatalError("Could not unwrap string of data URL.")
            }
            
            guard let predictionURL = URL(string: predictionURLString) else {
                        fatalError("URL is not correct!")
            }
            
            self.requestDataAndDecode(from: predictionURL, toContainer: [AEMETHourlyPredictionContainer].self) { predictions in
                guard let predictions = predictions else {
                    fatalError("Could not load prediction.")
                }
                
                self.hourlyPredictionsContainer = predictions[0]
            }
        }
        
    }
    
    /// Loads daily predictions into `dailyPredictionsContainer`
    func loadDailyPredictions() {
        
        guard let townID = self.townID, let apiKey = self.apiKey else {
            fatalError("API key or town ID are not set, can't fetch data without them.")
        }
        
        let url = URL(string: "https://opendata.aemet.es/opendata/api/prediccion/especifica/municipio/diaria/\(townID)/?api_key=\(apiKey)")!
        
        self.requestDataAndDecode(from: url, toContainer: GenericAEMETResponse.self) { response in
            guard let predictionURLString = response?.data else {
                fatalError("Could not unwrap string of data URL.")
            }
            
            guard let predictionURL = URL(string: predictionURLString) else {
                        fatalError("URL is not correct!")
            }
            
            self.requestDataAndDecode(from: predictionURL, toContainer: [AEMETDailyPredictionContainer].self) { predictions in
                guard let predictions = predictions else {
                    fatalError("Could not load prediction.")
                }
                
                self.dailyPredictionsContainer = predictions[0]
            }
        }
        
    }
    
    func getHourlyPredictions() -> AEMETHourlyPrediction {
        
        guard let hourlyPredictionsContainer = hourlyPredictionsContainer else {
            fatalError("Hourly predictions are empty.")
        }
        
        let hour = Calendar.current.component(.hour, from: Date())
        
        let todayTemperatures = hourlyPredictionsContainer.prediction.days[0].temperature.filter { Int($0.period!)! >= hour }
        let todaySky = hourlyPredictionsContainer.prediction.days[0].sky.filter { Int($0.period!)! >= hour }
        
        var filteredHourlyPredictions = hourlyPredictionsContainer.prediction
        filteredHourlyPredictions.days[0].temperature = todayTemperatures
        filteredHourlyPredictions.days[0].sky = todaySky
        
        return filteredHourlyPredictions
        
    }
    
    func getCurrentData() -> (AEMETPeriodicData, AEMETSky) {
        
        guard let hourlyPredictionsContainer = hourlyPredictionsContainer else {
            fatalError("Hourly predictions are empty.")
        }
        
        let hour = Calendar.current.component(.hour, from: Date())
        
        let currentTemperature = hourlyPredictionsContainer.prediction.days[0].temperature.filter { Int($0.period!)! == hour }
        let currentSky = hourlyPredictionsContainer.prediction.days[0].sky.filter { Int($0.period!)! == hour }
        
        return (currentTemperature[0], currentSky[0])
        
    }
}

// AEMET uses self signed certificates and by default URLSession refuses to download data in that case.
// We need to override this behaviour and allow unsecure connections.
extension PredictionManager: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
       //Trust the certificate even if it is not valid.
       let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)

       completionHandler(.useCredential, urlCredential)
    }
}
