//
//  VoiceView.swift
//  AddProductAddress
//
//  Created by SD.Man on 2020/10/29.
//

import SwiftUI
import AVKit

private let voiceWidth = UIScreen.main.bounds.width
private let voiceHeight = UIScreen.main.bounds.height / 6

struct VoiceView: View {
        
    var body: some View {
        Text("Voice")
            .navigationBarTitle("录音处理器", displayMode: .large)
            .navigationBarHidden(false)
            .navigationBarUIColor(Color(red: 250 / 255, green: 128 / 255, blue: 114 / 255))
        
        ZStack(alignment: .center) {
            StartRecord()
        }
        .frame(width: voiceWidth, height: voiceHeight, alignment: .center)
        .background(
            Color(red: 0 / 255, green: 139 / 255, blue: 139 / 255)
                .cornerRadius(15)
                .edgesIgnoringSafeArea(.all)
        )
    }
}

struct StartRecord: View {
    @State var isStart = false
    var body: some View {
        HStack {
            Spacer()
            Button {
                // backward
            } label: {
                Image(systemName: "backward.fill")
                    .resizable()
                    .frame(width: voiceWidth / 7 - 20, height: voiceWidth / 7 - 20)
                    .foregroundColor(.gray)
            }
            Spacer()
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
                        self.isStart.toggle()
                    }
                } label: {
                    if !isStart {
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
            Spacer()
            Button {
                // forward
            } label: {
                Image(systemName: "forward.fill")
                    .resizable()
                    .frame(width: voiceWidth / 7 - 20, height: voiceWidth / 7 - 20)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }
}

struct VoiceView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceView()
    }
}
