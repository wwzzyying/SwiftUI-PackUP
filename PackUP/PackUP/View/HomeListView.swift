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
    
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
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
//            Form { // 可以多个Section
//                Section { // footer: Text("收货信息：\(data.name) \(data.phoneNumber) \(data.address)").lineLimit(1)
//                    List() {
//                        NavigationLink(destination: AddressList()) {
//                            navigationLinkItem(icon: "地址", text: "收货地址")
//                        }
//                    }
//                }
//                .frame(width: UIScreen.main.bounds.width, height: 60, alignment: .leading)
//
//                Section { //(footer: Text("身份信息这里就不显示预览了"))
//                    List() {
//                        NavigationLink(destination: TravelView()) {
//                            navigationLinkItem(icon: "旅游攻略", text: "旅游打卡地")
//                        }
//                    }
//                }
//                .frame(width: UIScreen.main.bounds.width, height: 60, alignment: .center)
//
//                Section { //(footer: Text("placeholder"))
//                    List() {
//                        NavigationLink(destination: VoiceView()) {
//                            navigationLinkItem(icon: "luyin", text: "录音处理器")
//                        }
//                    }
//                }
//                .frame(width: UIScreen.main.bounds.width, height: 60, alignment: .center)
//
//                Section {
//                    List() {
//                        NavigationLink(destination: EasterEggView()) {
//                            navigationLinkItem(icon: "猫", text: "猫咪识别器")
//                        }
//                    }
//                }
//                .frame(width: UIScreen.main.bounds.width, height: 60, alignment: .center)
//            }
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
                        NavigationLink(destination: VoiceView()) {
                            CardView(icon: "录音", text: "录音处理器")
                        }
                        .padding(.horizontal)
                        Spacer()
                        NavigationLink(destination: EasterEggView()) {
                            CardView(icon: "放大镜", text: "猫咪识别器")
                        }
                        .padding(.horizontal)
                        Spacer()
                    }
                    .padding(.vertical, 30)
                    
                    Spacer()
                }
                .navigationBarTitle("PackUP")
            }
        }.accentColor(.white) // 修改back button颜色
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
