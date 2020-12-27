//
//  TravelData.swift
//  PackUP
//
//  Created by SD.Man on 2020/11/8.
//

import SwiftUI
import Combine

final class TravelData: NSObject, ObservableObject, NSCoding {
    /* 遵守NSCoding协议后一定要实现encode和init方法，并在其中进行属性的编码解码操作，
        因为archivedData和unarchiveTopLevelObjectWithData需要调用实现了的这两个方法 */
    func encode(with coder: NSCoder) {
        coder.encode(TravelCount, forKey: "count")
        coder.encode(isCompleted, forKey: "complete")
        coder.encode(travelPlace, forKey: "place")
        coder.encode(placeList, forKey: "list")
    }
    
    init?(coder: NSCoder) {
        TravelCount = coder.decodeInteger(forKey: "count")
        isCompleted = coder.decodeObject(forKey: "complete") as? [Bool] ?? []
        travelPlace = coder.decodeObject(forKey: "place") as? String ?? ""
        placeList = coder.decodeObject(forKey: "list") as? [String] ?? []
        print("init")
    }
    
    override init() {
        super.init() // This got rid of the "Missing argument for parameter 'coder' in call.
    }
    
    @Published var TravelCount = 0
    @Published var isCompleted = [Bool]()
    @Published var travelPlace = ""
    @Published var placeList = [String]()
}

// 存储和读取TravelData
class TravelTool: NSObject {
    
    var travel: TravelData?
    static let replacer = TravelTool()
    
    func saveTravelData(travelData: TravelData) {
        self.travel = travelData
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: travel!, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: "travelData")
            print("成功写入到磁盘")
        } catch {
            print("save error")
        }
    }
    
    func readTravelData() -> TravelData {
        if let traveldata = UserDefaults.standard.object(forKey: "travelData") as? Data {
            if let decodeTravel = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(traveldata) as? TravelData {
                travel = decodeTravel
            }
        }
        print("从磁盘取出")
        return self.travel ?? TravelData()
    }
}
