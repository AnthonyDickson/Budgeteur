//
//  Budget_Overview_Widget.swift
//  Budget Overview Widget
//
//  Created by Anthony Dickson on 7/01/23.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
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
}

struct Budget_Overview_WidgetEntryView : View {
    var entry: Provider.Entry
    
    /// Whether the user's device has light or dark mode enabled.
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    static let previewEntry: BudgetOverviewEntry = BudgetOverviewEntry(date: .now, period: .oneWeek, income: 100, expenses: 31)
    
    var colour: Color {
        if Self.previewEntry.underBudget {
            return colorScheme == .light ? .moneyGreen : .moneyGreenDarker
        } else {
            return colorScheme == .light ? .grapefruitRed : .bloodOrange
        }
    }
    
    var backgroundBrightness: Double {
        colorScheme == .light ?  0.2 : 0.1
    }
    
    var foregroundHeight: CGFloat {
        Self.previewEntry.underBudget ? 165 * Self.previewEntry.percentUnder : 165
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
        
        if Self.previewEntry.underBudget {
            return "\(Self.previewEntry.percentUnder.formatted(percentFormat)) remaining"
        } else {
            return "\(Self.previewEntry.percentOver.formatted(percentFormat)) over"
        }
    }
    
    var underOverText: String {
        Self.previewEntry.underBudget ? "under" : "over"
    }

    var body: some View {
        ZStack(alignment: .leading) {
           foreground
            VStack(alignment: .leading) {
                Text(Currency.formatAsWhole(Self.previewEntry.absoluteBudget))
                    .font(.title)
                Text("\(underOverText) \(Self.previewEntry.period.contextLabel)")
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
        Budget_Overview_WidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
