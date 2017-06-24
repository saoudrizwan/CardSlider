//
//  ViewController.swift
//  CardSlider
//
//  Created by Saoud Rizwan on 2/26/17.
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    /// Data structure for custom cards - in this example, we're using an array of ImageCards
    var cards = [ImageCard]()
    /// The emojis on the sides are simply part of a view that sits ontop of everything else,
    /// but this overlay view is non-interactive so any touch events are passed on to the next receivers.
    var emojiOptionsOverlay: EmojiOptionsOverlay!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 28/255, green: 39/255, blue: 101/255, alpha: 1.0)
        dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        setUpDummyUI()
        
        // 1. create a deck of cards
        // 20 cards for demonstrational purposes - once the cards run out, just re-run the project to start over
        // of course, you could always add new cards to self.cards and call layoutCards() again
        for _ in 1...20 {
            let card = ImageCard(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 60, height: self.view.frame.height * 0.6))
            cards.append(card)
        }
        
        // 2. layout the first 4 cards for the user
        layoutCards()
        
        // 3. set up the (non-interactive) emoji options overlay
        emojiOptionsOverlay = EmojiOptionsOverlay(frame: self.view.frame)
        self.view.addSubview(emojiOptionsOverlay)
    }
    
    /// Scale and alpha of successive cards visible to the user
    let cardAttributes: [(downscale: CGFloat, alpha: CGFloat)] = [(1, 1), (0.92, 0.8), (0.84, 0.6), (0.76, 0.4)]
    let cardInteritemSpacing: CGFloat = 15
    
    /// Set up the frames, alphas, and transforms of the first 4 cards on the screen
    func layoutCards() {
        // frontmost card (first card of the deck)
        let firstCard = cards[0]
        self.view.addSubview(firstCard)
        firstCard.layer.zPosition = CGFloat(cards.count)
        firstCard.center = self.view.center
        firstCard.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleCardPan)))
        
        // the next 3 cards in the deck
        for i in 1...3 {
            if i > (cards.count - 1) { continue }
            
            let card = cards[i]
            
            card.layer.zPosition = CGFloat(cards.count - i)
            
            // here we're just getting some hand-picked vales from cardAttributes (an array of tuples) 
            // which will tell us the attributes of each card in the 4 cards visible to the user
            let downscale = cardAttributes[i].downscale
            let alpha = cardAttributes[i].alpha
            card.transform = CGAffineTransform(scaleX: downscale, y: downscale)
            card.alpha = alpha
            
            // position each card so there's a set space (cardInteritemSpacing) between each card, to give it a fanned out look
            card.center.x = self.view.center.x
            card.frame.origin.y = cards[0].frame.origin.y - (CGFloat(i) * cardInteritemSpacing)
            // workaround: scale causes heights to skew so compensate for it with some tweaking
            if i == 3 {
                card.frame.origin.y += 1.5
            }
            
            self.view.addSubview(card)
        }
        
        // make sure that the first card in the deck is at the front
        self.view.bringSubview(toFront: cards[0])
    }
    
    /// This is called whenever the front card is swiped off the screen or is animating away from its initial position.
    /// showNextCard() just adds the next card to the 4 visible cards and animates each card to move forward.
    func showNextCard() {
        let animationDuration: TimeInterval = 0.2
        // 1. animate each card to move forward one by one
        for i in 1...3 {
            if i > (cards.count - 1) { continue }
            let card = cards[i]
            let newDownscale = cardAttributes[i - 1].downscale
            let newAlpha = cardAttributes[i - 1].alpha
            UIView.animate(withDuration: animationDuration, delay: (TimeInterval(i - 1) * (animationDuration / 2)), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: {
                card.transform = CGAffineTransform(scaleX: newDownscale, y: newDownscale)
                card.alpha = newAlpha
                if i == 1 {
                    card.center = self.view.center
                } else {
                    card.center.x = self.view.center.x
                    card.frame.origin.y = self.cards[1].frame.origin.y - (CGFloat(i - 1) * self.cardInteritemSpacing)
                }
            }, completion: { (_) in
                if i == 1 {
                    card.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handleCardPan)))
                }
            })
            
        }
        
        // 2. add a new card (now the 4th card in the deck) to the very back
        if 4 > (cards.count - 1) {
            if cards.count != 1 {
                self.view.bringSubview(toFront: cards[1])
            }
            return
        }
        let newCard = cards[4]
        newCard.layer.zPosition = CGFloat(cards.count - 4)
        let downscale = cardAttributes[3].downscale
        let alpha = cardAttributes[3].alpha
        
        // initial state of new card
        newCard.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        newCard.alpha = 0
        newCard.center.x = self.view.center.x
        newCard.frame.origin.y = cards[1].frame.origin.y - (4 * cardInteritemSpacing)
        self.view.addSubview(newCard)
        
        // animate to end state of new card
        UIView.animate(withDuration: animationDuration, delay: (3 * (animationDuration / 2)), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: {
            newCard.transform = CGAffineTransform(scaleX: downscale, y: downscale)
            newCard.alpha = alpha
            newCard.center.x = self.view.center.x
            newCard.frame.origin.y = self.cards[1].frame.origin.y - (3 * self.cardInteritemSpacing) + 1.5
        }, completion: { (_) in
            
        })
        // first card needs to be in the front for proper interactivity
        self.view.bringSubview(toFront: self.cards[1])
        
    }
    
    /// Whenever the front card is off the screen, this method is called in order to remove the card from our data structure and from the view.
    func removeOldFrontCard() {
        cards[0].removeFromSuperview()
        cards.remove(at: 0)
    }
    
    /// UIKit dynamics variables that we need references to.
    var dynamicAnimator: UIDynamicAnimator!
    var cardAttachmentBehavior: UIAttachmentBehavior!
    
    /// This method handles the swiping gesture on each card and shows the appropriate emoji based on the card's center.
    func handleCardPan(sender: UIPanGestureRecognizer) {
        // if we're in the process of hiding a card, don't let the user interace with the cards yet
        if cardIsHiding { return }
        // change this to your discretion - it represents how far the user must pan up or down to change the option
        let optionLength: CGFloat = 60
        // distance user must pan right or left to trigger an option
        let requiredOffsetFromCenter: CGFloat = 15
        
        let panLocationInView = sender.location(in: view)
        let panLocationInCard = sender.location(in: cards[0])
        switch sender.state {
        case .began:
            dynamicAnimator.removeAllBehaviors()
            let offset = UIOffsetMake(panLocationInCard.x - cards[0].bounds.midX, panLocationInCard.y - cards[0].bounds.midY);
            // card is attached to center
            cardAttachmentBehavior = UIAttachmentBehavior(item: cards[0], offsetFromCenter: offset, attachedToAnchor: panLocationInView)
            dynamicAnimator.addBehavior(cardAttachmentBehavior)
        case .changed:
            cardAttachmentBehavior.anchorPoint = panLocationInView
            if cards[0].center.x > (self.view.center.x + requiredOffsetFromCenter) {
                if cards[0].center.y < (self.view.center.y - optionLength) {
                    cards[0].showOptionLabel(option: .like1)
                    emojiOptionsOverlay.showEmoji(for: .like1)
                    
                    if cards[0].center.y < (self.view.center.y - optionLength - optionLength) {
                        emojiOptionsOverlay.updateHeartEmoji(isFilled: true, isFocused: true)
                    } else {
                        emojiOptionsOverlay.updateHeartEmoji(isFilled: true, isFocused: false)
                    }
                    
                } else if cards[0].center.y > (self.view.center.y + optionLength) {
                    cards[0].showOptionLabel(option: .like3)
                    emojiOptionsOverlay.showEmoji(for: .like3)
                    emojiOptionsOverlay.updateHeartEmoji(isFilled: false, isFocused: false)
                } else {
                    cards[0].showOptionLabel(option: .like2)
                    emojiOptionsOverlay.showEmoji(for: .like2)
                    emojiOptionsOverlay.updateHeartEmoji(isFilled: false, isFocused: false)
                }
            } else if cards[0].center.x < (self.view.center.x - requiredOffsetFromCenter) {
                
                emojiOptionsOverlay.updateHeartEmoji(isFilled: false, isFocused: false)
                
                if cards[0].center.y < (self.view.center.y - optionLength) {
                    cards[0].showOptionLabel(option: .dislike1)
                    emojiOptionsOverlay.showEmoji(for: .dislike1)
                } else if cards[0].center.y > (self.view.center.y + optionLength) {
                    cards[0].showOptionLabel(option: .dislike3)
                    emojiOptionsOverlay.showEmoji(for: .dislike3)
                } else {
                    cards[0].showOptionLabel(option: .dislike2)
                    emojiOptionsOverlay.showEmoji(for: .dislike2)
                }
            } else {
                cards[0].hideOptionLabel()
                emojiOptionsOverlay.hideFaceEmojis()
            }
            
        case .ended:
            
            dynamicAnimator.removeAllBehaviors()
            
            if emojiOptionsOverlay.heartIsFocused {
                // animate card to get "swallowed" by heart
                
                let currentAngle = CGFloat(atan2(Double(cards[0].transform.b), Double(cards[0].transform.a)))
                
                let heartCenter = emojiOptionsOverlay.heartEmoji.center
                var newTransform = CGAffineTransform.identity
                newTransform = newTransform.scaledBy(x: 0.05, y: 0.05)
                newTransform = newTransform.rotated(by: currentAngle)
                
                UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut], animations: {
                    self.cards[0].center = heartCenter
                    self.cards[0].transform = newTransform
                    self.cards[0].alpha = 0.5
                }, completion: { (_) in
                    self.emojiOptionsOverlay.updateHeartEmoji(isFilled: false, isFocused: false)
                    self.removeOldFrontCard()
                })
                
                emojiOptionsOverlay.hideFaceEmojis()
                showNextCard()
                
            } else {
                emojiOptionsOverlay.hideFaceEmojis()
                emojiOptionsOverlay.updateHeartEmoji(isFilled: false, isFocused: false)
                
                if !(cards[0].center.x > (self.view.center.x + requiredOffsetFromCenter) || cards[0].center.x < (self.view.center.x - requiredOffsetFromCenter)) {
                    // snap to center
                    let snapBehavior = UISnapBehavior(item: cards[0], snapTo: self.view.center)
                    dynamicAnimator.addBehavior(snapBehavior)
                } else {
                    
                    let velocity = sender.velocity(in: self.view)
                    let pushBehavior = UIPushBehavior(items: [cards[0]], mode: .instantaneous)
                    pushBehavior.pushDirection = CGVector(dx: velocity.x/10, dy: velocity.y/10)
                    pushBehavior.magnitude = 175
                    dynamicAnimator.addBehavior(pushBehavior)
                    // spin after throwing
                    var angular = CGFloat.pi / 2 // angular velocity of spin
                    
                    let currentAngle: Double = atan2(Double(cards[0].transform.b), Double(cards[0].transform.a))
                    
                    if currentAngle > 0 {
                        angular = angular * 1
                    } else {
                        angular = angular * -1
                    }
                    let itemBehavior = UIDynamicItemBehavior(items: [cards[0]])
                    itemBehavior.friction = 0.2
                    itemBehavior.allowsRotation = true
                    itemBehavior.addAngularVelocity(CGFloat(angular), for: cards[0])
                    dynamicAnimator.addBehavior(itemBehavior)
                    
                    showNextCard()
                    hideFrontCard()
                    
                }
            }
        default:
            break
        }
    }
    
    /// This function continuously checks to see if the card's center is on the screen anymore. If it finds that the card's center is not on screen, then it triggers removeOldFrontCard() which removes the front card from the data structure and from the view.
    var cardIsHiding = false
    func hideFrontCard() {
        if #available(iOS 10.0, *) {
            var cardRemoveTimer: Timer? = nil
            cardRemoveTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] (_) in
                guard self != nil else { return }
                if !(self!.view.bounds.contains(self!.cards[0].center)) {
                    cardRemoveTimer!.invalidate()
                    self?.cardIsHiding = true
                    UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
                        self?.cards[0].alpha = 0.0
                    }, completion: { (_) in
                        self?.removeOldFrontCard()
                        self?.cardIsHiding = false
                    })
                }
            })
        } else {
            // fallback for earlier versions
            UIView.animate(withDuration: 0.2, delay: 1.5, options: [.curveEaseIn], animations: {
                self.cards[0].alpha = 0.0
            }, completion: { (_) in
                self.removeOldFrontCard()
            })
        }
    }
}

// MARK: - Unrelated to cards logic code

extension ViewController {
    /// Hide status bar
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    /// Dummy UI
    func setUpDummyUI() {
        // menu icon
        let menuIconImageView = UIImageView(image: UIImage(named: "menu_icon"))
        menuIconImageView.contentMode = .scaleAspectFit
        menuIconImageView.frame = CGRect(x: 35, y: 30, width: 35, height: 30)
        menuIconImageView.isUserInteractionEnabled = false
        self.view.addSubview(menuIconImageView)
        
        // title label
        let titleLabel = UILabel()
        titleLabel.text = "How do you like\nthis one?"
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 19)
        titleLabel.textColor = UIColor(red: 83/255, green: 98/255, blue: 196/255, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: (self.view.frame.width / 2) - 90, y: 17, width: 180, height: 60)
        self.view.addSubview(titleLabel)
        
        // REACT
        let reactLabel = UILabel()
        reactLabel.text = "REACT"
        reactLabel.font = UIFont(name: "AvenirNextCondensed-Heavy", size: 28)
        reactLabel.textColor = UIColor(red: 54/255, green: 72/255, blue: 149/255, alpha: 1.0)
        reactLabel.textAlignment = .center
        reactLabel.frame = CGRect(x: (self.view.frame.width / 2) - 60, y: self.view.frame.height - 70, width: 120, height: 50)
        self.view.addSubview(reactLabel)
        
        // <- ☹️
        let frownArrowImageView = UIImageView(image: UIImage(named: "frown_arrow"))
        frownArrowImageView.contentMode = .scaleAspectFit
        frownArrowImageView.frame = CGRect(x: (self.view.frame.width / 2) - 140, y: self.view.frame.height - 70, width: 80, height: 50)
        frownArrowImageView.isUserInteractionEnabled = false
        self.view.addSubview(frownArrowImageView)
        
        // 🙂 ->
        let smileArrowImageView = UIImageView(image: UIImage(named: "smile_arrow"))
        smileArrowImageView.contentMode = .scaleAspectFit
        smileArrowImageView.frame = CGRect(x: (self.view.frame.width / 2) + 60, y: self.view.frame.height - 70, width: 80, height: 50)
        smileArrowImageView.isUserInteractionEnabled = false
        self.view.addSubview(smileArrowImageView)
    }
}

