//
//  EasterEggView.swift
//  PackUP
//
//  Created by SD.Man on 2020/11/28.
//

import SwiftUI
import CoreML
import Vision
/*
 构思1：利用Create ML做一个简单的动物模型匹配度界面--模型提前训练好预置入APP
 */

private let width = UIScreen.main.bounds.width

struct EasterEggView: View {
    
    @State private var isShowPhotoLibrary = false
    @State private var isShowCamera = false
    @State private var image = UIImage() //要接受picker选中的图片
    @State private var label = [String]()
    @State private var isShowAlert = false
    @State private var libraryOrCamera = false // true-PhotoLibrary, false-Camera
    
    var body: some View {
        VStack {
            Image(uiImage: self.image)
                .resizable()
                .scaledToFit()
                .frame(minWidth: 0, maxWidth: .infinity)
                .edgesIgnoringSafeArea(.all)
            HStack {
                // 相册按钮
                Button(action: {
                    self.isShowPhotoLibrary = true
                    self.libraryOrCamera = true
                }) {
                    HStack {
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                        
                        Text("相册")
                            .font(.headline)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
                // 拍照按钮
                Button(action: {
                    self.isShowCamera = true
                    self.libraryOrCamera = false
                }) {
                    HStack {
                        Image(systemName: "camera")
                            .font(.system(size: 20))
                        
                        Text("拍照")
                            .font(.headline)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
            }
            
            Text("模型准确度仅供娱乐")
                .foregroundColor(.gray)
                .font(.subheadline)
        }
        .navigationBarUIColor(.blue)
        .navigationBarTitle(Text("物体识别器"))
        .alert(isPresented: $isShowAlert, content: {
            if label.count == 1 {
                return Alert(title: Text("\(label[0])"))
            } else {
                return Alert(title: Text("\(label[1])\n\(label[2])\n\(label[3])\n\(label[4])"))
            }
        })
        .sheet(isPresented: libraryOrCamera ? $isShowPhotoLibrary : $isShowCamera) {
            // dismissed to do
            label = loadModel().imageClassify(image: CIImage(image: image)!)
            self.isShowAlert = true
            getFeatures(label: label)
        } content: {
            if libraryOrCamera {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $image)
            } else {
                ImagePicker(sourceType: .camera, selectedImage: $image)
            }
        }
    }
    
    // 输出前三个匹配值
    func getFeatures(label: [String]) {
        if label.count == 1 {
            print("return \(label)")
        } else {
            for i in 1...4 {
                print(label[i])
            }
        }
    }
}

// 选中照片返回后才调用该类方法
class loadModel {
    var answerLabel = ["detecting"]
    
    let semaphore = DispatchSemaphore(value: 0)
    let group = DispatchGroup()
    let myQueue = DispatchQueue(label: "tech.sdman")
    
    func imageClassify(image: CIImage) -> [String] {

        // 加载ML模型
        let model: VNCoreMLModel = {
            do {
                let config = MLModelConfiguration()
                return try VNCoreMLModel(for: MobileNetV2Int8LUT(configuration: config).model)
            } catch {
                print(error)
                fatalError("Couldn't create CatTypeClassify")
            }
        }()
        
        // 创建带有处理程序的视觉请求
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            let results = request.results as? [VNClassificationObservation]
            
            var outputText = ["detecting"]
            
            for res in results! {
                outputText.append("\(Int(res.confidence * 100))% it's \(res.identifier)")
            }
            self?.answerLabel = outputText
            
            // 如果在主队列中将主队列作为同步调度，则将产生异常，因为将产生死锁
//            DispatchQueue.main.async { [weak self] in
//                self?.answerLabel = outputText
//            }
        }
        
        // 运行CoreML3 CatTypeClassify分类器
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
            print(self.answerLabel)
        } catch {
            print(error)
        }
        // 在全局调度队列上运行CoreML3 CatTypeClassify分类器
//        DispatchQueue.global(qos: .userInteractive).async {
//            do {
//                try handler.perform([request])
//                print(self.answerLabel)
//            } catch {
//                print(error)
//            }
//        }
        
//        print("异步队列未结束")
//        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
//        print("获得信号量，异步队列结束")
        return answerLabel
    }
}

struct ImagePicker: UIViewControllerRepresentable {
 
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage
    @Environment(\.presentationMode) private var presentationMode
    
    // The system calls this method only once, when it creates your view controller for the first time
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
 
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    // Use this method to update the configuration of your view controller to match the new state information provided in the context parameter
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
 
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
     
        var parent: ImagePicker
     
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
     
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
     
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
     
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct EasterEggView_Previews: PreviewProvider {
    static var previews: some View {
        EasterEggView()
    }
}
