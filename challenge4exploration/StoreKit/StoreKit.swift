//
//  StoreKit.swift
//  challenge4exploration
//
//  Created by Ahmad Zuhal Zhafran on 05/06/25.
//

import StoreKit
import SwiftUI

struct StoreKit: View {
    @State var coins: Int = 0
    @State var adFree: Bool = false
    @State var subscription: Bool = false
    @State var purchaseStatus: String = ""
    @State var products: [Product] = []
    
    func loadProducts(ids: [String]) async {
        do {
            let storeProducts = try await Product.products(for: ids)
            products = storeProducts
        } catch {
            purchaseStatus = "Failed to load products: \(error.localizedDescription)"
        }
    }
    
    func restorePurchase() async {
        // This only recover non-consumables and subs
        // No consumables is recovered
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                print("Restored: \(transaction)")
                await handlePurchase(transaction.productID)
            case .unverified(_, let error):
                print("Error restoring purchase: \(error)")
            }
        }
    }
    
    func handlePurchase(_ productID: String) async {
        switch productID {
            case "com.example.adfree":
                adFree = true
            case "com.example.subscription":
                subscription = true
            case "com.example.1000_coin":
                coins += 1000
            default:
                break
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                do {
                    switch verification {
                    case .verified(let transaction):
                        purchaseStatus = "Purchased: \(transaction.productID)"
                        await transaction.finish()
                        await handlePurchase(transaction.productID)
                    case .unverified(_, let error):
                        purchaseStatus =
                            "Unverified: \(error.localizedDescription)"
                    }
                }

            case .pending:
                purchaseStatus = "Pending purchase."

            case .userCancelled:
                purchaseStatus = "User cancelled."

            @unknown default:
                purchaseStatus = "Unknown error."
            }
            
            print(purchaseStatus)
        } catch {
            purchaseStatus = "Error: \(error.localizedDescription)"
        }
    }

    var body: some View {
        VStack {
            Text("Coin : \(coins)")
            Text("You are \(adFree ? "ad free" : "not ad free")")

            ForEach (products) { product in
                Button("Buy \(product.displayName) - \(product.displayPrice)") {
                    Task {
                        await purchase(product)
                    }
                }
            }

            Text("Hello subscriber!")
                .fontWeight(.bold)
                .opacity(subscription ? 1 : 0)
                .padding(.vertical)
            
            Button("Restore purchases") {
                Task.init{
                    await restorePurchase()
                }
            }
        }
        .task {
            await loadProducts(ids: ["com.example.adfree", "com.example.1000_coin"])
            
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }

                await handlePurchase(transaction.productID)

                await transaction.finish()
            }
        }
    }
}

#Preview {
    StoreKit()
}
