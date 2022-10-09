//
//  DataModel.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import Foundation
import GameplayKit

final class DataModel: ObservableObject {
    @Published var transactions = {
        var sampleTransactions: [Transaction] = []
        var rng = GKMersenneTwisterRandomSource(seed: 42)
        let descriptions = [
            "Foo",
            "Bar",
            "Bat",
            "Baz",
            "Fizz",
            "Pop"
        ]
        let startDate = ISO8601DateFormatter().date(from: "2022-10-09")
        
        for index in 0...25 {
            let description = descriptions[rng.nextInt(upperBound: descriptions.count)]
            let amount = 100.0 * Double(rng.nextUniform())
            let date = Calendar.current.date(
                byAdding: Calendar.Component.day,
                value: -index * rng.nextInt(upperBound: 5),
                to: Date.now)!
            
            sampleTransactions.append(Transaction(
                amount: amount,
                date: date,
                description: description
            ))
        }
        
        return sampleTransactions.sorted(by: { $0.date > $1.date })
    }()
}
