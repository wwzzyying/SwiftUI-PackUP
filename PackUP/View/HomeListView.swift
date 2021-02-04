//
//  HomeListView.swift
//  AddProductAddress
//
//  Created by SD.Man on 2020/10/25.
//

import SwiftUI

private let width = UIScreen.main.bounds.width
private let contentHeight = UIScreen.main.bounds.height
private let showHeight = UIScreen.main.bounds.height / 4.5

// 使用UserDefaults获取data
struct DataInfo {
    let userDefault = UserDefaults(suiteName: "group.tech.sdman.AddProductAddress")
    var arg = ""
    func get() -> String {
        userDefault?.object(forKey: arg) as? String ?? ""
    }
}

struct HomeListView: View {
    @ObservedObject var data = Address()
    @State private var selection = 0
    
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
    }
    
    var body: some View {
//        ZStack() {
//            Image("scene")
//            Text("Pack UP!")
//                .font(.largeTitle)
//                .foregroundColor(.black)
//                .bold()
//        }.frame(width: width, height: showHeight)
        NavigationView {
            // TabView不能放在NavigationView上，会导致NavigationLink跳转页面被覆盖一个Tab
            TabView(selection: self.$selection) {
    //            Form { // 可以多个Section
    //                Section { // footer: Text("收货信息：\(data.name) \(data.phoneNumber) \(data.address)").lineLimit(1)
    //                    List() {
    //                        NavigationLink(destination: AddressList()) {
    //                            navigationLinkItem(icon: "地址", text: "收货地址")
    //                        }
    //                    }
    //                }
                ZStack {
                    Image("背景")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .scaledToFill()
                    
                    VStack {
                        HStack {
                            Spacer()
                            NavigationLink(destination: AddressList()) {
                                CardView(icon: "地址", text: "地址簿")
                            }
                            .padding(.horizontal)
                            Spacer()
                            NavigationLink(destination: TravelView()) {
                                CardView(icon: "打卡", text: "旅游打卡")
                            }
                            .padding(.horizontal)
                            Spacer()
                        }
                        .padding(.top, contentHeight / 7)
                        
                        HStack {
                            Spacer()
                            NavigationLink(destination: VoiceView(audioRecorder: AudioRecorder())) {
                                CardView(icon: "录音", text: "录音器")
                            }
                            .padding(.horizontal)
                            Spacer()
                            NavigationLink(destination: EasterEggView()) {
                                CardView(icon: "放大镜", text: "物体识别器")
                            }
                            .padding(.horizontal)
                            Spacer()
                        }
                        .padding(.vertical, 30)
                        
                        Spacer()

                    }
                    
                }
                
                .tabItem({
                    Image(systemName: "house")
                    // 需要修改颜色
                    Text("主页面")
                })
                .tag(0)
                
                // 设置
                ZStack {
                    Image("背景2")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .scaledToFill()
                    
                    Text("设置")
                }
                .tabItem({
                    Image(systemName: "gear")
                    // 需要修改颜色
                    Text("设置")
                })
                .tag(1)
            }
            .navigationBarTitle("PackUP")
        }.accentColor(.white)// 修改back button颜色,需要作用在NavigationView上
    }
}

// 提取每个linkItem出来，参数为icon和text
struct navigationLinkItem: View {
    var icon: String
    var text: String
    
    var body: some View {
        Image(icon)
            .resizable()
            .frame(width: 40, height: 40)
        Text(text)
            .bold()
    }
}

struct HomeListView_Previews: PreviewProvider {
    static var previews: some View {
        HomeListView()
    }
}
