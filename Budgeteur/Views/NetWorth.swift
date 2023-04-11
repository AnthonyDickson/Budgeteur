//
//  NetWorth.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 10/04/23.
//

import SwiftUI


struct NetWorth: View {
    var assets: Assets
    var liabilities: Liabilities
    
    var netWorth: Double {
        assets.total - liabilities.total
    }
    
    /// A measure of one's ability to cover short-term liabilities with liquid assets.
    var shortTermLiquidity: Double {
        assets.totalLiquid - liabilities.shortTermTotal
    }
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    var assetsTable: some View {
        VStack {
            Text("Assets")
                .font(.title)
            
            Grid(alignment: .leading) {
                GridRow {
                    Text("Description")
                    Text("Value")
                        .gridColumnAlignment(.trailing)
                }
                .font(.headline)
                .foregroundColor(.accentColor)
                
                GridRow {
                    Text("Liquid Assets: ")
                    Text(Currency.formatAsInt(assets.totalLiquid))
                }
                
                GridRow {
                    Text("Large and Fixed Assets: ")
                    Text(Currency.formatAsInt(assets.totalFixed))
                }
                
                GridRow {
                    Text("Personal Items: ")
                    Text(Currency.formatAsInt(assets.totalPersonalItems))
                }
                
                Divider()
                
                GridRow {
                    Text("Total Assets: ")
                    Text(Currency.formatAsInt(assets.total))
                }
                .bold()
            }
        }
        .padding()
    }
    
    var liabilitiesTable: some View {
        VStack {
            Text("Liabilities")
                .font(.title)
            
            
            Grid(alignment: .leading) {
                GridRow {
                    Text("Description")
                    Text("Value")
                        .gridColumnAlignment(.trailing)
                }
                .font(.headline)
                .foregroundColor(.accentColor)
                
                GridRow {
                    Text("Short Term Liabilities: ")
                    Text(Currency.formatAsInt(liabilities.shortTermTotal))
                }
                
                GridRow {
                    Text("Long Term Liabilities: ")
                    Text(Currency.formatAsInt(liabilities.longTermTotal))
                }
                
                Divider()
                
                GridRow {
                    Text("Total Liabilities: ")
                    Text(Currency.formatAsInt(liabilities.total))
                }
                .bold()
            }
            .padding()
        }
    }
    
    var body: some View {
        VStack {
            // TODO: Add navigation links to table rows that shows list of items for the category and allows them to be edited.
            // TODO: Integrate assets and liabilities records into CoreData store.
            if sizeClass == .compact {
                assetsTable
                liabilitiesTable
            } else {
                // TODO: Fix heading rows not lining up due to liabilities table having one less row.
                HStack {
                    assetsTable
                    Spacer()
                    liabilitiesTable
                }
            }
            
            Text("Net Worth: \(Currency.formatAsInt(netWorth))")
                .font(.title)
            Text("Short-Term Liquity: \(Currency.formatAsInt(shortTermLiquidity))")
        }
    }
}

struct NetWorth_Previews: PreviewProvider {
    static var previews: some View {
        let previewDevices = [
            "iPhone 14 Pro",
            "iPad mini (6th generation)"
        ]
        
        ForEach(previewDevices, id: \.description) { previewDevice in
            NetWorth(assets: Assets.preview, liabilities: Liabilities.preview)
                .environment(\.managedObjectContext, DataManager.preview.context)
                .environmentObject(DataManager.preview)
                .previewDisplayName(previewDevice)
                .previewDevice(.init(rawValue: previewDevice))
        }
    }
}
