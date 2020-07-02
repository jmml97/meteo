//
//  MeteoApp.swift
//  Shared
//
//  Created by José María Martín Luque on 02/07/2020.
//

import SwiftUI

@main
struct MeteoApp: App {
    var body: some Scene {
        WindowGroup {
            PredictionView()
        }
    }
}

struct MeteoApp_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
