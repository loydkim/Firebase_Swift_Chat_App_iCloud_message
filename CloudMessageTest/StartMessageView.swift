//
//  StartMessageView.swift
//  CloudMessageTest
//
//  Created by YOUNGSIC KIM on 2020-01-12.
//  Copyright © 2020 YOUNGSIC KIM. All rights reserved.
//

import SwiftUI

let messageSimulatorSender = "Simulator"
let messageDeviceSender = "Device"

struct StartMessageView: View {
    var body: some View {
        NavigationView{
            VStack {
                Text("Please select who are you").font(.title).padding(20)

                NavigationLink(destination: ContentView(sender: messageSimulatorSender)) {
                    Text("I am a simulator").font(.title).padding(20)
                }

                NavigationLink(destination: ContentView(sender: messageDeviceSender)) {
                    Text("I am a device").font(.title).padding(20)
                }
            }
            .navigationBarHidden(true)
            .navigationBarTitle("Start",displayMode: .inline)
        }
    }
}

struct StartMessageView_Previews: PreviewProvider {
    static var previews: some View {
        StartMessageView()
    }
}
