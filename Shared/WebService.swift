//
//  WebService.swift
//  Meteo
//
//  Created by José María Martín Luque on 02/07/2020.
//

import Foundation

enum PredictionType {
    case daily
    case hourly
}

class WebService: NSObject {
    
    func loadDataRequest(url: URL, completion: @escaping (GenericAEMETResponse?) -> ()) {
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        
        session.dataTask(with: url) { data, response, error in
                    
                    guard let data = data, error == nil else {
                        completion(nil)
                        return
                    }
                    
                    let response = try? JSONDecoder().decode(GenericAEMETResponse.self, from: data)
                    if let response = response {
                        DispatchQueue.main.async {
                            completion(response)
                        }
                    }
                    
                    
        }.resume()
    }
    
    func loadHourlyPredictionRequest(url: URL, completion: @escaping (AEMETHourlyPredictionContainer?) -> ()) {
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        
        session.dataTask(with: url) { data, response, error in
                    
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            // Cosas feas por el encoding usado
            // FIXME: buscar mejor solución
            let stringData = String(data: data, encoding: String.Encoding.windowsCP1252)
            let data2 = Data(stringData!.utf8)
            
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(AEMETRoot.self, from: data2)
                
                DispatchQueue.main.async {
                    completion(response[0])
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
    
    func loadDailyPredictionRequest(url: URL, completion: @escaping (AEMETDailyPredictionContainer?) -> ()) {
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        
        session.dataTask(with: url) { data, response, error in
                    
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            // Cosas feas por el encoding usado
            // FIXME: buscar mejor solución
            let stringData = String(data: data, encoding: String.Encoding.windowsCP1252)
            let data2 = Data(stringData!.utf8)
            
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode([AEMETDailyPredictionContainer].self, from: data2)
                
                DispatchQueue.main.async {
                    completion(response[0])
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
    
}

extension WebService: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
       //Trust the certificate even if not valid
       let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)

       completionHandler(.useCredential, urlCredential)
    }
}
