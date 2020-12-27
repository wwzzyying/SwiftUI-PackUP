//
//  AddressData.swift
//  AddProductAddress
//
//  Created by SD.Man on 2020/10/19.
//

import Foundation

class Address: ObservableObject {
    @Published var name = ""
    @Published var phoneNumber = ""
    @Published var address = ""
    @Published var type = ""
    let userDefault = UserDefaults(suiteName: "group.tech.sdman.AddProductAddress")
    
    func updateData(Nname: String, NphoneNumber: String, Naddress: String, Ntype: String) {
        name = Nname
        phoneNumber = NphoneNumber
        address = Naddress
        type = Ntype
    }
    
//    func saveData(id: Int) {
//        userDefault?.setValue(name, forKey: "name\(id)")
//        userDefault?.setValue(phoneNumber, forKey: "phoneNumber\(id)")
//        userDefault?.setValue(address, forKey: "address\(id)")
//        userDefault?.setValue(type, forKey: "type\(id)")
//        print("saveData->\(name),\(phoneNumber),\(address)")
//    }
}
