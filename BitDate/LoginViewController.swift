//
//  LoginViewController.swift
//  BitDate
//
//  Created by David Pirih on 07.04.15.
//  Copyright (c) 2015 Piri-Piri. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressedFBLogin(sender: UIButton) {
        PFFacebookUtils.logInWithPermissions(["public_profile", "user_about_me", "user_birthday"], block: {
            user, error in
            if user == nil {
                print("Error. The user cancelled the Facebook login.")
                // Add UIAlertController to inform user before pushing back to app store
                return
            }
            else if user!.isNew {
                print("User signed up and logged in through Facebook!")
                
                FBRequestConnection.startWithGraphPath("/me?fields=picture,first_name,birthday,gender", completionHandler: {
                connection, result, error in
                    let r = result as! NSDictionary
                    
                    user!["firstName"] = r["first_name"]
                    user!["gender"] = r["gender"]
                    
                    let dateformatter = NSDateFormatter()
                    dateformatter.dateFormat = "dd.MM.yyyy"
                    user!["birthday"] = dateformatter.dateFromString(r["birthday"] as! String)
                    
                
                    let pictureURL = ((r["picture"] as! NSDictionary)["data"] as! NSDictionary)["url"] as! String
                    let url = NSURL(string: pictureURL)
                    let request = NSURLRequest(URL: url!)
                    
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
                        response, data, error in
                        
                        let imageFile = PFFile(name: "avatar.jpg", data: data!)
                        user!["picture"] = imageFile
                        user!.saveInBackgroundWithBlock({
                            success, error in
                            print(success)
                            print(error)
                        })
                        
                    })
                }
                )
                
            }
            else {
                print("User logged in through Facebook!")
            }
            
            /* 
                May a bug or an missing step in eliots videos?!

                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CardsNavController") as? UIViewController
                self.presentViewController(vc!, animated: true, completion: nil)
            
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PageController") as? UIViewController
                self.presentViewController(vc!, animated: true, completion: nil)
            */
            
              self.presentViewController(pageController, animated: true, completion: nil)
        })
    }
}
