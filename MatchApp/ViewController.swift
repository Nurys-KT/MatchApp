//
//  ViewController.swift
//  MatchApp
//
//  Created by KYUNGTAE KIM on 2021/01/27.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var timerLabel: UILabel!
    
    let model = CardModel()
    var cardsArray: [Card] = []
    
    var timer: Timer?
    var milliseconds: Int = 10 * 1000
    
    var firstFlippedCardIndex: IndexPath?
    
    var soundPlayer = SoundManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardsArray = model.getCards()
        
        // Set the view controller as the datasource and delegate of the collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Initialize the timer
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Play shuffle sound
        soundPlayer.playSound(effect: .shuffle)
    }
    
    // MARK: - Timer Methods
    @objc func timerFired() {
        // Decrement the counter
        milliseconds -= 1
        
        // update the label
        let seconds: Double = Double(milliseconds)/1000.0
        timerLabel.text = String(format: "Time Remaining : %.2f", seconds)
        
        // stop the timer if it reaches zero
        if milliseconds == 0 {
            timerLabel.textColor = UIColor.red
            timer?.invalidate()
            
            // check if the user has cleared all the pairs
            checkForGameEnd()
        }
    }
    
}

// MARK: - Collection View Delegate Methods
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // check timer and if it's over, user can't try flip
        if milliseconds <= 0 {
            return
        }
        
        // get a reference to the cell that was tapped
        guard let cell = collectionView.cellForItem(at: indexPath) as? CardCell else { return }
        
        // check the status of the card to determine how to flip it
        if cell.card?.isFlipped == false && cell.card?.isMatched == false {
            // Flip the card up
            cell.flipUp()
            
            // Play flip sound
            soundPlayer.playSound(effect: .flip)
            
            // check if this is the first card that was flipped or the second card
            if firstFlippedCardIndex == nil {
                // this is the first card flipped over
                firstFlippedCardIndex = indexPath
            } else {
                // second card that is flipped
                
                // run the comparison logic
                checkForMatch(indexPath)
            }
        }
    }
    
    // MARK: - Game Logic Methods
    func checkForMatch(_ secondFlippedCardIndex: IndexPath) {
        
        // get the two card object for the tow indices and see if thay match
        let cardOne = cardsArray[firstFlippedCardIndex!.row]
        let cardTwo = cardsArray[secondFlippedCardIndex.row]
        
        // get the two collection view cells that represent card one and two
        let cardOneCell = collectionView.cellForItem(at: firstFlippedCardIndex!) as? CardCell
        let cardTwoCell = collectionView.cellForItem(at: secondFlippedCardIndex) as? CardCell

        // compare the tow cards
        if cardOne.imageName == cardTwo.imageName {
            
            soundPlayer.playSound(effect: .match)
            
            // it's a match
            cardOne.isMatched = true
            cardTwo.isMatched = true
            
            // set the status and remove them
            cardOneCell?.remove()
            cardTwoCell?.remove()
            
            // Was that the las pair?
            checkForGameEnd()
        } else {
            
            soundPlayer.playSound(effect: .nomatch)
            
            // i'ts not match
            cardOne.isFlipped = false
            cardTwo.isFlipped = false
            
            // flip them back over
            cardOneCell?.flipDown()
            cardTwoCell?.flipDown()
        }
        
        // reset the firstFlippedCardIndex property
        self.firstFlippedCardIndex = nil
    }
    
    func checkForGameEnd() {
        // Check if there's any card that is unmatched
        var hasWon = true
        
        for card in cardsArray {
            if !card.isMatched {
                hasWon = false
                break
            }
        }
        
        if hasWon {
            // show alert
            showAlert(title: "Congratulations!", message: "You've won the game!")
        } else {
            // check time left
            if milliseconds <= 0 {
                showAlert(title: "Time's Up", message: "Sorry, better luck next time")
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Collection View DataSource Methods
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return number of cards
        return cardsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Get a cell
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as? CardCell else {
            return UICollectionViewCell()
        }
 
        // Return it
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // configure the state of the cell based on the properties of the card that it represents
        
        let cardCell = cell as? CardCell
        
        // get the card from the card array
        let card = cardsArray[indexPath.row]
        
        // Configure it
        cardCell?.configureCell(card: card)
    }
}
