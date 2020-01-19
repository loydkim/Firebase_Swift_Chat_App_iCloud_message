//
//  ThreadData.swift
//  FireBaseProject
//
//  Created by YOUNGSIC KIM on 2019-12-29.
//  Copyright © 2019 YOUNGSIC KIM. All rights reserved.
//

import Foundation
import SwiftUI

struct ThreadDataType: Identifiable {
    var id: String
    var userID: String
    var content: String
    var date:String
    var isRead:Bool = false
}

func makeToday() -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm a"
    return formatter.string(from: date)
}

func rowTrailing(userID:String, senderName:String) -> HorizontalAlignment {
    if userID == senderName {
        return HorizontalAlignment.trailing
    }else {
        return HorizontalAlignment.leading
    }
}

let threadDataTest = [ThreadDataType(id: "id1",userID:messageSimulatorSender, content: "content1", date:makeToday())]
