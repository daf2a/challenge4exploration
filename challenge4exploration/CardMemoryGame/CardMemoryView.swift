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
    @State private var showTurnIndicator = false
    @State private var matchedPair: [Card] = []
    @State private var showMatchedPair = false
    @State private var matchedPairOffset: CGSize = .zero
    @State private var matchedPairPositions: [UUID: CGRect] = [:]
    @Namespace private var animation
    
    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    let allImages = [
        "sun.max.fill", "moon.fill", "cloud.fill", "bolt.fill", "snowflake",
        "flame.fill", "drop.fill", "leaf.fill", "ant.fill"
    ]
    
    var resultView: some View {
        ZStack {
            VStack(spacing: 0) {
                Color.red.opacity(0.8)
                    .ignoresSafeArea()
                    .frame(height: UIScreen.main.bounds.height / 2)
                Color.mint.opacity(0.8)
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 40) {
                Image(winnerImageName())
                    .resizable()
                    .frame(width: 120, height: 120)
                
                Image(loserImageName())
                    .resizable()
                    .frame(width: 100, height: 100)
                
                Button("Rematch") {
                    startGame()
                }
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .clipShape(Capsule())
            }
        }
    }
    
    
    var body: some View {
        ZStack {
            (isPlayer1Turn ? Color.mint.opacity(0.5) : Color.red.opacity(0.5))
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.black.opacity(0.7), lineWidth: 12)
                            .fill(Color.yellow)
                            .frame(width: 100, height: 100)
                        VStack {
                            Text("Player 2")
                                .bold()
                                .foregroundColor(.red)
                            Text("\(player2.score)")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.red)
                        }
                        .padding()
                        .rotationEffect(.degrees(180))
                    }
                }
                
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.black, lineWidth: 12)
                        .fill(Color.orange)
                    
                    // Kartu cocok muncul di tengah (dalam keadaan terbuka)
                    if showMatchedPair {
                        HStack(spacing: 20) {
                            ForEach(matchedPair) { card in
                                CardView(card: card, forceFlipped: true)
                                    .matchedGeometryEffect(id: card.id, in: animation)
                                    .frame(width: 75, height: 75)
                            }
                        }
                        .offset(matchedPairOffset)
                        .zIndex(2)
                    }
                    
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(cards) { card in
                            if matchedPair.contains(where: { $0.id == card.id }) {
                                // Jangan tampilkan kartu yang sedang dianimasikan ke tengah
                                Color.clear
                                    .frame(width: 75, height: 75)
                            } else if card.isMatched {
                                // Kartu yang sudah cocok: tampilkan slot kosong
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.clear)
                                    .frame(width: 75, height: 75)
                            } else {
                                // Kartu normal
                                CardView(card: card)
                                    .matchedGeometryEffect(id: card.id, in: animation)
                                    .onTapGesture {
                                        flipCard(card)
                                    }
                                    .background(
                                        GeometryReader { geo in
                                            Color.clear
                                                .onAppear {
                                                    matchedPairPositions[card.id] = geo.frame(in: .global)
                                                }
                                        }
                                    )
                            }
                        }
                        //                        .rotationEffect(.degrees(isPlayer1Turn ? 0 : 180))
                    }
                    .padding()
                }
                .padding(.vertical)
                
                
                Spacer()
                
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.black.opacity(0.7), lineWidth: 12)
                            .fill(Color.yellow)
                            .frame(width: 100, height: 100)
                        VStack {
                            Text("Player 1")
                                .bold()
                                .foregroundColor(.mint)
                            Text("\(player1.score)")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.mint)
                        }
                        .padding()
                    }
                    Spacer()
                }
                
                //                if gameOver {
                //                    resultView
                //                }
                
            }
            .padding()
            .onAppear {
                startGame()
            }
            
            if gameOver {
                resultView
            }
            
            if isPlayer1Turn && showTurnIndicator {
                VStack {
                    Spacer()
                    HStack {
                        ZStack {
                            Circle()
                                .stroke(.white, lineWidth: 10)
                                .fill(Color.mint)
                                .frame(width: 200, height: 200)
                                .overlay(
                                    Text("Your turn!")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                        .rotationEffect(.degrees(40))
                                        .padding(.bottom, 20)
                                )
                        }
                        .offset(x: -40, y: 70)
                        Spacer()
                    }
                }
                .transition(.opacity)
                .animation(.easeInOut, value: showTurnIndicator)
            } else if !isPlayer1Turn && showTurnIndicator {
                VStack {
                    Spacer()
                    HStack {
                        ZStack {
                            Circle()
                                .stroke(.white, lineWidth: 10)
                                .fill(Color.red)
                                .frame(width: 200, height: 200)
                                .overlay(
                                    Text("Your turn!")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                        .rotationEffect(.degrees(220))
                                )
                        }
                        .offset(x: 240, y: -680)
                        Spacer()
                    }
                }
                .transition(.opacity)
                .animation(.easeInOut, value: showTurnIndicator)
            }
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
        showTurnLabelTemporarily()
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
    
    func showTurnLabelTemporarily() {
        withAnimation {
            showTurnIndicator = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                showTurnIndicator = false
            }
        }
    }
    
    func checkForMatch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard flippedCards.count == 2 else { return }
            let first = flippedCards[0]
            let second = flippedCards[1]
            
            if first.imageName == second.imageName {
                matchedPair = [first, second]
                withAnimation(.easeInOut(duration: 0.5)) {
                    showMatchedPair = true
                }
                
                if let i1 = cards.firstIndex(where: { $0.id == first.id }),
                   let i2 = cards.firstIndex(where: { $0.id == second.id }) {
                    cards[i1].isMatched = true
                    cards[i2].isMatched = true
                }
                
                if isPlayer1Turn {
                    player1.score += 1
                } else {
                    player2.score += 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        matchedPairOffset = CGSize(width: isPlayer1Turn ? -300 : 300, height: 0)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        matchedPair = []
                        matchedPairOffset = .zero
                        showMatchedPair = false
                    }
                }
            } else {
                if let firstIndex = cards.firstIndex(where: { $0.id == first.id }) {
                    cards[firstIndex].isFlipped = false
                }
                if let secondIndex = cards.firstIndex(where: { $0.id == second.id }) {
                    cards[secondIndex].isFlipped = false
                }
                isPlayer1Turn.toggle()
                showTurnLabelTemporarily()
            }
            
            flippedCards.removeAll()
            
            if cards.allSatisfy({ $0.isMatched }) {
                gameOver = true
            }
        }
    }
    
    func winnerImageName() -> String {
        return player1.score > player2.score ? "medal_gold" : "medal_silver"
    }
    
    func loserImageName() -> String {
        return player1.score > player2.score ? "medal_silver" : "medal_gold"
    }
    
    
    func resultText() -> String {
        if player1.score > player2.score {
            return "Player 1 Wins!"
        } else if player2.score > player1.score {
            return "Player 2 Wins!"
        } else {
            return "It's a Draw!"
        }
    }
}

struct CardView: View {
    let card: Card
    var forceFlipped: Bool = false
    @State private var flipped = false
    
    var body: some View {
        ZStack {
            if flipped {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: 6)
                    .fill(Color.cyan.opacity(0.7))
                    .frame(width:75, height: 75)
                    .overlay(
                        Image(systemName: card.imageName)
                            .resizable()
                            .scaledToFit()
                            .padding(10)
                            .foregroundColor(.black)
                    )
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: 6)
                    .fill(Color.yellow)
                    .frame(width:75, height: 75)
            }
        }
        .rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .onAppear {
            if forceFlipped {
                flipped = true
            }
        }
        .onChange(of: card.isFlipped) { _, newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                flipped = newValue
            }
        }
    }
}

struct CardMemoryView_PreviewWrapper: View {
    var body: some View {
        // Buat CardMemoryView dan panggil resultView-nya
        CardMemoryView().resultView
    }
}

//#Preview("Result View Preview") {
//    // Buat instance dummy untuk preview
//    CardMemoryView_PreviewWrapper()
//}

#Preview {
    CardMemoryView()
}
