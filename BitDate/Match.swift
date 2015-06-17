//
//  Match.swift
//  BitDate
//
//  Created by David Pirih on 21.04.15.
//  Copyright (c) 2015 Piri-Piri. All rights reserved.
//

import Foundation

struct Match {
    let id: String
    let user: User
}

func fetchMatches(callBack: ([Match]) -> ()) {
    PFQuery(className: "Action")
    .whereKey("byUser", equalTo: PFUser.currentUser()!.objectId!)
    .whereKey("type", equalTo: "matched")
        .findObjectsInBackgroundWithBlock({
        objects, error in
            if let matches = objects as? [PFObject] {
                
                let matchedUsers = matches.map({
                    (object)->(matchID: String, userID: String)
                    in
                    (object.objectForKey("matchId") as! String, object.objectForKey("toUser") as! String)
                })
                let userIDs = matchedUsers.map({$0.userID})
                
                PFUser.query()?
                    .whereKey("objectId", containedIn: userIDs)
                    .orderByDescending("createdAt")
                    .findObjectsInBackgroundWithBlock({
                        objects, error in
                        if let users = objects as? [PFUser] {
                            var m: [Match] = []
                            for (index, user) in users.enumerate() {
                                m.append(Match(id: matchedUsers[index].matchID, user: pfUserToUser(user)))
                            }
                            callBack(m)
                        }
                    })
            }
        })
}