//
//  Budget_Overview_Widget.swift
//  Budget Overview Widget
//
//  Created by Anthony Dickson on 7/01/23.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> BudgetOverviewEntry {
        BudgetOverviewEntry(date: .now, period: .oneWeek, income: 1000, expenses: 800)
    }

    func getSnapshot(in context: Context, completion: @escaping (BudgetOverviewEntry) -> ()) {
        if context.isPreview {
            let entry = BudgetOverviewEntry(date: .now, period: .oneWeek, income: 1000, expenses: 800)
            completion(entry)
        } else {
            let entry = BudgetOverviewEntry.from(date: .now)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = BudgetOverviewEntry.from(date: .now)
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!

        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct BudgetOverviewEntry: TimelineEntry {
    let date: Date
    let period: Period
    let income: Double
    let expenses: Double
    
    var underBudget: Bool {
        expenses < income
    }
    
    var percentBudget: Double {
        guard income > 0.0 else {
            return 0.0
        }
        
        guard expenses > 0.0 else {
            return 1.0
        }
        
        return expenses / income
    }
    
    var percentUnder: Double {
        percentBudget < 1.0 ? 1.0 - percentBudget : 1.0
    }
    
    var percentOver: Double {
        max(0.0, percentBudget - 1.0)
    }
    
    var absoluteBudget: Double {
        return abs(income - expenses)
    }
    
    static func from(date: Date) -> BudgetOverviewEntry {
        let period: Period = .oneWeek
        let dateInterval = period.getDateInterval(for: date)
        let request = Transaction.fetchRequest()
        request.predicate = Transaction.getPredicateForAllTransactions(in: dateInterval)
        let transactions = (try? DataManager().context.fetch(request)) ?? []
        let transactionSet = TransactionSet.fromTransactions(transactions, in: dateInterval, groupBy: period)
        
        let entry = BudgetOverviewEntry(date: date, period: period, income: transactionSet.sumIncomeLessSavings, expenses: transactionSet.sumExpenses)
        
        return entry
    }
}

struct Budget_Overview_WidgetEntryView : View {
    var entry: Provider.Entry
    
    /// Whether the user's device has light or dark mode enabled.
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    var colour: Color {
        if entry.underBudget {
            return colorScheme == .light ? .moneyGreen : .moneyGreenDarker
        } else {
            return colorScheme == .light ? .grapefruitRed : .bloodOrange
        }
    }
    
    var backgroundBrightness: Double {
        colorScheme == .light ?  0.2 : 0.1
    }
    
    var foregroundHeight: CGFloat {
        entry.underBudget ? 166 * entry.percentUnder : 166
    }
    
    var foreground: some View {
        VStack {
            Spacer()
            Rectangle()
                .frame(height: foregroundHeight)
                .foregroundColor(colour)
        }
    }
    
    var background: some View {
        colour
            .brightness(backgroundBrightness)
    }
    
    var percentUnderOverText: String {
        let percentFormat = FloatingPointFormatStyle<Double>.Percent().precision(.fractionLength(0))
        
        if entry.underBudget {
            return "\(entry.percentUnder.formatted(percentFormat)) remaining"
        } else {
            return "\(entry.percentOver.formatted(percentFormat)) over"
        }
    }
    
    var underOverText: String {
        entry.underBudget ? "under" : "over"
    }

    var body: some View {
        ZStack(alignment: .leading) {
           foreground
            VStack(alignment: .leading) {
                Text(Currency.formatAsWhole(entry.absoluteBudget))
                    .font(.title)
                Text("\(underOverText) \(entry.period.contextLabel)")
                    .font(.callout)
                Spacer()
                Text(percentUnderOverText)
                    .font(.callout)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background)
    }
}

struct Budget_Overview_Widget: Widget {
    let kind: String = "Budget_Overview_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Budget_Overview_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct Budget_Overview_Widget_Previews: PreviewProvider {
    static var previews: some View {
        let entryUnder = BudgetOverviewEntry(date: .now, period: .oneWeek, income: 100, expenses: 31)
        let entryOver = BudgetOverviewEntry(date: .now, period: .oneWeek, income: 100, expenses: 169)
        
        Budget_Overview_WidgetEntryView(entry: entryUnder)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("Widget Under Budget")
        
        Budget_Overview_WidgetEntryView(entry: entryOver)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("Widget Over Budget")
    }
}
