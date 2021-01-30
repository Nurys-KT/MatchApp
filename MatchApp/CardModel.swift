//
//  CardModel.swift
//  MatchApp
//
//  Created by KYUNGTAE KIM on 2021/01/27.
//

import Foundation

class CardModel {
    
    func getCards() -> [Card] {
        
        // Declare an empty array
        var generatedCards: [Card] = []
        var selectedCards: [Int] = []
        
        // Randomly generate 8 pairs of cards
        while selectedCards.count < 8 {
            // Generate a random number
            let randomNumber = Int.random(in: 1...13)
            
            // check card number duplicated
            if selectedCards.contains(randomNumber) {
                continue
            } else {
                selectedCards += [randomNumber]
            }
            
            // Create two new card object
            let cardOne = Card()
            let cardTwo = Card()
            
            // set their image names
            cardOne.imageName = "card\(randomNumber)"
            cardTwo.imageName = "card\(randomNumber)"
            
            // add them to array
            generatedCards += [cardOne, cardTwo]
            
            print(randomNumber)
        }
        
        // Randomize the card within the array
        generatedCards.shuffle()
        
        // Return the array
        return generatedCards
    }
    
}
