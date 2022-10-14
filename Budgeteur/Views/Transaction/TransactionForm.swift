//
//  TransactionForm.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 10/10/22.
//

import SwiftUI

extension Color {
    static let moneyGreen = Color(red: 0.49, green: 0.96, blue: 0.49)
    static let moneyGreenDarker = Color(red: 0.38, green: 0.72, blue: 0.38)
}

extension View {
    func dismissKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}

/// A form for creating a new transaction. Features a big keypad.
struct TransactionForm: View {
    /// The app data.
    @ObservedObject var data: DataModel
    
    /// A description of the transaction.
    @State var description = ""
    /// The amount of money spent.
    @State var amount = 0.0
    /// When the transaction occured.
    @State var date = Date.now
    /// The ID of the category the transaction fits into (e.g., groceries vs. entertainment).
    @State var categoryID: UUID? = nil
    
    /// Whether the user's device has light or dark mode enabled.
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    /// Whether to show the date/repitition controls.
    @State private var showDateControls = false
    @State private var repeatPeriod = RepeatPeriod.never
    
    /// Is the current amount invalid?
    private var invalidAmount: Bool {
        amount <= 0
    }
    
    /// The background color of the transaction amount. Reacts to whether dark mode is enabled.
    private var amountBackground: Color {
        colorScheme == .light ? Color.moneyGreen : Color.moneyGreenDarker
    }
    
    /// Add the transaction to the app's data.
    private func save() {
        let transaction = Transaction(amount: amount, description: description, date: date, categoryID: categoryID)
        data.addTransaction(transaction)
        reset()
    }
    
    /// Reset the inputs to their default values.
    private func reset() {
        withAnimation {
            description = ""
            amount = 0.0
            date = Date.now
            categoryID = nil
            repeatPeriod = .never
        }
    }
    
    /// Get the total amount of all transactions in the current time period (e.g. this week, this month).
    private func getTotalSpendingForTimePeriod() -> Double {
        let dateInterval = data.period.getDateInterval(for: Date.now)
        
        var sum = 0.0
        
        for transaction in data.transactions {
            if transaction.date > dateInterval.end {
                continue
            } else if transaction.date < dateInterval.start {
                break
            }
            sum += transaction.amount
        }
        
        return sum
    }
    
    /// Convert a time period to a context-aware label.
    private func getTimePeriodLabel() -> String {
        switch(data.period) {
        case .oneDay:
            return "today"
        case .oneWeek:
            return "this week"
        case .twoWeeks:
            return "this fortnight"
        case .oneMonth:
            return "this month"
        case .threeMonths:
            return "this quarter"
        case .oneYear:
            return "this year"
        }
    }
    
    /// A label with the total amount spent and the aggregation period.
    private func getSpendingSummary() -> String {
        "Spent \(Currency.format(getTotalSpendingForTimePeriod())) \(getTimePeriodLabel())"
    }
    
    var body: some View {
        // Need GeometryReader here to prevent the keyboard from moving the views (keyboard avoidance).
        GeometryReader { _ in
            VStack(alignment: .center) {
                ZStack {
                    Text(getSpendingSummary())
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            showDateControls = true
                        } label: {
                            Label("Change date and repetition.", systemImage: "ellipsis")
                                .labelStyle(.iconOnly)
                                .foregroundColor(.primary)
                        }
                        .sheet(isPresented: $showDateControls) {
                            Grid {
                                GridRow {
                                    Label("Date", systemImage: "calendar")
                                    Label("Repeat", systemImage: "repeat")
                                }
                                GridRow {
                                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                                        .labelsHidden()
                                        .padding(.bottom)
                                    Picker("Repeat", selection: $repeatPeriod) {
                                        ForEach(RepeatPeriod.allCases, id: \.rawValue) { period in
                                            Text(period.rawValue)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                            .padding(.top)
                            .presentationDetents([.medium, .height(128)])
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // TODO: Handle case where text overflows. Make text smaller?
                Text(Currency.format(amount))
                    .font(.title)
                    .bold()
                    .frame(maxWidth: 180, maxHeight: 110)
                    .padding()
                    .background(amountBackground)
                    .cornerRadius(10)
                
                Spacer()
                
                TextField("What did you pay for?", text: $description)
                    .submitLabel(.done)
                    .multilineTextAlignment(.center)
                    .padding()
                
                CategorySelector(categories: $data.categories, selectedCategory: $categoryID)
                
                Keypad(amount: $amount, onSave: save)
            }
        }
        // Tapping on anything other than the description textfield will dismiss the keyboard.
        .onTapGesture {
            dismissKeyboard()
        }
        // This stops the keyboard from pushing up the keypad view
        .ignoresSafeArea(.keyboard, edges: .all)
    }
}

struct TransactionForm_Previews: PreviewProvider {
    static var previews: some View {
        TransactionForm(data: DataModel())
    }
}
