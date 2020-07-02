//
//  PredictionView.swift
//  Meteo
//
//  Created by José María Martín Luque on 02/07/2020.
//

import SwiftUI

struct PredictionView: View {
    
    @ObservedObject private var model = PredictionViewModel()
    
    var body: some View {
        List(model.predictions) { prediction in
            Text(prediction.nombre ?? "")
            Text(prediction.provincia ?? "")
            Text(prediction.elaborado ?? "")
        }
    }
}

struct PredictionView_Previews: PreviewProvider {
    static var previews: some View {
        PredictionView()
    }
}
