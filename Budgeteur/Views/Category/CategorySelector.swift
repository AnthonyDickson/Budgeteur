//
//  TagSelector.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 11/10/22.
//

import SwiftUI


/// Displays categories as a scrollable, horizontal list of categories and an edit button.
struct CategorySelector: View {
    /// The app data.
    @ObservedObject var data: DataModel
    /// The category the user has tapped on.
    @Binding var selectedCategory: UserCategory?
    
    /// The width of the button borders.
    var lineWidth = 1.0
    
    /// The radius of the button borders.
    var cornerRadius = 5.0
    
    /// The dash style for the edit category button.
    var dashStyle: [CGFloat] = [5.0, 3.0]
    
    /// Get the color for the category label.
    ///
    /// If no category has been selected by the user, all categories are given the same color.
    /// Otherwise, the selected category is highlighted and the other categories are grayed out.
    /// - Parameter category: The category that is to be displayed.
    /// - Returns: The saturation level for the given category's label.
    private func getColor(for category: UserCategory) -> Color {
        if selectedCategory == nil {
            return .primary
        } else if category == selectedCategory {
            return .purple
        } else {
            return .secondary
        }
    }
    
    /// Get the saturation for the category label.
    ///
    /// If a category has been selected by the user, then the saturation is reduced to 0.0 from 1.0.
    /// This is intended to make the selected category stand out by removing the color from emojis in the unselected categories.
    /// - Parameter category: The category that is to be displayed.
    /// - Returns: The saturation level for the given category's label.
    private func getSaturation(for category: UserCategory) -> Double {
        if selectedCategory == nil || category == selectedCategory {
            return 1.0
        } else {
            return 0.0
        }
    }
    
    ///  Sets ``selectedTag`` or removes the selection depending on the input category.
    /// - Parameter category: The category the user tapped on.
    private func updateSelectedTag(with category: UserCategory) {
        if category == selectedCategory {
            selectedCategory = nil
        } else {
            selectedCategory = category
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(data.categories) { category in
                    Button {
                        updateSelectedTag(with: category)
                    } label: {
                        Text(category.name)
                            .foregroundColor(getColor(for: category))
                            .saturation(getSaturation(for: category))
                            .padding()
                            .overlay {
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .strokeBorder(getColor(for: category), lineWidth: lineWidth)
                            }
                    }
                }
                
                Button {
                    // TODO: Show sheet with list of categories and controls to add a new category(s).
                } label: {
                    Text("Edit Tags")
                        .foregroundColor(.primary)
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .strokeBorder(style: StrokeStyle(lineWidth: lineWidth, dash: dashStyle))
                                .foregroundColor(.primary)
                        }
                }
                .disabled(true)
            }
            .padding(.horizontal)
        }
    }
}


struct CategorySelector_Previews: PreviewProvider {
    static var previews: some View {
        Stateful(initialState: nil) { $userTag in
            CategorySelector(data: DataModel(), selectedCategory: $userTag)
        }
    }
}
