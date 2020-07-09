//
//  FavouriteTownManager.swift
//  Meteo
//
//  Created by José María Martín Luque on 05/07/2020.
//

import Foundation
import SQLite

/// Stores and allows retrieving all town related data from a SQLite database
class TownStore: ObservableObject {
    
    @Published var favouriteTowns: [AEMETTown] = []
    //@Published var townData: [AEMETTown] = []
    
    var db: Connection? = nil
    
    let favouriteTownTableName = "favouriteTowns"
    let townsTableName = "towns"
    
    let dbFilename = "meteo.sqlite3"
    
    init() {
        
        // Database in bundle is read-only so the first time we must create a copy in a writtable directory.
        let fileManager = FileManager.default
        var dbPath = ""
        
        do {
            dbPath = try fileManager
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(dbFilename)
                .path
        } catch {
            fatalError("Couldn't find the included database at path \(dbFilename):\(error)")
        }
        
        do {
            if !fileManager.fileExists(atPath: dbPath) {
                let dbResourcePath = Bundle.main.path(forResource: "meteo", ofType: "sqlite3")!
                try fileManager.copyItem(atPath: dbResourcePath, toPath: dbPath)
            }
        } catch {
            fatalError("Couldn't create database in a writtable directory:\(error)")
        }
        
        do {
            db = try Connection(dbPath)
        } catch {
            fatalError("Couldn't establish a connection to the database:\(error)")
        }
        
        favouriteTowns = load(dbTableName: favouriteTownTableName)
        //townData = load(dbFilename: dbFilename, dbTableName: townsTableName)
    }
    
    /// Loads and decodes data from a table.
    /// - Parameter dbTableName: name of the table whose data is used to decode.
    func load<T: Decodable>(dbTableName: String) -> [T] {
        
        let data = Table(dbTableName)
        
        do {
            return try db!.prepare(data).map { row in
                do {
                    return try row.decode()
                } catch {
                    fatalError("Couldn't decode row \(row)")
                }
            }
        } catch {
            fatalError("Couldn't parse the contents of \(dbTableName) as \(T.self):\n\(error)")
        }
    }
    
    func reloadFavouriteTowns() {
        favouriteTowns = load(dbTableName: favouriteTownTableName)
    }
    
    /// Adds a town to the favourite town table and reloads the `favouriteTowns` array.
    func addFavouriteTown(_ town: AEMETTown) {
        
        let towns = Table(favouriteTownTableName)
        let name = Expression<String>("name")
        let id = Expression<String>("id")
        
        let townsWithSameName = towns.filter(name == town.name)
        
        do {
            if (try db!.scalar(townsWithSameName.count) == 0) {
                do {
                    let insert = towns.insert(name <- town.name, id <- town.id)
                    try db!.run(insert)
                    reloadFavouriteTowns()
                    
                } catch {
                    fatalError("Could not insert town data into table: \(error)")
                }
            }
        } catch {
            fatalError("Could not count towns with same name: \(error)")
        }
        
    }
    
    /// Removes a town from the favourite town table and reloads the `favouriteTowns` array.
    func removeFavouriteTown(at offsets: IndexSet) {
        for offset in offsets {
            let favouriteTownsTable = Table(favouriteTownTableName)
            let id = Expression<String>("id")
            
            let town = favouriteTownsTable.filter(id == favouriteTowns[offset].id)
            do {
                try db!.run(town.delete())
                reloadFavouriteTowns()
            } catch {
                fatalError("Could not delete favourite town: \(error)")
            }
        }
    }
    
    /// Returns an array of towns whose name contains `containingString`.
    /// - Parameter containingString: string used to look for towns.
    func getTowns(containingString: String) -> [AEMETTown] {
        let towns = Table(townsTableName)
        let name = Expression<String>("name")
        let id = Expression<String>("id")
        
        var returnTowns: [AEMETTown] = []
        
        let filteredTowns = towns.filter(name.like("%"+containingString.lowercased()+"%"))
        
        do {
            for t in try db!.prepare(filteredTowns) {
                returnTowns.append(AEMETTown(name: t[name], id: t[id]))
            }
        } catch {
            fatalError("Could not create array of filtered elements: \(error)")
        }
        
        return returnTowns
    }
}
