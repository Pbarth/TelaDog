//
//  Dog.swift
//  TelaDog
//
//  Created by Pierre BARTHELEMY on 04/04/2023.
//

import Foundation

struct Dog: Identifiable, Hashable {
    let id: UUID = UUID()
    let name: String
    let subBreed: [String]
    
    public init(name: String, subBreed: [String]) {
        self.name = name
        self.subBreed = subBreed
    }
}
