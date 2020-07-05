//
//  PredictionView.swift
//  Meteo
//
//  Created by José María Martín Luque on 02/07/2020.
//

import SwiftUI

struct PredictionView: View {
    
    @StateObject var loader = PredictionDataLoader()
    var townID: String
    
    @ViewBuilder
    var body: some View {
        if loader.predictions != nil {
            VStack(alignment: .leading) {
                
                HStack {
                    Text(loader.predictions?.provincia ?? "Provincia")
                    Text("Elaborado: \(loader.predictions?.elaborado ?? "")")
                }
                .padding(10)
                Text("Predicción horaria")
                    .font(.title)
                    .padding(10.0)
                ScrollView(.horizontal) {
                    HStack(spacing: 20) {
                        let datosHorarios = Array(zip((loader.predictions?.prediccion.dia[0].temperatura)!, (loader.predictions?.prediccion.dia[0].estadoCielo)!))
                        ForEach(datosHorarios, id: \.0.periodo) { dato in
                            datoHorarioView(periodo: dato.0.periodo, temp: dato.0.value, estadoCielo: dato.1.descripcion)
                        }
                    }
                }.padding(.leading, 10.0).navigationTitle(loader.predictions?.nombre ?? "Ciudad")
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
            switch estadoCielo {
            case AEMETDescripcion.despejado:
                Image(systemName: "sun.max")
            case AEMETDescripcion.cubierto:
                            Image(systemName: "cloud")
            case AEMETDescripcion.nuboso:
                            Image(systemName: "smoke")
            case AEMETDescripcion.niebla:
                            Image(systemName: "cloud.fog")
            default:
                Image(systemName: "tornado")
            }
            Text(temp + "º")
        }
    }
}


