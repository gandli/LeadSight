//
//  LeadSightApp.swift
//  LeadSight
//
//  Created by user on 2026/3/1.
//

import SwiftUI

@main
struct LeadSightApp: App {
    @State private var dataStore = DataStore()
    @State private var leadManager = LeadManager()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(dataStore)
                .environment(leadManager)
        }
    }
}