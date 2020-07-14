//
//  Models.swift
//  Meteo
//
//  Created by José María Martín Luque on 14/07/2020.
//

import Foundation

let AEMETDateFormat = "yyyy-MM-dd'T'HH:mm:ss"

// MARK: - Helper functions

func dateFrom(string: String) -> Date {
    
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "es_ES")
    dateFormatter.dateFormat = AEMETDateFormat
    return dateFormatter.date(from: string)!
}

// MARK: - Models

struct PredictionModel {
    
    // Metadata
    let townName, province: String
    let dateCreated: Date
    
    let days: [PredictionDayModel]
    
}

struct PredictionDayModel {
    
    let date: Date
    let min, max: Int
    let sky: AEMETSkyDescription
    
    let hourlyData: [HourlyDataModel]
    
}

struct HourlyDataModel {
    
    let hour: Int
    let sky: AEMETSkyDescription
    let temperature: Int
    
}

extension PredictionModel {
    static func from(hourlyDTO: AEMETHourlyPredictionRoot, and dailyDTO: AEMETDailyPredictionRoot) -> PredictionModel {
        
        var days: [PredictionDayModel] = []
        
        for (index, day) in dailyDTO.prediction.days.enumerated() {
            
            var dayHourlyData: [HourlyDataModel] = []
            
            // We create hourly data only for the days that have them
            if (hourlyDTO.prediction.days.indices.contains(index)) {
                
                let hourlyDataDay = hourlyDTO.prediction.days[index]
                
                // Sky and temperature data are provided on a hourly basis, and they share indices
                for (index_, sky) in hourlyDTO.prediction.days[index].sky.enumerated() {
                    
                    // We strip the hours that have already passed
                    let currentHour = Calendar.current.component(.hour, from: Date())
                    let hour = Int(sky.period!)!
                    
                    if (index == 0 && hour < currentHour - 1) {
                        continue
                    }
                    
                    dayHourlyData.append(HourlyDataModel(hour: Int(sky.period!)!, sky: sky.description, temperature: Int(hourlyDataDay.temperature[index_].value)!))
                }
                
            }
            
            days.append(PredictionDayModel(date: dateFrom(string: day.date), min: day.temperature.min, max: day.temperature.max, sky: day.sky.first!.description, hourlyData: dayHourlyData))
            
        }
        
        return PredictionModel(townName: dailyDTO.name, province: dailyDTO.province, dateCreated: dateFrom(string: dailyDTO.created), days: days)
    }
}
