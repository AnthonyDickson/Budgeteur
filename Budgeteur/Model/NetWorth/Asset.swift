//
//  Asset.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 11/04/23.
//

import Foundation


struct Asset: Identifiable {
    let id = UUID()
    let description: String
    let value: Double
}

/// A collection of assets where each asset consists of a description and a cash value.
struct Assets {
    /// Things that can be quickly converted into cash or are cash equivalent, e.g., cash, savings, stocks.
    let liquidAssets: [Asset]
    /// Large and non-liquid things such as vehicles, houses.
    let fixedAssets: [Asset]
    /// Personal belongings such as phone, musical instruments, jewelry.
    let personalItems: [Asset]
    
    static let liquidAssetDescription = "Things that can be quickly converted into cash or are cash equivalent, e.g., cash, savings, stocks."
    static let fixedAssetDescription = "Large and non-liquid things such as vehicles, houses."
    static let personalItemDescription = "Personal belongings such as phone, musical instruments, jewelry."
    
    /// The total value of all liquid assets.
    var totalLiquid: Double {
        liquidAssets.sum(\.value)
    }
    
    /// The total value of all large and fixed assets.
    var totalFixed: Double {
        fixedAssets.sum(\.value)
    }
    
    /// The total value of all personal items.
    var totalPersonalItems: Double {
        personalItems.sum(\.value)
    }
    
    /// The total value of all assets.
    var total: Double {
        totalLiquid + totalFixed + totalPersonalItems
    }
    
    static var preview: Assets {
        Assets(
            liquidAssets: [Asset(description: "Savings", value: 12345.67), Asset(description: "Stocks", value: 3245.34)],
            fixedAssets: [Asset(description: "Car", value: 25000)],
            personalItems: [Asset(description: "iPhone", value: 2000)]
        )
    }
}
