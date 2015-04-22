//
//  ChatViewController.swift
//  BitDate
//
//  Created by David Pirih on 21.04.15.
//  Copyright (c) 2015 Piri-Piri. All rights reserved.
//

import Foundation


class ChatViewController: JSQMessagesViewController {
    
    var messages: [JSQMessage] = []
    
    var matchId: String?
    
    var messageListener: MessageListener?
    
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        collectionView.collectionViewLayout.springinessEnabled = true
        
        if let id = matchId {
            fetchMessages(id, {
                messages in
                for m in messages {
                    self.messages.append(JSQMessage(senderId: m.senderId, senderDisplayName: m.senderId, date: m.date, text: m.message))
                }
                self.finishReceivingMessage()
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let id = matchId {
            messageListener = MessageListener(matchId: id, startDate: NSDate(), callback: {
                message in
                self.messages.append(JSQMessage(senderId: message.senderId, senderDisplayName: message.senderId, date: message.date, text: message.message))
                self.finishReceivingMessage()
            })
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
       
        messageListener?.stop()
    }
    
    override var senderId: String! {
        get {
            return currentUser()!.id
        }
        set {
            super.senderId = newValue
        }
    }
    
    override var senderDisplayName: String! {
        get {
            return currentUser()!.id
        }
        set {
            super.senderDisplayName = newValue
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.row]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        var data = self.messages[indexPath.row]
        if data.senderId == PFUser.currentUser()!.objectId {
            return outgoingBubble
        }
        else {
            return incomingBubble
        }
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        let m = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages.append(m)

        
        if let id = matchId {
            saveMessage(id, Message(message: text, senderId: senderId, date: date))
        }
        
        finishSendingMessage()
    }
    
}