//
//  TransactionListByDay.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 26/11/22.
//

import SwiftUI


/// A list of transactions, grouped by date interval and then day.
struct TransactionListByDay: View {
    /// The selected date interval to group transactions by.
    var period: Period
    /// 
    var predicate: NSPredicate?
    
    @Environment(\.managedObjectContext) private var context
    
    private var startDate: Date {
        let request = Transaction.fetchRequest()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: true)]
        
        let transaction = try? context.fetch(request)
        
        return transaction?.first?.date ?? Date.now
    }
    
    var body: some View {
        ForEach(period.getDateIntervals(from: startDate).reversed(), id: \.hashValue) { dateInterval in
            TransactionGroup(dateInterval: dateInterval, period: period, predicate: predicate)
        }
    }
}

struct TransactionListByDay_Previews: PreviewProvider {
    static var dataManager: DataManager = .init(inMemory: true)
    
    static var previews: some View {
        List {
            TransactionListByDay(period: .oneWeek)
        }
        .environment(\.managedObjectContext, dataManager.context)
        .onAppear {
            dataManager.addSampleData()
        }
    }
}
