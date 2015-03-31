//
//  CardsViewController.swift
//  BitDate
//
//  Created by David Pirih on 31.03.15.
//  Copyright (c) 2015 Piri-Piri. All rights reserved.
//

import UIKit

class CardsViewController: UIViewController, SwipeViewDelegate {

    /* The CardsViewController should managed both views (!!! coding modular !!!) */
    struct Card {
        let cardView: CardView
        let swipView: SwipeView
    }
    
    let frontCardTopMargin: CGFloat = 0
    let backCardTopMargin: CGFloat = 10
    
    @IBOutlet weak var cardStackView: UIView!
    
    var backCard: Card?
    var frontCard: Card?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cardStackView.backgroundColor = UIColor.clearColor()
        
        backCard = createCard(backCardTopMargin)
        cardStackView.addSubview(backCard!.swipView)
        
        frontCard = createCard(frontCardTopMargin)
        cardStackView.addSubview(frontCard!.swipView)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func createCardFrame(topMargin: CGFloat) -> CGRect {
        return CGRect(x: 0, y: topMargin, width: cardStackView.frame.width, height: cardStackView.frame.height)
    }
    
    
    private func createCard(topMargin: CGFloat) -> Card {
        let cardView = CardView()
        let swipeView = SwipeView(frame: createCardFrame(topMargin))
        swipeView.delegate = self
        swipeView.innerView = cardView
        
        return Card(cardView: cardView, swipView: swipeView)
    }
    
    
    // MARK: SwipeViewDelegate
    
    func swipedLeft() {
        //println("Left")
        if let frontCard = frontCard {
            frontCard.swipView.removeFromSuperview()
        }
    }
    
    func swipedRight() {
        //println("Right")
        if let frontCard = frontCard {
            frontCard.swipView.removeFromSuperview()
        }
    }
}
