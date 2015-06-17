//
//  User.swift
//  BitDate
//
//  Created by David Pirih on 07.04.15.
//  Copyright (c) 2015 Piri-Piri. All rights reserved.
//

import Foundation

struct User {
    let id: String
    let name: String
    private let pfUser: PFUser
    
    /* get picture data asyncronously by a nested function */
    func getPhoto(callback: (UIImage) -> ()) {
        let imageFile = pfUser.objectForKey("picture") as! PFFile
        imageFile.getDataInBackgroundWithBlock({
        data, error in
            if error != nil {
                print(error)
            }
            if let data = data {
                callback(UIImage(data: data)!)
            }
        })
    }
}

func pfUserToUser(user: PFUser) -> User {
    return User(id: user.objectId!, name: user.objectForKey("firstName") as! String, pfUser: user)
}

func currentUser() -> User? {
    if let user = PFUser.currentUser() {
        return pfUserToUser(user)
    }
    return nil
}

func fetchUnviewedUsers(callback: ([User]) -> ()) {
    PFQuery(className: "Action")
        .whereKey("byUser", equalTo: PFUser.currentUser()!.objectId!)
        .findObjectsInBackgroundWithBlock {
        objects, error in
            if objects != nil {
                let seenIDS = (objects!).map({$0.objectForKey("toUser")!})
                PFUser.query()!
                    .whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
                    .whereKey("objectId", notContainedIn: seenIDS)
                    .findObjectsInBackgroundWithBlock( {
                        objects, error in
                        if let pfUsers = objects as? [PFUser] {
                            /* map is creating an array of Users (Class User) */
                            let users = pfUsers.map({pfUserToUser($0)})
                            callback(users)
                        }
                    }
                )
            }
        }
}

func saveLike(user: User) {
    PFQuery(className: "Action")
        .whereKey("byUser", equalTo: user.id)
        .whereKey("toUser", equalTo: PFUser.currentUser()!.objectId!)
        .whereKey("type", equalTo: "liked")
        .findObjectsInBackgroundWithBlock( {
            objects, error in
            
            // create a unique chatroom (matchId)
            let matchId = PFUser.currentUser()!.objectId! + "-" + user.id
            
            var matched = false
            if let objects = objects  {
                matched = true
                print(objects[0], appendNewline: true)
                print(objects.count, appendNewline: true)
                objects[0].setObject("matched", forKey: "type")
                objects[0].setObject(matchId, forKey: "matchId")
                objects[0].saveInBackgroundWithBlock(nil)
            }
            
            let match = PFObject(className: "Action")
            match.setObject(PFUser.currentUser()!.objectId!, forKey: "byUser")
            match.setObject(user.id, forKey: "toUser")
            
            if matched {
                match.setObject("matched", forKey: "type")
                match.setObject(matchId, forKey: "matchId")
            }
            else {
                match.setObject("liked", forKey: "type")
            }
            match.saveInBackgroundWithBlock(nil)
        })
}

func saveSkip(user: User) {
        let skip = PFObject(className: "Action")
        
        skip.setObject(PFUser.currentUser()!.objectId!, forKey: "byUser")
        skip.setObject(user.id, forKey: "toUser")
        skip.setObject("skipped", forKey: "type")
        skip.saveInBackgroundWithBlock(nil)
}