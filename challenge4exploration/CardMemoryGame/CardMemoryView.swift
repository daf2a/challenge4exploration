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
    @State private var backgroundColor: Color = Color.mint.opacity(0.5)
    @State private var lastMatchedByPlayer1: Bool = true
    
    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    let allImages = [
        "animal_1", "animal_2", "animal_3", "animal_4", "animal_5", "animal_6", "animal_7", "animal_8", "animal_9"
    ]
    
    var sortedPlayers: [Player] {
        [player1, player2].sorted { $0.score > $1.score }
    }
    
    var winner: Player? {
        sortedPlayers[0]
    }
    
    var resultView: some View {
        ZStack{
            (player1.score > player2.score ? Color.mint.opacity(0.5) : Color.red.opacity(0.5))
                .ignoresSafeArea()
            VStack {
                VStack{
                    Text("🏆 Winner!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text(winner!.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text("\(winner!.score)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black.opacity(0.9))
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 25)
                .background(
                    Color.white.opacity(0.3))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Final Standings")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    LazyVStack(spacing: 10) {
                        ForEach(Array(sortedPlayers.enumerated()), id: \.offset) { index, player in
                            HStack {
                                if index == 0 {
                                    Image("medal_gold")
                                        .resizable()
                                        .frame(width: 82, height: 82)
                                } else {
                                    Image("medal_silver")
                                        .resizable()
                                        .frame(width: 82, height: 82)
                                }
                                
                                Text(player.name)
                                    .font(.title3.bold())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.black)
                                    .padding(.leading, 20)
                                
                                Text("\(player.score)")
                                    .font(.title3.bold())
                                    .frame(width: 100)
                                    .foregroundColor(.black)
                            }
                            .padding(.trailing, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(index == 0 ? Color.yellow.opacity(0.2) : Color.white.opacity(0.1))
                                    .stroke(index == 0 ? Color.yellow.opacity(1) : Color.clear, lineWidth: 5)
                                    .shadow(color: .white.opacity(0.8), radius: 10, x: 0, y: 5)
                            )
                            .cornerRadius(15)
                            
                        }
                    }
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 20)
                .background(Color.white.opacity(0.3))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .padding()
        }
        
        
        //                ZStack {
        //                    //            (player1.score > player2.score ? Color.mint.opacity(0.5) : Color.red.opacity(0.5))
        //                    //                .ignoresSafeArea()
        //                    RoundedRectangle(cornerRadius: 20)
        //                        .fill(Color.purple.opacity(0.7))
        //                        .frame(height: 350)
        //                        .padding(7)
        //                    VStack(spacing: 0) {
        //                        // Header row
        //                        HStack {
        //                            Text("Rank")
        //                                .font(.title2.bold())
        //                                .foregroundColor(.white)
        //                                .frame(width: 60, alignment: .leading)
        //
        //                            Text("Name")
        //                                .font(.title2.bold())
        //                                .foregroundColor(.white)
        //                                .frame(maxWidth: .infinity, alignment: .leading)
        //                                .padding(.leading, 20)
        //
        //                            Text("Score")
        //                                .font(.title2.bold())
        //                                .foregroundColor(.white)
        //                                .frame(width: 100)
        //                        }
        //                        .padding(.horizontal, 20)
        //                        .padding(.bottom, 25)
        //                        //                .background(Color.purple.opacity(0.6))
        //                        //                .cornerRadius(15)
        //
        //                        // Leaderboard rows
        //                        ForEach(Array(sortedPlayers.enumerated()), id: \.offset) {
        //                            index,
        //                            player in
        //                            HStack {
        //                                if index == 0 {
        //                                    Image("medal_gold")
        //                                        .resizable()
        //                                        .frame(width: 82, height: 82)
        //                                } else {
        //                                    Image("medal_silver")
        //                                        .resizable()
        //                                        .frame(width: 82, height: 82)
        //                                }
        //
        //                                Text(player.name)
        //                                    .font(.title3.bold())
        //                                    .frame(maxWidth: .infinity, alignment: .leading)
        //                                    .foregroundColor(.white)
        //                                    .padding(.leading, 20)
        //
        //                                Text("\(player.score)")
        //                                    .font(.title3.bold())
        //                                    .frame(width: 100)
        //                                    .foregroundColor(.white)
        //                            }
        //                            .padding(.trailing, 20)
        //                            .background(
        //                                index % 2 == 0
        //                                    ? Color.cyan.opacity(0.5) : Color.pink.opacity(0.5)
        //                            )
        //                            .cornerRadius(15)
        //                        }
        //                        .padding(.top, 7)
        //                    }
        //                    .padding(.horizontal)
        //                }
        
        //            ZStack{
        //                Color.red.opacity(0.8)
        //                    .ignoresSafeArea()
        //                    .frame(height: UIScreen.main.bounds.height / 2)
        //                Circle()
        //                    .fill(Color.black.opacity(0.3))
        //                    .frame(width: 150, height: 150)
        //                    .offset(y: 120)
        //                Image(resultMedal(score1: player2.score, score2: player1.score))
        //                    .resizable()
        //                    .frame(width: 250, height: 250)
        //                    .rotationEffect(.degrees(180))
        //                    .offset(y: 100)
        //            }
        //
        //            ZStack{
        //                Color.mint.opacity(0.8)
        //                    .ignoresSafeArea()
        //                    .frame(height: UIScreen.main.bounds.height / 2)
        //                Circle()
        //                    .fill(Color.black.opacity(0.3))
        //                    .frame(width: 150, height: 150)
        //                    .offset(y: -120)
        //                Image(resultMedal(score1: player1.score, score2: player2.score))
        //                    .resizable()
        //                    .frame(width: 250, height: 250)
        //                    .offset(y: -100)
        //            }
    }
    
    var body: some View {
        
        ZStack {
            // Warna background body
            backgroundColor
                .ignoresSafeArea()
                .opacity(0.5)
            VStack {
                ZStack {
                    // warna background board
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white)
                        .stroke(isPlayer1Turn ? Color.mint : Color.red, lineWidth: 6)
                        .fill(isPlayer1Turn ? Color.mint.opacity(0.5) : Color.pink.opacity(0.5))
                    
                    // Kartu cocok muncul di tengah (dalam keadaan terbuka)
                    if showMatchedPair {
                        HStack(spacing: 20) {
                            ForEach(matchedPair) { card in
                                CardView(
                                    card: card,
                                    isPlayer1Turn: isPlayer1Turn,
                                    overridePlayer1Color: lastMatchedByPlayer1,
                                    forceFlipped: true
                                )
                                
                                .matchedGeometryEffect(
                                    id: card.id,
                                    in: animation
                                )
                                .frame(width: 75, height: 75)
                            }
                        }
                        .offset(matchedPairOffset)
                        .zIndex(2)
                    }
                    
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(cards) { card in
                            if matchedPair.contains(where: { $0.id == card.id }) {
                                // Sebelumnya: Color.clear
                                // Ubah menjadi:
                                CardView(
                                    card: card,
                                    isPlayer1Turn: isPlayer1Turn
                                )
                                .matchedGeometryEffect(id: card.id, in: animation)
                                .frame(width: 75, height: 75)
                                .opacity(0) // agar tidak dobel terlihat
                            }
                            else if card.isMatched {
                                // Kartu yang sudah cocok: tampilkan slot kosong
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.clear)
                                    .frame(width: 75, height: 75)
                            }
                            else {
                                CardView(
                                    card: card,
                                    isPlayer1Turn: isPlayer1Turn
                                )
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
                    }
                    
                    .padding()
                }
                .padding(.vertical)
                
                Spacer()
                
                HStack {
                    ZStack {
                        // Warna kotak player 1
                        RoundedRectangle(cornerRadius: 20)
//                            .stroke(.mint.opacity(0.7), lineWidth: 12)
                            .fill(Color.mint)
                            .frame(width: 100, height: 100)
                        VStack {
                            Text("\(player1.name)")
                                .bold()
                                .foregroundColor(.white)
                            Text("\(player1.score)")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    ZStack {
                        // Warna kotak player 2
                        RoundedRectangle(cornerRadius: 20)
//                            .stroke(.black.opacity(0.7), lineWidth: 12)
                            .fill(Color.red)
                            .frame(width: 100, height: 100)
                        VStack {
                            Text("\(player2.name)")
                                .bold()
                                .foregroundColor(.white)
                            Text("\(player2.score)")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                }
            }
            .padding()
            .onAppear {
                startGame()
            }
            
            if gameOver {
                resultView
            }
            
            turnIndicatorView()
        }
        .onChange(of: isPlayer1Turn) { newValue in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation {
                    backgroundColor =
                    newValue
                    ? Color.mint.opacity(0.5) : Color.red.opacity(0.5)
                }
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
              !cards[index].isMatched
        else { return }
        
        cards[index].isFlipped = true
        flippedCards.append(cards[index])
        
        if flippedCards.count == 2 {
            checkForMatch()
        }
    }
    
    @ViewBuilder
    func turnIndicatorView() -> some View {
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
                                Text("Your Enemy's turn!")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .rotationEffect(.degrees(-40))
                            )
                    }
                    .offset(x: 240, y: 70)
                    Spacer()
                }
            }
            .transition(.opacity)
            .animation(.easeInOut, value: showTurnIndicator)
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
                lastMatchedByPlayer1 = isPlayer1Turn
                matchedPair = [first, second]
                withAnimation(.easeInOut(duration: 0.5)) {
                    showMatchedPair = true
                }
                
                if let i1 = cards.firstIndex(where: { $0.id == first.id }),
                   let i2 = cards.firstIndex(where: { $0.id == second.id })
                {
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
                        matchedPairOffset = CGSize(
                            width: isPlayer1Turn ? -300 : 300,
                            height: 0
                        )
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        matchedPair = []
                        matchedPairOffset = .zero
                        showMatchedPair = false
                    }
                }
            } else {
                if let firstIndex = cards.firstIndex(where: {
                    $0.id == first.id
                }) {
                    cards[firstIndex].isFlipped = false
                }
                if let secondIndex = cards.firstIndex(where: {
                    $0.id == second.id
                }) {
                    cards[secondIndex].isFlipped = false
                }
                isPlayer1Turn.toggle()
                showTurnLabelTemporarily()
            }
            
            flippedCards.removeAll()
            
            if cards.allSatisfy({ $0.isMatched }) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        gameOver = true
                    }
                }
            }
            
        }
    }
    
    func resultMedal(score1: Int, score2: Int) -> String {
        if score1 > score2 {
            return "medal_gold"
        } else {
            return "medal_silver"
        }
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
    var isPlayer1Turn: Bool
    var overridePlayer1Color: Bool? = nil
    var forceFlipped: Bool = false
    @State private var rotation: Double = 0
    @State private var lastFlippedByPlayer1: Bool = true
    
    var effectivePlayer1Color: Bool {
        overridePlayer1Color ?? lastFlippedByPlayer1
    }
    
    var isFront: Bool {
        rotation >= 90
    }
    
    var body: some View {
        ZStack {
            backCard
                .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
                .zIndex(isFront ? 0 : 1)
            
            frontCard
                .rotation3DEffect(
                    .degrees(rotation + 180),
                    axis: (x: 0, y: 1, z: 0)
                )
                .zIndex(isFront ? 1 : 0)
        }
        .onAppear {
            if forceFlipped {
                rotation = 180
            }
        }
        .onChange(of: card.isFlipped) { _, newValue in
            if newValue {
                // Saat mulai dibuka, simpan siapa yang flip
                lastFlippedByPlayer1 = isPlayer1Turn
            }
            
            let target = rotation + (newValue ? 180 : -180)
            let step: Double = 2.0
            let interval = 0.004
            
            Timer.scheduledTimer(withTimeInterval: interval, repeats: true) {
                timer in
                if newValue {
                    rotation += step
                    if rotation >= target {
                        rotation = target
                        timer.invalidate()
                    }
                } else {
                    rotation -= step
                    if rotation <= target {
                        rotation = target
                        timer.invalidate()
                    }
                }
            }
        }
    }
    
    var frontCard: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color.white, lineWidth: 6)
            .fill(
                effectivePlayer1Color
                ? Color.white
                : Color.white
            )
            .fill(
                effectivePlayer1Color
                ? Color.mint.opacity(0.25)
                : Color.red.opacity(0.25)
            )
            .frame(width: 75, height: 75)
            .overlay(
                Image(card.imageName)
                    .resizable()
                    .frame(width: 70, height: 70)
//                    .scaledToFit()
                    .padding(10)
                    .foregroundColor(.white)
            )
            .opacity(1)  // Tetap terlihat
    }
    
    var backCard: some View {
        // Warna 18 kartu
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color.white, lineWidth: 6)
            .fill(isPlayer1Turn ? Color.mint : Color.red)
            .frame(width: 75, height: 75)
            .opacity(1)  // Tetap terlihat
    }
}

struct CardMemoryView_PreviewWrapper: View {
    var body: some View {
        // Buat CardMemoryView dan panggil resultView-nya
        CardMemoryView().resultView
    }
}

#Preview("Result View Preview") {
    // Buat instance dummy untuk preview
    CardMemoryView_PreviewWrapper()
}

#Preview {
    CardMemoryView()
}
