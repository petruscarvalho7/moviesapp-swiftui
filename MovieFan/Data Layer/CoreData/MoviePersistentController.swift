//
//  MoviePersistentController.swift
//  MovieFan
//
//  Created by Petrus Carvalho on 21/06/23.
//

import Foundation
import CoreData

class MoviePersistentController: ObservableObject {
    var persistentContainer = NSPersistentContainer(name: "MovieFan")
    
    init() {
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("error: \(error)")
            }
        }
    }
    
}
