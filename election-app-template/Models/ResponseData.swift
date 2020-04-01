//
//  ResponseData.swift
//  election-app-template
//
//  Created by Kate Halushka on 3/27/20.
//

import Foundation

struct Response: Codable {
     let records: [Record]
}

struct Record: Codable {
    let id: String?
    let fields: Field
}

struct Field: Codable {
    let Candidates: [String]?
    let Position: String?
    let Name: String?
}
