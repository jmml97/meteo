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
    .cubiertoLluviaEscasa: "cloud.drizzle",
    .intervalosNubosos: "cloud.sun",
    .intervalosNubososLluvia: "cloud.sun.rain",
    .intervalosNubososLluviaEscasa: "cloud.sun.rain",
    .intervalosNubososTormenta: "cloud.sun.bolt",
    .pocoNuboso: "cloud.sun",
    .nuboso: "smoke",
    .niebla: "cloud.fog",
]

let isoDateFormatString = "yyyy-MM-dd'T'HH:mm:ss"


// MARK: - Helper functions

/// Returns a string in the desired format from a date object
func getStringDate(from date: Date, formattedAs format: String) -> String {
    
    let formatter = DateFormatter()
    formatter.dateFormat = format
    formatter.locale = Locale(identifier: "es_ES")
    
    return formatter.string(for: date)!
    
}

// MARK: - Views

/// Main prediction view
/// - Parameter townID: id of the town this view represents, needed to pull data
struct PredictionViewContainer: View {
    
    @ObservedObject var manager = PredictionStore()
    var townID: String
    
    @ViewBuilder
    var body: some View {
        
        if let model = manager.model {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    #if os(macOS)
                    Text(model.townName)
                        .font(.title)
                        .fontWeight(.bold)
                    #endif
                    MetadataView(province: model.province, predictionDate: model.dateCreated)
                    CurrentDataView(skyDescription: model.days.first!.hourlyData.first!.sky, temperature: model.days.first!.hourlyData.first!.temperature)
                    Spacer().frame(height: 50)
                    HourlyPredictionView(model: model)
                    Spacer().frame(height: 50)
                    DailyPredictionListView(model: model)
                    Spacer()
                }.padding()
            }
            .navigationTitle(model.townName)
            .frame(minWidth: 300, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
        } else {
            loading
        }
        
    }
    
    var loading: some View {
        VStack {
            Spacer()
            ProgressView("Cargando").onAppear {
                manager.townID = townID
                manager.getPredictionModel()
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            Spacer()
        }
    }
}

struct MetadataView: View {
    
    let province: String
    let predictionDate: Date
    
    var body: some View {
        HStack {
            Text(province).font(Font.system(.body).smallCaps())
            Divider().frame(height: 20)
            Text("Elaboración: \(getStringDate(from: predictionDate, formattedAs: "MM/dd/yyyy HH:mm"))")
        }
    }
}

struct CurrentDataView: View {
    
    let skyDescription: AEMETSkyDescription
    let temperature: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(String(temperature) + "º").font(.system(size: 36))
                Image(systemName: weatherIcons[skyDescription, default: "tornado"]).font(.system(size: 36))
            }
            Text(skyDescription.rawValue)
        }
    }
}

struct HourlyPredictionView: View {
    
    let model: PredictionModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Predicción horaria").font(.headline)
            scroll
        }
    }
    
    var scroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(model.days.filter { d in
                    !d.hourlyData.isEmpty
                }, id:\.date) { d in
                    VStack(alignment: .leading) {
                        Text(getStringDate(from: d.date, formattedAs: "EEEE d"))
                            .font(.subheadline)
                            .padding(.bottom)
                        HStack(spacing: 20) {
                            ForEach(d.hourlyData, id: \.hour) { h in
                                HourlyDataView(hour: h.hour, temperature: h.temperature, sky: h.sky)
                            }
                        }
                    }
                    Divider().frame(height: 100)
                }
            }
        }
    }
}

struct HourlyDataView: View {
    
    let hour, temperature: Int
    let sky: AEMETSkyDescription
    
    var body: some View {
        VStack {
            Text(String(hour) + "h")
                .foregroundColor(Color.gray)
            Spacer()
            Image(systemName: weatherIcons[sky, default: "tornado"]).font(.system(size: 24))
            Spacer()
            Text(String(temperature) + "º")
                .fontWeight(.bold)
        }.frame(height: 80)
    }
}

/// List of each one of the daily predictions
struct DailyPredictionListView: View {
    
    let model: PredictionModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Predicción diaria")
                .font(.headline)
            VStack {
                ForEach(model.days, id:\.date) { d in
                    DailyPredictionView(date: d.date, min: d.min, max: d.max, sky: d.sky)
                }
            }
        }
    }
}

struct DailyPredictionView: View {
    
    let date: Date
    let min, max: Int
    let sky: AEMETSkyDescription
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(getStringDate(from: date, formattedAs: "EEEE d"))
                .font(.subheadline)
            HStack(alignment: .top) {
                Text(String(max) + "º")
                    .fontWeight(.semibold)
                Text(String(min) + "º")
                Spacer()
                Text(sky.rawValue)
                Image(systemName: weatherIcons[sky, default: "tornado"])
            }
        }.frame(maxWidth: 400)
        .padding(.top)
        
    }
    
}


// MARK: - Previews

struct MetadataView_Previews: PreviewProvider {
    
    static var previews: some View {
        MetadataView(province: "Provincia", predictionDate: dateFrom(string: "2020-07-06T00:00:00"))
    }
}

struct HourlyDataView_Previews: PreviewProvider {
    
    static var previews: some View {
        HStack {
            HourlyDataView(hour: 12, temperature: 23, sky: AEMETSkyDescription.cubierto)
            HourlyDataView(hour: 13, temperature: 25, sky: AEMETSkyDescription.despejado)
        }
        
    }
}

struct DailyPredictionView_Previews: PreviewProvider {
    
    static var previews: some View {
        DailyPredictionView(date: dateFrom(string: "2020-07-06T00:00:00"), min: 19, max: 34, sky: AEMETSkyDescription.cubierto)
    }
}
