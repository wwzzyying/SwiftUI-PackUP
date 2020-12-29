//
//  VoiceView.swift
//  AddProductAddress
//
//  Created by SD.Man on 2020/10/29.
//

import Foundation
import SwiftUI
import AVFoundation

private let voiceWidth = UIScreen.main.bounds.width
private let voiceHeight = UIScreen.main.bounds.height / 7 - 20

/*
 AVAudioSession: An object that communicates to the system how you intend to use audio in your app.
 管理多个APP对音频硬件设备（麦克风，扬声器）的资源使用。
 */

class AudioRecorder: ObservableObject {
    
    // 判断是否在录音
    @Published var recording = false
    
    // 声明变量audioRecorder是AVAudioRecorder，且保证后续不存在nil的情况
    var audioRecorder: AVAudioRecorder!
    
    // 激活录音函数
    func startRecording() {
        
        //
        let recordingSession = AVAudioSession.sharedInstance()
        
        // 定义录音时的类型并激活它。如果失败，我们将输出相应的错误
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session")
        }
        
        // 定义文件路径
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // 文件以录制的日期和时间命名，采用.m4a格式
        let audioFilename = documentPath.appendingPathComponent("\(Date().toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss")).m4a")
        
        // 设置录音属性
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        // 尝试请求AVAudioRecorder对象和调用录音功能
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.record()
            recording = true // 状态改变，向观察者发出消息
        } catch {
            // 请求失败
            print("Could not start recording")
        }
    }
    
    // 停止录音函数
    func stopRecording() {
//        audioRecorder.stop()
        recording = false
    }
    
}

// 显示录音列表
struct RecordingsList: View {
    
    @ObservedObject var audioRecorder: AudioRecorder
    
    var body: some View {
        List {
            Text("Empty list")
        }
    }
}

// 主视图
struct VoiceView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    // 观察者，当观察到audioRecorder对象的属性发生变化时发送给该view以及拥有该观察者的view，及时刷新
    
    var body: some View {
        RecordingsList(audioRecorder: audioRecorder)
            .navigationBarTitle("录音处理器", displayMode: .large)
            .navigationBarHidden(false)
            .navigationBarUIColor(Color(red: 250 / 255, green: 128 / 255, blue: 114 / 255))
        
        // 底部
        ZStack(alignment: .center) {
            StartRecord(audioRecorder: audioRecorder)
        }
        .frame(width: voiceWidth, height: voiceHeight, alignment: .center)
        .background(
            Color(red: 0 / 255, green: 139 / 255, blue: 139 / 255)
                .cornerRadius(15)
                .edgesIgnoringSafeArea(.all)
        )
    }
}

// 底部视图
struct StartRecord: View {
    @ObservedObject var audioRecorder: AudioRecorder
//    @State var isStart = false
    
    var body: some View {
//        HStack {
//            Spacer()
//            Button {
//                // backward
//            } label: {
//                Image(systemName: "backward.fill")
//                    .resizable()
//                    .frame(width: voiceWidth / 7 - 20, height: voiceWidth / 7 - 20)
//                    .foregroundColor(.gray)
//            }
//            Spacer()
            ZStack {
                Image(systemName: "circle")
                    .resizable()
                    .frame(width: voiceWidth / 6 + 8, height: voiceWidth / 6 + 8)
                    .foregroundColor(.gray)
                    
                Image(systemName: "circle")
                    .resizable()
                    .frame(width: voiceWidth / 6 + 2, height: voiceWidth / 6 + 2)
                    .foregroundColor(Color(red: 245 / 255, green: 245 / 255, blue: 245 / 255))
                
                Button {
                    withAnimation(.easeInOut) {
//                        self.isStart.toggle()
                        if audioRecorder.recording == false {
                            self.audioRecorder.startRecording()
                        } else {
                            self.audioRecorder.stopRecording()
                        }
                    }
                } label: {
                    if !audioRecorder.recording {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .frame(width: voiceWidth / 6 - 10, height: voiceWidth / 6 - 10)
                            .foregroundColor(.red)
                    } else {
                        Image(systemName: "stop.fill")
                            .resizable()
                            .frame(width: voiceWidth / 6 - 40, height: voiceWidth / 6 - 40)
                            .foregroundColor(.red)
                    }
                }
            }
//            Spacer()
//            Button {
//                // forward
//            } label: {
//                Image(systemName: "forward.fill")
//                    .resizable()
//                    .frame(width: voiceWidth / 7 - 20, height: voiceWidth / 7 - 20)
//                    .foregroundColor(.gray)
//            }
//            Spacer()
//        }
    }
}

// 扩展toString方法，用于录音文件名中插值字符串转换
extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

}

struct VoiceView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceView(audioRecorder: AudioRecorder())
    }
}
