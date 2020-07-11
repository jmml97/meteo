//
//  PredictionView.swift
//  Meteo
//
//  Created by José María Martín Luque on 02/07/2020.
//

import SwiftUI

// MARK: Constants

let weatherIcons: [AEMETSkyDescription: String] = [
    .despejado: "sun.max",
    .cubierto: "cloud",
    .nuboso: "smoke",
    .niebla: "cloud.fog",
]

let isoDateFormatString = "yyyy-MM-dd'T'HH:mm:ss"


// MARK: - Helper functions

/// Returns a string in the desired format from a string in another format
func getFormattedDateFromString(dateString: String, inFormat: String, outFormat: String) -> String {
    
    let inFormatter = DateFormatter()
    inFormatter.dateFormat = inFormat
    
    let date = inFormatter.date(from:dateString)!
    
    let outFormatter = DateFormatter()
    outFormatter.dateFormat = outFormat
    outFormatter.locale = Locale(identifier: "es_ES")
    
    return outFormatter.string(for: date)!
}

// MARK: - Views

/// Main prediction view
/// - Parameter townID: id of the town this view represents, needed to pull data
struct PredictionView: View {
    
    @ObservedObject var manager = PredictionManager()
    var townID: String
    
    @ViewBuilder
    var body: some View {
        if let hourlyPredictions = manager.hourlyPredictionsContainer {
            VStack(alignment: .leading) {
                #if os(macOS)
                Text(hourlyPredictions.name)
                    .font(.title)
                    .fontWeight(.bold)
                #endif
                MetadataView(province: hourlyPredictions.province, predictionDate: hourlyPredictions.created)
                Divider()
                HourlyPredictionView(prediction: manager.getHourlyPredictions()).navigationTitle(hourlyPredictions.name)
                Divider()
                if let dailyPredictions = manager.dailyPredictionsContainer {
                    DailyPredictionListView(predictions: dailyPredictions)
                }
                Spacer()
            }
            .padding([.top, .leading])
        } else {
            
            VStack {
                Spacer()
                ProgressView("Cargando").onAppear {
                    manager.townID = townID
                    manager.loadHourlyPredictions()
                    manager.loadDailyPredictions()
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                Spacer()
            }
        }
        
    }
}

struct MetadataView: View {
    
    let province, predictionDate: String
    
    var body: some View {
        HStack {
            Text(province).font(Font.system(.body).smallCaps())
            Divider().frame(height: 20)
            Text("Elaboración: \(getFormattedDateFromString(dateString: predictionDate, inFormat: isoDateFormatString, outFormat: "MM/dd/yyyy HH:mm"))")
        }
    }
}

struct HourlyPredictionView: View {
    
    let prediction: AEMETHourlyPrediction
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Predicción horaria")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(prediction.days, id:\.date) { d in
                        VStack(alignment: .leading) {
                            Text(getFormattedDateFromString(dateString: d.date, inFormat: isoDateFormatString, outFormat: "EEEE"))
                                .font(.subheadline)
                                .padding(.bottom)
                            let datosHorarios = Array(zip(d.temperature, d.sky))
                            HStack(spacing: 20) {
                                ForEach(datosHorarios, id:\.0.period) { dato in
                                    HourlyDataView(period: dato.0.period!, temp: dato.0.value, sky: dato.1.description)
                                }
                            }
                        }
                        Divider().frame(height: 100)
                    }
                }
            }
        }
    }
}

struct HourlyDataView: View {
    
    let period, temp: String
    let sky: AEMETSkyDescription
    
    var body: some View {
        VStack(spacing: 10) {
            Text(period + "h")
                .foregroundColor(Color.gray)
            Image(systemName: weatherIcons[sky, default: "tornado"]).font(.system(size: 24))
            Text(temp + "º")
                .fontWeight(.bold)
        }
    }
}

/// List of each one of the daily predictions
struct DailyPredictionListView: View {
    
    let predictions: AEMETDailyPredictionContainer
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Predicción diaria")
                .font(.headline)
            VStack(alignment: .custom) {
                ForEach(predictions.prediction.day, id:\.date) { d in
                    //Text(predictions.prediction.day[0].sky[0].description)
                    DailyPredictionView(date: d.date, min: String(d.temperature.min), max: String(d.temperature.max), sky: d.sky[0].description)
                }
            }
        }
    }
}

struct DailyPredictionView: View {
    
    let date, min, max: String
    let sky: AEMETSkyDescription
    
    var body: some View {
        HStack {
            Text(getFormattedDateFromString(dateString: date, inFormat: isoDateFormatString, outFormat: "EEEE d"))
            Divider().frame(height: 20).alignmentGuide(.custom) { $0[.leading] }
            Text(String(max) + "º")
            Text(String(min) + "º")
            Divider().frame(height: 20)
            Image(systemName: weatherIcons[sky, default: "tornado"])
            Text(sky.rawValue)
        }
    }
    
}

struct CustomAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        return context[.leading]
    }
}

extension HorizontalAlignment {
    static let custom: HorizontalAlignment = HorizontalAlignment(CustomAlignment.self)
}

// MARK: - Previews

struct MetadataView_Previews: PreviewProvider {
    
    static var previews: some View {
        MetadataView(province: "Provincia", predictionDate: "2020-07-06T00:00:00")
    }
}

struct HourlyDataView_Previews: PreviewProvider {
    
    static var previews: some View {
        HourlyDataView(period: "12:00", temp: "23", sky: AEMETSkyDescription.cubierto)
    }
}

struct DailyPredictionView_Previews: PreviewProvider {
    
    static var previews: some View {
        DailyPredictionView(date: "2020-07-06T00:00:00", min: "19", max: "34", sky: AEMETSkyDescription.cubierto)
    }
}
