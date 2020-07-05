//
//  TownListView.swift
//  Meteo
//
//  Created by José María Martín Luque on 03/07/2020.
//

import SwiftUI

struct TownListView: View {
    
    @EnvironmentObject var favouriteTownManager: FavouriteTownManager
    
    @State private var searchText : String = ""
    
    @Binding var isSheetOpened : Bool
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                if (searchText.isEmpty) {
                    VStack {
                        Spacer()
                        Text("Usa el cuadro de búsqueda")
                        Spacer()
                    }.navigationTitle("Elige un municipio")
                } else {
                    List(townData.filter {
                        self.searchText.isEmpty ? true : $0.nombre.lowercased().contains(self.searchText.lowercased())
                    }, id:\.id) { town in
                        Button(action: {
                            self.favouriteTownManager.favouriteTowns.append(town)
                            self.isSheetOpened = false
                        }, label: {
                            Text(town.nombre)
                        })
                    }.navigationTitle("Elige un municipio")
                }
                
            }
        }
    }
}

struct TownListView_Previews: PreviewProvider {
    static var previews: some View {
        TownListView(isSheetOpened: .constant(true)).environmentObject(FavouriteTownManager())
    }
}
