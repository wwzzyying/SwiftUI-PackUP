//
//  AddProductAddressApp.swift
//  AddProductAddress
//
//  Created by SD.Man on 2020/10/9.
//

import SwiftUI

@main
struct AddProductAddressApp: App {
    var body: some Scene {
        WindowGroup {
            HomeListView()
                .environmentObject(TravelData())
        }
    }
}
