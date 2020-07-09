//
//  TownListView.swift
//  Meteo
//
//  Created by José María Martín Luque on 03/07/2020.
//

import SwiftUI

struct TownListView: View {
    
    @EnvironmentObject var townStore: TownStore
    
    @State private var searchText : String = ""
    @Binding var isSheetOpened : Bool
    
    #if os(macOS)
    @State var selectedTown = Set<AEMETTown>()
    #endif
    
    @ViewBuilder
    var body: some View {
        #if os(macOS)
        VStack {
            SearchBar(text: $searchText, placeholder: "Búsqueda de municipios")
            if (searchText.isEmpty) {
                VStack {
                    Spacer()
                    Text("Los resultados de la búsqueda se mostrarán aquí")
                    Spacer()
                }
            } else {
                List(townStore.getTowns(containingString: searchText), id: \.self, selection: $selectedTown) { town in
                    Text(town.name)
                }.id(UUID())
            }
            Spacer()
            Button(action: {
                self.townStore.addFavouriteTown(Array(selectedTown)[0])
                self.isSheetOpened = false
            }, label: {
                Text("OK")
            })
        }.frame(width: 400, height: 300)
        .padding()
        #else
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
        #endif
    }
}

struct TownListView_Previews: PreviewProvider {
    static var previews: some View {
        TownListView(isSheetOpened: .constant(true)).environmentObject(TownStore())
    }
}
