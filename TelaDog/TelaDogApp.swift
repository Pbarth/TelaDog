//
//  TelaDogApp.swift
//  TelaDog
//
//  Created by Pierre BARTHELEMY on 03/04/2023.
//

import SwiftUI

@main
struct TelaDogApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                DogListView()
            }
        }
    }
}
