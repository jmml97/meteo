//
//  FavouriteTownManager.swift
//  Meteo
//
//  Created by José María Martín Luque on 05/07/2020.
//

import Foundation
import SQLite

class TownStore: ObservableObject {
    
    @Published var favouriteTowns: [AEMETTown] = []
    @Published var townData: [AEMETTown] = []
    
    var db: Connection? = nil
    
    let dbFilename = "meteo.sqlite3"
    
    init() {
        
        let fileManager = FileManager.default
        var dbPath = ""
        
        do {
            dbPath = try fileManager
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(dbFilename)
                .path
        } catch {
            
        }
        
        do {
            if !fileManager.fileExists(atPath: dbPath) {
                let dbResourcePath = Bundle.main.path(forResource: "meteo", ofType: "sqlite3")!
                try fileManager.copyItem(atPath: dbResourcePath, toPath: dbPath)
            }
        } catch {
            fatalError("Couldn't try to find \(dbFilename) in main bundle.")
        }
        
        do {
            db = try Connection(dbPath)
        } catch {
            fatalError("Couldn't load \(dbFilename) from main bundle:\n\(error)")
        }
        
        favouriteTowns = load(dbFilename: dbFilename, dbTableName: "favouriteTowns")
        townData = load(dbFilename: dbFilename, dbTableName: "towns")
    }
    
    func load<T: Decodable>(dbFilename: String, dbTableName: String) -> [T] {
        
        let towns = Table(dbTableName)
        
        do {
            return try db!.prepare(towns).map { row in
                do {
                    return try row.decode()
                } catch {
                    fatalError("Couldn't decode row \(row)")
                }
            }
        } catch {
            fatalError("Couldn't parse \(dbFilename) as \(T.self):\n\(error)")
        }
    }
    
    func reloadFavouriteTowns() {
        favouriteTowns = load(dbFilename: dbFilename, dbTableName: favouriteTownTableName)
    }
    
    func addFavouriteTown(_ town: AEMETTown) {
        
        let towns = Table("favouriteTowns")
        let name = Expression<String>("name")
        let id = Expression<String>("id")
        
        do {
            let insert = towns.insert(name <- town.name, id <- town.id)
            try db!.run(insert)
//            try db!.run(towns.create { t in
//                t.column(name)
//                t.column(id)
//            })
            reloadFavouriteTowns()
            
        } catch {
            fatalError("Could not insert town data into table: \(error)")
        }
    }
}
