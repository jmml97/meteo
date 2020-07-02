//
//  WebService.swift
//  Meteo
//
//  Created by José María Martín Luque on 02/07/2020.
//

import Foundation

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
    
    func loadPredictionRequest(url: URL, completion: @escaping ([AEMETPrediction]?) -> ()) {
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        
        session.dataTask(with: url) { data, response, error in
                    
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            let stringData = String(data: data, encoding: String.Encoding.windowsCP1252)
            let data2 = Data(stringData!.utf8)
            
            let response = try? JSONDecoder().decode([AEMETPrediction].self, from: data2)
            if let response = response {
                print("response=response")
                DispatchQueue.main.async {
                    print("a")
                    completion(response)
                }
            } else {
                print("else")
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
