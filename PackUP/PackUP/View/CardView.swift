//
//  CardView.swift
//  PackUP
//
//  Created by SD.Man on 2020/12/27.
//

import SwiftUI

private let cardWidth = UIScreen.main.bounds.width

struct CardView: View {
    var icon: String
    var text: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .circular)
//                .fill(Color(red: 255 / 255, green: 239 / 255, blue: 213 / 255))
//                .fill(Color(red: 189 / 255, green: 183 / 255, blue: 107 / 255))
//                .fill(Color(red: 255 / 255, green: 192 / 255, blue: 203 / 255))
                .fill(Color(red: 220 / 255, green: 220 / 255, blue: 220 / 255))
                .opacity(1)
                .frame(width: cardWidth / 3 + 20, height: cardWidth / 3 + 20)
            
            VStack {
                Image(icon)
                    .resizable()
                    .frame(width: 80, height: 80, alignment: .center)
                    .opacity(0.8)
                    .padding()
                
                Text(text)
                    .bold()
                    .foregroundColor(.black)
            }
        }.shadow(radius: 10)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(icon: "录音", text: "Voice")
    }
}
