//
//  TravelView.swift
//  AddProductAddress
//
//  Created by SD.Man on 2020/10/30.
//  未解决List UI问题

import SwiftUI
import MapKit
import CoreLocation

private let width = UIScreen.main.bounds.width
private let iconWidth = UIScreen.main.bounds.width / 8
private let iconHeight = UIScreen.main.bounds.width / 8
private let showHeight = UIScreen.main.bounds.height / 3.5
private var daddr = ""
private var locationManager: CLLocationManager = CLLocationManager()

struct makeList: View {
    var image = "旅游攻略"
    
    //    @AppStorage("country", store: UserDefaults(suiteName: "group.tech.sdman.AddProductAddress")) private var country = ""
    //    @AppStorage("site", store: UserDefaults(suiteName: "group.tech.sdman.AddProductAddress")) private var site = ""
    
    @State var index = 0 // ForEach列表对应的每个item的index
    @State private var country = [String](repeating: "", count: 100)
    @State private var site = [String](repeating: "", count: 100)
    /* 存疑：可以使用index通过userDefaults来绑定每个item（的内容），用于更新和读取item内容 */
    
    func getIndexContent() {
        
    }
    
    func saveIndexContent() {
        
    }
    
    var body: some View {
        HStack {
            Image(image)
                .resizable()
                .frame(width: iconWidth, height: iconHeight)
            VStack(alignment: .leading) {
                TextField("国家: ", text: $country[index])
                TextField("地点: ", text: $site[index])
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Button {
                print("copy site in index: \(index)")
                // copy site to pasteboard
            } label: {
                Text("复制").padding(10)
            }.foregroundColor(.black).background(Color.blue).cornerRadius(10)
        }
        .onDisappear(perform: {
            saveIndexContent()
        })
        .onAppear(perform: {
            getIndexContent()
        })
    }
}

//class location: NSObject, CLLocationManagerDelegate {
//
//    var locationManager = CLLocationManager()
//    var lat = CLLocationDegrees(0)
//    var lon = CLLocationDegrees(0)
//
//    override init() {
//        locationManager.requestWhenInUseAuthorization() //请求授权获取当前位置信息
//    }
//
//    func getLocation() {
//        locationManager.delegate = self
//
//        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters //位置精度
//
//        locationManager.requestLocation()
//
//
//    }
//
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print(error)
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        lat = locations[0].coordinate.latitude // 纬度
//        lon = locations[0].coordinate.longitude // 经度
//        print(lat, lon)
//    }
//
//}

struct mapView: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.showsUserLocation = true
        view.userTrackingMode = .follow
        
//        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
                
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//              if let location = locationManager.location?.coordinate// 用可选链式调用避免第一次未授权定位时强制解包引发闪退
                let location = view.userLocation.coordinate // 使用MapView中的定位，避免使用CLLocationManager中的偏移定位
                let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
                let region = MKCoordinateRegion(center: location, span: span)
                view.setCenter(location, animated: true)
                view.setRegion(region, animated: true)
                locationManager.stopUpdatingLocation() // 点击授权后停止不断弹出获取定位弹窗
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: mapView
        
        init(_ parent: mapView) {
            self.parent = parent
        }
    }
}

struct goToMap {
    
    // 如果你的URL中有中文，直接放在网络请求中就会崩溃
    // open iOS Map，可以尝试使用Universial Link
    func launchiOSMap(daddr: String) {
        let iOSMapUrl = "http://maps.apple.com/?q=\(daddr)&dirflg=d&t=m"
        
        // encode
        let newUrl = iOSMapUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        // decode
        if let url = URL(string: newUrl) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("iOSMapUrl cannot open")
            }
        }
    }
    
    // open Gaode Map
    func launchGaodeMap(daddr: String) {
        let gaodeMapUrl = "iosamap://poi?sourceApplication=PackUP&name=\(daddr)&dev=1"
        
        // encode
        let newUrl = gaodeMapUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        // decode
        if let url = URL(string: newUrl) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("gaodeMapUrl cannot open")
            }
        }
    }
    
    // open Baidu Map
    func launchBaiduMap(daddr: String) {
        let baiduMapUrl = "baidumap://map/nearbysearch?query=\(daddr)&radius=4000&src=tech.sdman.AddProductAddress"
        
        // encode
        let newUrl = baiduMapUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        // decode
        if let url = URL(string: newUrl) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("baiduMapUrl cannot open")
            }
        }
    }
}

struct TravelView: View {
    
    @EnvironmentObject var travelData: TravelData
    @State private var inputPlace = ""
    @State private var isAlert = false
    
    var goMap = goToMap()
    
    var isInput: Bool {
        inputPlace.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 5) {
            // 显示地图
            mapView()
                .frame(width: width, height: showHeight, alignment: .center)
            
            HStack {
                TextField("输入地址", text: $inputPlace).frame(height: 35).border(Color.gray, width: 2).cornerRadius(7).padding(10)
                Button {
                    self.updateTravelData() // 更新travelData对象的数据
                    self.inputPlace = "" // 点击添加后清空输入框
                    self.endEditing() // 收起键盘
                    TravelTool.replacer.saveTravelData(travelData: travelData)
                } label: {
                    Text("添加")
                        .font(.title3)
                        .padding(5)
                }
                .disabled(isInput)
                .foregroundColor(.black)
                .background(isInput ? Color.gray : Color.blue)
                .cornerRadius(5)
                .padding(10)
            }
            
            // 打卡地位置List
            List {
                ForEach(0..<travelData.TravelCount, id: \.self) { index in
                    HStack {
                        Button {
                            daddr = travelData.placeList[index]
                            self.isAlert = true
                        } label: {
                            HStack {
                                Text(travelData.placeList[index])
                                Spacer()
                            }
                        }
                        
                        Button {
                            travelData.isCompleted[index].toggle()
                        } label: {
                            Image(systemName: travelData.isCompleted[index] ? "checkmark" : "circle" )
                        }
                        .frame(width: 40, height: 40)
                    }.foregroundColor(travelData.isCompleted[index] ? Color.gray : Color.blue)
                }
                .onDelete(perform: deleteList)
            }
            .buttonStyle(BorderlessButtonStyle()) // 分离两个Button，不然处于同一个HStack会一起点击
        } // end VStack
        .actionSheet(isPresented: $isAlert, content: { () -> ActionSheet in
            ActionSheet(title: Text("地图类型"), message: Text("选择你要打开的地图"), buttons: [
                .default(Text("苹果地图"), action: {
                    goMap.launchiOSMap(daddr: daddr)
                }),
                .default(Text("高德地图"), action: {
                    goMap.launchGaodeMap(daddr: daddr)
                    print("2")
                }),
                .default(Text("百度地图"), action: {
                    goMap.launchBaiduMap(daddr: daddr)
                    print("3")
                }),
                .cancel()
            ])
        })
        .onDisappear(perform: {
            // 页面消失时encode数据进行保存
            TravelTool.replacer.saveTravelData(travelData: travelData)
        })
        .onAppear(perform: {
            // 页面显示时decode数据进行取出
            let transf = TravelTool.replacer.readTravelData() // 由于@EnvironmentObject不能直接修改，只能间接复制给属性
            travelData.TravelCount = transf.TravelCount
            travelData.isCompleted = transf.isCompleted
            travelData.travelPlace = transf.travelPlace
            travelData.placeList = transf.placeList
            print(transf.TravelCount,transf.isCompleted,transf.placeList)
        })
        .navigationBarTitle("目的地", displayMode: .automatic)
        .navigationBarUIColor(.blue)
        .navigationBarItems(trailing: EditButton())
    }
    
    // 更新model，使得观察者travelData能观察model变化及时刷新view
    func updateTravelData() {
        travelData.TravelCount += 1
        travelData.travelPlace = inputPlace
        travelData.placeList.append(travelData.travelPlace)
        travelData.isCompleted.append(false)
    }
    
    // 当List发生onDelete行为时调用该函数删除置顶item
    func deleteList(at offsets: IndexSet) {
        if let first = offsets.first { //获得索引集合里的第一个元素，然后从数组里删除对应索引的元素
            travelData.TravelCount -= 1
            travelData.placeList.remove(at: first)
        }
    }
}

extension TravelView {
    
    // 收起键盘
    func endEditing() {
        //UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        keyWindow?.endEditing(true)
    }
    
}

struct TravelView_Previews: PreviewProvider {
    static var previews: some View {
        TravelView()
            .environmentObject(TravelData())
    }
}
