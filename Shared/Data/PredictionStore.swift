//
//  PredictionManager.swift
//  Meteo
//
//  Created by José María Martín Luque on 10/07/2020.
//

import Foundation

let AEMETBaseUrl = "https://opendata.aemet.es/opendata/api/prediccion/especifica/municipio/"
let keyFileName = "key"
let keyFileExtension = "plist"

/// Manages fetching predictions
class PredictionStore: NSObject, ObservableObject {
    
    var townID: String? = nil
    var apiKey: String? = nil
    
    @Published var model: PredictionModel? = nil
    
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
    
    // MARK: -
    
    func getPredictionModel() {
        
        guard let townID = self.townID, let apiKey = self.apiKey else {
            fatalError("API key or town ID are not set, can't fetch data without them.")
        }
        
        var h: AEMETHourlyPredictionRoot?
        var d: AEMETDailyPredictionRoot?
        
        let dataDownloadGroup = DispatchGroup()
        
        var url = URL(string: AEMETBaseUrl + "horaria/\(townID)/?api_key=\(apiKey)")!
        
        dataDownloadGroup.enter()
        self.requestDataAndDecode(from: url, toContainer: GenericAEMETResponse.self) { response in
            guard let predictionURLString = response?.data else {
                fatalError("Could not unwrap string of data URL.")
            }
            
            guard let predictionURL = URL(string: predictionURLString) else {
                        fatalError("URL is not correct!")
            }
            
            self.requestDataAndDecode(from: predictionURL, toContainer: [AEMETHourlyPredictionRoot].self) { predictions in
                guard let predictions = predictions else {
                    fatalError("Could not load prediction.")
                }
                
                h = predictions.first
                dataDownloadGroup.leave()
            }
        }
        
        url = URL(string: AEMETBaseUrl + "diaria/\(townID)/?api_key=\(apiKey)")!
        
        dataDownloadGroup.enter()
        self.requestDataAndDecode(from: url, toContainer: GenericAEMETResponse.self) { response in
            guard let predictionURLString = response?.data else {
                fatalError("Could not unwrap string of data URL.")
            }
            
            guard let predictionURL = URL(string: predictionURLString) else {
                        fatalError("URL is not correct!")
            }
            
            self.requestDataAndDecode(from: predictionURL, toContainer: [AEMETDailyPredictionRoot].self) { predictions in
                guard let predictions = predictions else {
                    fatalError("Could not load prediction.")
                }
                
                d = predictions.first
                dataDownloadGroup.leave()
            }
        }
        
        dataDownloadGroup.notify(queue: DispatchQueue.main, execute: {
            if let h = h, let d = d {
                print("created model")
                self.model = PredictionModel.from(hourlyDTO: h, and: d)
            }
        })
        
    }
}

// AEMET uses self signed certificates and by default URLSession refuses to download data in that case.
// We need to override this behaviour and allow unsecure connections.
extension PredictionStore: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
       //Trust the certificate even if it is not valid.
       let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)

       completionHandler(.useCredential, urlCredential)
    }
}
