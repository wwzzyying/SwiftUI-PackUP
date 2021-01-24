//
//  VoiceView.swift
//  AddProductAddress
//
//  Created by SD.Man on 2020/10/29.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

private let voiceWidth = UIScreen.main.bounds.width
private let voiceHeight = UIScreen.main.bounds.height / 7 - 20

/*
 AVAudioSession: An object that communicates to the system how you intend to use audio in your app.
 管理多个APP对音频硬件设备（麦克风，扬声器）的资源使用。
 */

//MARK: - Process

// 负责录音
class AudioRecorder: NSObject, ObservableObject {
    
    // 初始化时获取数据
    override init() {
        super.init()
        fetchRecordings()
    }
    
    // 告知监控者是否在录音
    @Published var recording = false
    
    // 录音数据数组,也需要监控变化
    @Published var recordings = [Recording]()
    
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
        audioRecorder.stop()
        recording = false
        fetchRecordings()
    }
    
    // 刷新现存录音数据
    func fetchRecordings() {
        // 删除数据，避免重复显示
        recordings.removeAll()
        
        // 获取文件夹内容
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryContents = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
        for audio in directoryContents {
            let recording = Recording(fileURL: audio, createdAt: getCreationDate(for: audio))
            recordings.append(recording)
        }
        
        // 根据创建时间排序
        recordings.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending})
    }
    
    // 删除录音
    func deleteRecording(urlsToDelete: [URL]) {
        
        // 逐个url删除
        for url in urlsToDelete {
            print(url)
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print("File coule not be deleted!")
            }
        }
        
        // 刷新
        fetchRecordings()
    }
    
    // 获取录音创建日期
    func getCreationDate(for file: URL) -> Date {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
            let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
            return creationDate
        } else {
            return Date()
        }
    }
    
}

// 负责播放录音
class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    // 告知监控者是否在播放录音
    @Published var isPlaying = false
    
    // 用于保存AVAudioPlayer实例
    var audioPlayer: AVAudioPlayer!
    
    // 播放录音
    func startPlayback(audio: URL) {
        
        let playbackSession = AVAudioSession.sharedInstance()
        
        // 重定向录音播放位置
        do {
            try playbackSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing over the device's speakers failed")
        }
        
        //
        do {
            print(audio)
            audioPlayer = try AVAudioPlayer(contentsOf: audio)
            // 在音频完成播放后，AudioPlayer作为它自己的委托将调用audioDidFinishPlaying函数
            audioPlayer.delegate = self
            audioPlayer.play()
            isPlaying = true
        } catch {
            print("Playback failed.")
        }
    }
    
    // 停止播放
    func stopPlayback() {
        audioPlayer.stop()
        isPlaying = false
    }
    
    // 实现AVAudioPlayerDelegate协议中的方法，当flag为true时表示FinishPlaying，此时设isPlaying = false
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            isPlaying = false
        }
    }
}


//MARK: - View

// 录音项
struct RecordingRow: View {
    
    var audioURL: URL
    
    @ObservedObject var audioPlayer = AudioPlayer()
    
    var body: some View {
        HStack {
            Text("\(audioURL.lastPathComponent)")
            Spacer()
            if audioPlayer.isPlaying == false {
                Button(action: {
                    self.audioPlayer.startPlayback(audio: self.audioURL)
                }) {
                    Image(systemName: "play.circle")
                        .imageScale(.large)
                }
            } else {
                Button(action: {
                    self.audioPlayer.stopPlayback()
                }) {
                    Image(systemName: "stop.fill")
                        .imageScale(.large)
                }
            }
        }
    }
}

// 显示录音列表
struct RecordingsList: View {
    
    @ObservedObject var audioRecorder: AudioRecorder
    
    var body: some View {
        List {
            ForEach(audioRecorder.recordings, id: \.createdAt) { recording in
                RecordingRow(audioURL: recording.fileURL)
            }
            .onDelete(perform: delete)
        }
    }
    
    //
    func delete(at offsets: IndexSet) {
        
        // 保存即将删除的录音的url
        var urlsToDelete = [URL]()
        
        // 获取全部url
        for index in offsets {
            urlsToDelete.append(audioRecorder.recordings[index].fileURL)
        }
        
        //
        audioRecorder.deleteRecording(urlsToDelete: urlsToDelete)
    }
}

// 主视图
struct VoiceView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    // 观察者，当观察到audioRecorder对象的属性发生变化时发送给该view以及拥有该观察者的view，及时刷新
    
    var body: some View {
        ZStack {
            RecordingsList(audioRecorder: audioRecorder)
                .opacity(audioRecorder.recording ? 0.4 : 1.0)
            if audioRecorder.recording == true {
                RecordingView()
            }
        }
        .navigationBarTitle("录音处理器", displayMode: .large)
        .navigationBarItems(trailing: EditButton())
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

// 正在录音视图
struct RecordingView: View {
    
    @State private var fadeInOut = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .circular)
                .fill(Color.gray)
                .frame(width: voiceWidth / 3, height: voiceWidth / 7, alignment: .center)
            
            Text("录音中")
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                self.fadeInOut.toggle()
            }
        }
        .opacity(fadeInOut ? 0 : 1)
    }
}

// 底部视图
struct StartRecord: View {
    
    @ObservedObject var audioRecorder: AudioRecorder
    
    var body: some View {
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
//        VoiceView(audioRecorder: AudioRecorder())
        RecordingView()
    }
}
