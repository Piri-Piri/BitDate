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
                let matchedUser = matches.map({
                    (object)->(matchID: String, userID: String)
                    in
                    (object.objectId! as String, object.objectForKey("toUser") as! String)
                })
                let userIDs = matchedUser.map({$0.userID})
                PFUser.query()?
                    .whereKey("objectId", containedIn: userIDs)
                    .orderByAscending("objectId")
                    .findObjectsInBackgroundWithBlock({
                        objects, error in
                        if let users = objects as? [PFUser] {
                            //var users = reverse(users)
                            var m: [Match] = []
                            for (index, user) in enumerate(users) {
                                m.append(Match(id: matchedUser[index].matchID, user: pfUserToUser(user)))
                            }
                            callBack(m)
                        }
                    })
            }
        })
}