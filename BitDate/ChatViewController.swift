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
    
    var match: Match?
    
    var messageListener: MessageListener?
    
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    
    var outgoingAvatar: UIImage!
    var incomingAvatar: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        collectionView.collectionViewLayout.springinessEnabled = true
        
        if let id = match?.id {
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
        if let id = match?.id {
            messageListener = MessageListener(matchId: id, startDate: NSDate(), callback: {
                message in
                JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
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
    
    func updateAvatarImageForItemAtIndexPatch(indexPath: NSIndexPath, avatarImage: UIImage) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? JSQMessagesCollectionViewCell {
            cell.avatarImageView.image = JSQMessagesAvatarImageFactory.circularAvatarImage(avatarImage, withDiameter: 60)
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
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        var avatarImage = JSQMessagesAvatarImage.avatarWithImage(JSQMessagesAvatarImageFactory.circularAvatarImage(UIImage(named: "profile-header"), withDiameter: 60))
        if self.messages[indexPath.row].senderId == self.senderId {
            if let avatar = self.outgoingAvatar {
                avatarImage = JSQMessagesAvatarImage.avatarWithImage(JSQMessagesAvatarImageFactory.circularAvatarImage(avatar, withDiameter: 60))
            }
            else {
                currentUser()?.getPhoto( {
                    image in
                    self.outgoingAvatar = image
                    self.updateAvatarImageForItemAtIndexPatch(indexPath, avatarImage: image)
                })
            }
        }
        else {
            if let avatar = self.incomingAvatar {
                avatarImage = JSQMessagesAvatarImage.avatarWithImage(JSQMessagesAvatarImageFactory.circularAvatarImage(avatar, withDiameter: 60))
            }
            else {
                match?.user.getPhoto( {
                    image in
                    self.incomingAvatar = image
                    self.updateAvatarImageForItemAtIndexPatch(indexPath, avatarImage: image)
                })
            }
        }
        return avatarImage
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        /*
            message add remove after implemeting the realtime listener to avoid dopple message posts

            let m = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
            self.messages.append(m)
        */
        
        if let id = match?.id {
            saveMessage(id, Message(message: text, senderId: senderId, date: date))
        }
        
        finishSendingMessage()
    }
    
}