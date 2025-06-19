//
//  CardMemoryView.swift
//  challenge4exploration
//
//  Created by Ahmad Zuhal Zhafran on 18/06/25.
//

import SwiftUI

struct Card: Identifiable {
    let id = UUID()
    let imageName: String
    var isFlipped: Bool = false
    var isMatched: Bool = false
}

struct Player {
    var score: Int = 0
    var name: String
}

struct CardMemoryView: View {
    @State private var cards: [Card] = []
    @State private var flippedCards: [Card] = []
    @State private var player1 = Player(name: "Player 1")
    @State private var player2 = Player(name: "Player 2")
    @State private var isPlayer1Turn = true
    @State private var gameOver = false
    @State private var showResult = false
    
    let columns = [GridItem(.adaptive(minimum: 50))]
    
    let allImages = [
        "sun.max.fill", "moon.fill", "cloud.fill", "bolt.fill", "snowflake",
        "flame.fill", "drop.fill", "leaf.fill", "ant.fill", "ladybug.fill",
        "pawprint.fill", "tortoise.fill", "hare.fill", "fish.fill", "star.fill"
    ]
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("Player 1")
                        .bold()
                        .foregroundColor(isPlayer1Turn ? .green : .primary)
                    Text("\(player1.score)")
                        .font(.largeTitle)
                }
                Spacer()
                VStack {
                    Text("Player 2")
                        .bold()
                        .foregroundColor(!isPlayer1Turn ? .green : .primary)
                    Text("\(player2.score)")
                        .font(.largeTitle)
                }
            }
            .padding()
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(cards) { card in
                    CardView(card: card)
                        .onTapGesture {
                            flipCard(card)
                        }
                }
            }
            .padding()
            
            if gameOver {
                VStack {
                    Text(resultText())
                        .font(.title)
                        .bold()
                        .padding()
                    Button("Rematch") {
                        startGame()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
            }
        }
        .onAppear {
            startGame()
        }
    }
    
    func startGame() {
        let pairedImages = (allImages + allImages).shuffled()
        cards = pairedImages.map { Card(imageName: $0) }
        player1.score = 0
        player2.score = 0
        isPlayer1Turn = true
        gameOver = false
        flippedCards = []
    }
    
    func flipCard(_ card: Card) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }),
              !cards[index].isFlipped,
              flippedCards.count < 2,
              !cards[index].isMatched else { return }
        
        cards[index].isFlipped = true
        flippedCards.append(cards[index])
        
        if flippedCards.count == 2 {
            checkForMatch()
        }
    }
    
    func checkForMatch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard flippedCards.count == 2 else { return }
            let first = flippedCards[0]
            let second = flippedCards[1]
            
            if first.imageName == second.imageName {
                // Match!
                if let firstIndex = cards.firstIndex(where: { $0.id == first.id }),
                   let secondIndex = cards.firstIndex(where: { $0.id == second.id }) {
                    cards[firstIndex].isMatched = true
                    cards[secondIndex].isMatched = true
                    
                    if isPlayer1Turn {
                        player1.score += 1
                    } else {
                        player2.score += 1
                    }
                }
            } else {
                // Not matched, flip back
                if let firstIndex = cards.firstIndex(where: { $0.id == first.id }) {
                    cards[firstIndex].isFlipped = false
                }
                if let secondIndex = cards.firstIndex(where: { $0.id == second.id }) {
                    cards[secondIndex].isFlipped = false
                }
                isPlayer1Turn.toggle()
            }
            
            flippedCards.removeAll()
            
            if cards.allSatisfy({ $0.isMatched }) {
                gameOver = true
            }
        }
    }
    
    func resultText() -> String {
        if player1.score > player2.score {
            return "🎉 Player 1 Wins!"
        } else if player2.score > player1.score {
            return "🎉 Player 2 Wins!"
        } else {
            return "🤝 It's a Draw!"
        }
    }
}

struct CardView: View {
    let card: Card
    
    var body: some View {
        ZStack {
            if card.isFlipped || card.isMatched {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .frame(height: 60)
                    .overlay(
                        Image(systemName: card.imageName)
                            .resizable()
                            .scaledToFit()
                            .padding(10)
                            .foregroundColor(.black)
                    )
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.yellow)
                    .frame(height: 60)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: card.isFlipped)
    }
}

#Preview {
    CardMemoryView()
}
