//
//  Message.swift
//  BitDate
//
//  Created by David Pirih on 21.04.15.
//  Copyright (c) 2015 Piri-Piri. All rights reserved.
//

import Foundation

struct Message {
    let message: String
    let senderId: String
    let date: NSDate
}

class MessageListener {
    var currentHandle: UInt?
    
    init(matchId: String, startDate: NSDate, callback: (Message) -> ()) {
        let handle = ref.childByAppendingPath(matchId)
            .queryOrderedByKey()
            .queryStartingAtValue(dateFormatter().stringFromDate(startDate))
            .observeEventType(FEventType.ChildAdded, withBlock: {
                snapshot in
                let message = snapshotToMessage(snapshot)
                callback(message)
            })
        self.currentHandle = handle
    }
    
    func stop() {
        if let handle = currentHandle {
            ref.removeObserverWithHandle(handle)
            currentHandle = nil
        }
    }
}

private let ref = Firebase(url: "https://bitdate-piri-piri.firebaseio.com/messages")
private let dateFormat = "yyyyMMddHHmmss"

private func dateFormatter() -> NSDateFormatter {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = dateFormat
    return dateFormatter
}

func saveMessage(matchID: String, message: Message) {
    ref.childByAppendingPath(matchID).updateChildValues([dateFormatter().stringFromDate(message.date) : ["message" : message.message, "sender" : message.senderId]])
}

private func snapshotToMessage(snapshot: FDataSnapshot) -> Message {
    let date = dateFormatter().dateFromString(snapshot.key)
    let sender = snapshot.value["sender"] as? String
    let text = snapshot.value["message"] as? String
    
    return Message(message: text!, senderId: sender!, date: date!)
}

func fetchMessages(matchId: String, callback: ([Message]) -> ()) {
    ref.childByAppendingPath(matchId)
        .queryLimitedToFirst(25)
        .observeSingleEventOfType(FEventType.Value, withBlock: {
        snapshot in
            var messages: [Message] = []
            
            let enumerator = snapshot.children
            while let data = enumerator.nextObject() as? FDataSnapshot {
                messages.append(snapshotToMessage(data))
            }
            callback(messages)
    })
}