//
//  Data.swift
//  FireBaseProject
//
//  Created by YOUNGSIC KIM on 2019-12-29.
//  Copyright © 2019 YOUNGSIC KIM. All rights reserved.
//

import Firebase
import FirebaseFirestore
import Combine
let dbCollection = Firestore.firestore().collection("cloudmessageDB")
let firebaseData = FirebaseData()

class FirebaseData: ObservableObject {
    var sender:String?
    @Published var didChange = PassthroughSubject<[ThreadDataType], Never>()
    @Published var data = [ThreadDataType](){
        didSet{
            didChange.send(data)
        }
    }
    
    init() {
        readData()
    }
    
    // Reference link: https://firebase.google.com/docs/firestore/manage-data/add-data
    func createData(sender: String,msg1:String) {
        // To create or overwrite a single document
        dbCollection.document().setData(["id" : dbCollection.document().documentID,"content":msg1,"userID":sender, "date":makeToday(),"isRead":false]) { (err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }else {
                print("create data success")
            }
        }
    }
    
    // Reference link : https://firebase.google.com/docs/firestore/query-data/listen
    func readData() {
        dbCollection.addSnapshotListener { (documentSnapshot, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }else {
                print("read data success")
            }
            
            documentSnapshot!.documentChanges.forEach { diff in
                // Real time create from server
                if (diff.type == .added) {
                    let msgData = ThreadDataType(id: diff.document.documentID, userID: diff.document.get("userID") as! String, content: diff.document.get("content") as! String, date: diff.document.get("date") as! String, isRead: diff.document.get("isRead") as! Bool)
                    self.data.append(msgData)
                }
                
                // Real time modify from server
                if (diff.type == .modified) {
                    self.data = self.data.map { (eachData) -> ThreadDataType in
                        var data = eachData
                        if data.id == diff.document.documentID {
                            data.content = diff.document.get("content") as! String
                            data.userID = diff.document.get("userID") as! String
                            data.date = diff.document.get("date") as! String
                            data.isRead = diff.document.get("isRead") as! Bool
                            
                            return data
                        }else {
                            return eachData
                        }
                    }
                }
                
                if (diff.type == .removed) {
                    var removeRowIndex = 0
                    for index in self.data.indices {
                        if self.data[index].id == diff.document.documentID {
                            removeRowIndex = index
                        }
                    }
                    self.data.remove(at: removeRowIndex)
                }
            }
        }
    }
    
    // Reference link: https://firebase.google.com/docs/firestore/manage-data/add-data
    func updateData(id: String, isRead: Bool) {
        dbCollection.document(id).updateData(["isRead":isRead]) { (err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }else {
                print("update data success")
            }
        }
    }
    
    func sendMessageTouser(datas:FirebaseData, to token: String, title: String, body: String) {
        print("sendMessageTouser()")
        var isNotRead: Int = 0
        for data in datas.data {
            if !data.isRead && title == data.userID { isNotRead += 1 }
        }
        isNotRead += 1
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "priority": "high",
                                           "notification" : ["title" : title, "body" : body,"badge" : isNotRead],
                                           "data" : ["user" : "test_id"]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(legacyServerKey)", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                        firebaseData.createData(sender: title,msg1: body)
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
