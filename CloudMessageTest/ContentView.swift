//
//  ContentView.swift
//  CloudMessageTest
//
//  Created by YOUNGSIC KIM on 2020-01-01.
//  Copyright © 2020 YOUNGSIC KIM. All rights reserved.
//

import SwiftUI
import Firebase

// Please change it your physical phone device FCM Token
// To get it, touch the handleLogTokenTouch button and see log
let ReceiverFCMToken = "Your_Physical_Device_Token"

// Please change it your Firebase Legacy server key
// Firebase -> Project settings -> Cloud messaging -> Legacy server key
let legacyServerKey = "Your_Firebase_Legacy_server_key"

struct ContentView: View {
    var sender:String
    
    init(sender:String) {
        self.sender = sender
        self.datas.sender = sender
        UITableView.appearance().separatorColor = .clear
    }
    
    @State private var fcmTokenMessage = "fcmTokenMessage"
    @State private var instanceIDTokenMessage = "instanceIDTokenMessage"
    
    @State private var notificationContent: String = ""
    
    @ObservedObject private var datas = firebaseData
    @ObservedObject private var keyboard = KeyboardResponder()
    
    var body: some View {
        NavigationView{
            VStack {
                List {
                    ForEach(self.datas.data){ data in
                        HStack {
                            if data.userID == self.sender { Spacer() }
                            DataRow(data: data,senderName:self.sender)
                            if data.userID != self.sender { Spacer() }
                        }
                    }
                }
                
                HStack {
                    TextField("Add text please", text: $notificationContent).textFieldStyle(RoundedBorderTextFieldStyle()).padding(10)

                    Button(action: { self.datas.sendMessageTouser(datas: self.datas,to: ReceiverFCMToken, title: self.sender, body: self.notificationContent)
                        self.notificationContent = ""
                    }) {
                        Text("Send").font(.body)
                    }.padding(10)
                }
            }.padding()
            .padding(.bottom, keyboard.currentHeight)
            .edgesIgnoringSafeArea(.bottom)
            .animation(.easeOut(duration: 0.16))
            }.onAppear(perform: checkRead)
                .onReceive(datas.didChange) { data in
                self.checkRead()
            }
    }
    
    func checkRead() {
        print("check the read")
        UIApplication.shared.applicationIconBadgeNumber = 0
        for data in datas.data {
            if self.sender != data.userID && data.isRead == false {
                self.datas.updateData(id: data.id, isRead: true)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(sender: "defualt")
    }
}

// Keyboard Responder
final class KeyboardResponder: ObservableObject {
    private var notificationCenter: NotificationCenter
    @Published private(set) var currentHeight: CGFloat = 0

    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = keyboardSize.height
        }
    }

    @objc func keyBoardWillHide(notification: Notification) {
        currentHeight = 0
    }
}
