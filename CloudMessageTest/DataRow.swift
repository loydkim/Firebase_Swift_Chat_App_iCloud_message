//
//  DataRow.swift
//  FireBaseProject
//
//  Created by YOUNGSIC KIM on 2019-12-31.
//  Copyright © 2019 YOUNGSIC KIM. All rights reserved.
//

import SwiftUI

struct DataRow: View {
    var data: ThreadDataType
    var senderName: String
    var messageBackgroundColor: Color {
        return data.userID == senderName ? Color.orange : Color.green
    }
    var isOtherUserMessage:Bool {
        return data.userID != senderName ? true : false
    }
    var rowTrailing: HorizontalAlignment? {
        return data.userID == senderName ? .trailing: .leading
    }
    var otherUserName: String? {
        return data.userID != messageSimulatorSender ? messageDeviceSender: messageSimulatorSender
    }
    
    var body: some View {
        VStack(alignment: self.rowTrailing!) {
            if isOtherUserMessage {
                Text(otherUserName!).bold().font(.subheadline).padding(4)
            }
            HStack {
                if !isOtherUserMessage && !data.isRead{
                    Text("1").foregroundColor(Color.yellow)
                }
                
                Text(data.content)
                    .padding(8)
                    .background(messageBackgroundColor)
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
                    .font(Font.body)
            }
            Text(data.date)
                .font(.subheadline)
                .foregroundColor(Color.gray)
        }
    }
}

struct DataRow_Previews: PreviewProvider {
    static var previews: some View {
        DataRow(data: threadDataTest[0],senderName:"senderName").previewLayout(PreviewLayout.fixed(width: 500, height: 140))
    }
}
