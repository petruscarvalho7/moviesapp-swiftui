//
//  DataError.swift
//  MovieFan
//
//  Created by Petrus Carvalho on 03/06/23.
//

import Foundation

enum DataError: Error {
    case networkingError(String)
    case coreDataError(String)
}
