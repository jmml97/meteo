//
//  TownListView.swift
//  Meteo
//
//  Created by José María Martín Luque on 10/07/2020.
//

import SwiftUI

struct TownListView: View {
    
    @EnvironmentObject var townStore: TownStore
    
    @State private var searchText : String = ""
    @Binding var isSheetOpened : Bool
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, placeholder: "Búsqueda de municipios")
                if (searchText.isEmpty) {
                    VStack {
                        Spacer()
                        Text("Los resultados de la búsqueda se mostrarán aquí")
                        Spacer()
                    }.navigationTitle("Elige un municipio")
                } else {
                    List(townStore.getTowns(containingString: searchText), id: \.self) { town in
                        Button(action: {
                            self.townStore.addFavouriteTown(town)
                            //self.favouriteTownManager.favouriteTowns.append(town)
                            self.isSheetOpened = false
                        }, label: {
                            Text(town.name)
                        })
                    }.id(UUID())
                    .navigationTitle("Elige un municipio").id(UUID())
                    // .id(UUID()) para que la lista se regenere más rápido
                    // ver: https://www.hackingwithswift.com/articles/210/how-to-fix-slow-list-updates-in-swiftui
                }
                
            }
        }
    }
}

struct TownListView_Previews: PreviewProvider {
    static var previews: some View {
        TownListView(isSheetOpened: .constant(true)).environmentObject(TownStore())
    }
}
