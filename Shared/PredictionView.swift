//
//  PredictionView.swift
//  Meteo
//
//  Created by José María Martín Luque on 02/07/2020.
//

import SwiftUI

let weatherIcons: [AEMETDescripcion: String] = [
    .despejado: "sun.max",
    .cubierto: "cloud",
    .nuboso: "smoke",
    .niebla: "cloud.fog",
]

struct PredictionView: View {
    
    @StateObject var loader = PredictionDataLoader()
    var townID: String
    
    @ViewBuilder
    var body: some View {
        if let predictions = loader.predictions {
            VStack(alignment: .leading) {
                
                HStack {
                    Text(predictions.provincia)
                    Text("Elaborado: \(predictions.elaborado)")
                }
                .padding(10)
                Text("Predicción horaria")
                    .font(.title)
                    .padding(10.0)
                ScrollView(.horizontal) {
                    HStack(spacing: 20) {
                        VStack {
                            Text("Hora")
                            Text("Cielo")
                            Text("Temperatura")
                        }
                        ForEach(predictions.prediccion.dia, id:\.fecha) { d in
                            Text(d.fecha)
                            let datosHorarios = Array(zip(d.temperatura, d.estadoCielo))
                            ForEach(datosHorarios, id:\.0.periodo) { dato in
                                datoHorarioView(periodo: dato.0.periodo, temp: dato.0.value, estadoCielo: dato.1.descripcion)
                            }
                        }
                    }
                }.padding(.leading, 10.0).navigationTitle(predictions.nombre)
                Spacer()
            }
        } else {
            ProgressView("Cargando").onAppear {
                loader.load(townID)
            }
        }
        
    }
}

struct PredictionView_Previews: PreviewProvider {
    static var previews: some View {
        PredictionView(townID: "29701")
    }
}

struct datoHorarioView: View {
    
    let periodo, temp: String
    let estadoCielo: AEMETDescripcion
    
    var body: some View {
        VStack(spacing: 5) {
            Text(periodo + "h")
            Image(systemName: weatherIcons[estadoCielo, default: "tornado"])
            Text(temp + "º")
        }
    }
}


