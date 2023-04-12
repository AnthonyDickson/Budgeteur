//
//  NetWorthCategoryDetail.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 12/04/23.
//

import SwiftUI

struct NetWorthCategoryDetail: View {
    let title: String
    let description: String
    let items: [Asset]
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Label("Description", systemImage: "info.circle")
                    .labelStyle(.iconOnly)
                    .foregroundColor(.accentColor)
                    
                Text(description)
                    .font(.body)
            }
            .padding()
            
            List {
                ForEach(items) { item in
                    HStack {
                        Text(item.description)
                        Spacer()
                        Text(Currency.format(item.value))
                    }
                }
                
                HStack {
                    Text("Total: ")
                    Spacer()
                    Text(Currency.format(items.sum(\.value)))
                }
                .bold()
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    
                } label: {
                    Label("Add new \(title.lowercased())", systemImage: "plus")
                }
            }
        }
    }
}

struct NetWorthCategoryDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NetWorthCategoryDetail(title: "Liquid Assets", description: Assets.liquidAssetDescription, items: Assets.preview.liquidAssets)
        }
    }
}
