//
//  ContentView.swift
//  AddProductAddress
//
//  Created by SD.Man on 2020/10/9.
//

import SwiftUI

/* navigationLink返回不能主动刷新 */
/* 刷新按钮没用？ delete异常 */
struct AddressList: View {
    
    @AppStorage("count") private var countStorage = 1
    @State private var countList = 1
    @State private var refresh = false // 无效，就算主动刷新，列表数据也还没更新
//    @State private var list: [String] = [String]()
    
    var body: some View {
        ZStack {
            VStack {
                Form {
                    ForEach(0 ..< countList, id: \.self) {index in
//                        let listItemName = list[index]
                        let listItemName = UserDefaults.standard.object(forKey: "address\(index)") as? String ?? ""
                        NavigationLink(listItemName, destination: ContentView(id: index))
                    }
                    .onDelete(perform: deleteList(at:))
                }
                .navigationBarItems(trailing: HStack {
                    Button(action: {
                        self.refresh.toggle()
                        self.refreshList()
                    }, label: {
                        Text(Image(systemName: "arrow.clockwise"))
                    }).padding(.trailing, 10)
                    
                    Button(action: {
                        countStorage = countStorage + 1
                        countList = countStorage
                        
                    }, label: {
                        Text(Image(systemName: "plus"))
                    }).padding(.leading, 10)
                })
                .navigationBarTitle("收货地址列表", displayMode: .automatic)
                .navigationBarUIColor(Color.yellow)
                .onAppear {
                    countList = countStorage
                }
            }
        }
        .popup(isPresented: $refresh) {
            HStack {
                Text("刷新成功")
            }
            .frame(width: 200, height: 60)
            .background(Color.yellow)
            .cornerRadius(15.0)
        }
    }
    
    // 更新列表
    func refreshList() {
        
    }
    
    // 删除列表项
    func deleteList(at offsets: IndexSet) {
        if let index = offsets.first
        { //获得索引集合里的第一个元素，然后从数组里删除对应索引的元素
            print(index)
            // 冒泡删除
            for i in index..<countList-1 {
                replaceObject(index: i)
            }
            // 无论删除哪个，最后一个最终都要删除（针对单独删除最后一个的情况）
            deleteEnd(index: countList-1)
            // 删除结束后更新列表
            countStorage -= 1
            countList = countStorage
        }
    }
    
    // 删除时用index+1内容替换index内容，避免新增item后出现旧数据情况
    func replaceObject(index: Int) {
        let people1 = UserDefaults.standard.object(forKey: "name\(index+1)") as? String ?? ""
        let phone1 = UserDefaults.standard.object(forKey: "phoneNumber\(index+1)") as? String ?? ""
        let address1 = UserDefaults.standard.object(forKey: "address\(index+1)") as? String ?? ""
        let tagIndex1 = UserDefaults.standard.integer(forKey: "tagIndex\(index+1)")
        let type1 = UserDefaults.standard.object(forKey: "type\(index+1)") as? String ?? ""
        
        // index位置保存index+1内容
        UserDefaults.standard.setValue(people1, forKey: "name\(index)")
        UserDefaults.standard.setValue(phone1, forKey: "phoneNumber\(index)")
        UserDefaults.standard.setValue(address1, forKey: "address\(index)")
        UserDefaults.standard.setValue(tagIndex1, forKey: "tagIndex\(index)")
        UserDefaults.standard.setValue(type1, forKey: "type\(index)")
    }
    
    // 最后一个列表项直接清空，无论是删除前面还是删除最后一个，最后一个都是清空的
    func deleteEnd(index: Int) {
        // 清空end内容
        print("end\(index)")
        UserDefaults.standard.setValue("", forKey: "name\(index)")
        UserDefaults.standard.setValue("", forKey: "phoneNumber\(index)")
        UserDefaults.standard.setValue("", forKey: "address\(index)")
        UserDefaults.standard.setValue(0, forKey: "tagIndex\(index)")
        UserDefaults.standard.setValue("", forKey: "type\(index)")
    }
}

struct ContentView: View {
    // id用于字符串插值形成这个页面数据encode对应的Key
    var id: Int
    // 初始化赋值的时候直接创建UserDefaults实例然后直接通过key读取数据
    @State private var people: String = ""
    @State private var phone: String = ""
    @State private var address: String = ""
    @State private var tagIndex: Int = 0
    @State private var type: String = ""
    
    // 初始化view时解码AddressList传来的List下标，构造出不同的Key，得到不同的跳转结果
//    @AppStorage("phoneNumber") private var phone = ""
//    @State private var phone = UserDefaults(suiteName: "group.tech.sdman.AddProductAddress")?.object(forKey: "phoneNumber") as? String ?? ""
//    @AppStorage("address") private var address = ""
//    @State private var address = UserDefaults(suiteName: "group.tech.sdman.AddProductAddress")?.object(forKey: "address") as? String ?? ""
//    @AppStorage("tagIndex") private var tagIndex = 0
//    @AppStorage("type") var type = ""
    
    @State private var isPresent = false // 用于按钮点击时弹窗的出现
    @State private var isPresent2 = false // 用于按钮点击时弹窗的出现
    @State private var isPresent3 = false
    
    let tags = ["我","家","学校","公司","其他"]
    
    var data = Address()
    
    var confirmMsg: String {
        """
        收货人：\(data.name)
        电话号码：\(data.phoneNumber)
        地址：\(data.address)
        地址类型：\(data.type)
        """
    } // 计算属性用于保存弹窗确定消息，使用三引号代替过多的\n换行
    
    var invalidInput: Bool {
        people.isEmpty || phone.isEmpty || address.isEmpty
    }
    
    var body: some View {
        //let displayMode = UITraitCollection.current.userInterfaceStyle //用于获取当前模式，便于根据显示模式修改组件属性
        
        Form {
            Section(header: Text("输入收货人信息")) {
                HStack {
                    Text("收货人")
                    TextField("请填写收货人姓名", text: $people)
                }
                HStack {
                    Text("手机号码")
                    TextField("请填写收货人电话号码", text: $phone)
                        .keyboardType(.numberPad)
                }
                HStack {
                    Text("收货地址")
                    TextEditor(text: $address)
                }
            }
            
            Section(header: Text("地址类型")) {
                Picker("地址归类", selection: $tagIndex) {
                    ForEach(0 ..< tags.count, id: \.self) { (index) in
                        Text(self.tags[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // 点击其他类型输入自定义类型
            if tagIndex == 4 {
                Section(header: Text("自定义类型")) {
                    HStack {
                        TextField("输入其他类型", text: $type)
                        Button {
                            self.endEditing()
                        } label: {
                            Text("确定")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            Section(header: Text("点击保存收货地址")) {
                Button {
                    self.isPresent = true
                    // 点击保存--更新data数据用于显示确认弹窗
                    data.updateData(Nname: people, NphoneNumber: phone, Naddress: address, Ntype: tagIndex==4 ? type : tags[tagIndex])
                    // 点击保存--encode基本数据
                    encodeUserDefaults(en_people: people, en_phone: phone, en_address: address, en_tagIndex: tagIndex, en_type: type)
                } label: { () in
                    Text("保存")
                        .foregroundColor(.blue)
                }
                .disabled(invalidInput) // 基本信息为空则不能点
                .alignmentGuide(.leading) { (dimension) -> CGFloat in
                    dimension[.trailing]
                }
//                .alertX(isPresented: $isPresent) { () -> AlertX in
//                    AlertX(
//                        title: Text("确认地址"),
//                        message: Text("\(confirmMsg)"),
//                        primaryButton: .default(Text("取消")),
//                        secondaryButton: .default(Text("确定")),
//                        theme: displayMode == .light ? .sun(withTransparency: true, roundedCorners: true) : .dark(withTransparency: true, roundedCorners: true),
//                        animation: .fadeEffect()
//                    )
//                }
                .alert(isPresented: $isPresent) { () -> Alert in
                    Alert(title: Text("确认地址"), message: Text("\(confirmMsg)"), primaryButton: .default(Text("取消")), secondaryButton: .default(Text("确定")))
                }
            }
            
            Section(header: Text("点击复制收货信息")) {
                
                Button {
                    self.isPresent2 = true
                    // copy action
                    UIPasteboard.general.string = "\(people) \(phone) \(address)"
                } label: {
                    Text("一键复制")
                        .foregroundColor(.blue)
                }
                .disabled(invalidInput)
                .alert(isPresented: $isPresent2) { () -> Alert in
                    Alert(title: Text("复制成功"))
                }
            }
        }
        .navigationBarTitle("添加收货地址", displayMode: .automatic)
        .navigationBarItems(trailing: Button(action: {
            self.endEditing()
        }, label: {
            Text("完成")
        })
        )
        .navigationBarUIColor(Color.yellow)
        .onDisappear {
            // 退出该页面时保存数据
            encodeUserDefaults(en_people: people, en_phone: phone, en_address: address, en_tagIndex: tagIndex, en_type: type)
        }
        .onAppear {
            // 当该页面显示时才解码数据
            people = UserDefaults.standard.object(forKey: "name\(id)") as? String ?? ""
            phone = UserDefaults.standard.object(forKey: "phoneNumber\(id)") as? String ?? ""
            address = UserDefaults.standard.object(forKey: "address\(id)") as? String ?? ""
            tagIndex = UserDefaults.standard.integer(forKey: "tagIndex\(id)")
            type = UserDefaults.standard.object(forKey: "type\(id)") as? String ?? ""
        }
    }
}

extension ContentView {
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
    
    // 编码五个属性值--根据List页下标index的不同来区分各ContentView数据
    func encodeUserDefaults(en_people: String, en_phone: String, en_address: String, en_tagIndex: Int, en_type: String) {
        UserDefaults.standard.setValue(en_people, forKey: "name\(id)")
        UserDefaults.standard.setValue(en_phone, forKey: "phoneNumber\(id)")
        UserDefaults.standard.setValue(en_address, forKey: "address\(id)")
        UserDefaults.standard.setValue(en_tagIndex, forKey: "tagIndex\(id)")
        UserDefaults.standard.setValue(en_type, forKey: "type\(id)")
    }
}

extension View {
    // 给View扩展出navigationBarUIColor方法
    func navigationBarUIColor(_ backgroundColor: Color?) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: UIColor(backgroundColor!)))
    }
    // 文字渐变色--通过先把文字隐藏（self.hidden()），然后通过modifier传入渐变色覆盖在上层，再通过mask按照文字view裁剪
//    public func overlayMask<T: View>(_ overlay: T) -> some View {
//        self.hidden()
//            .overlay(overlay)
//            .mask(self)
//    }
}
