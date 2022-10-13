//
//  TagSelector.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 11/10/22.
//

import SwiftUI


/// Displays categories as a scrollable, horizontal list of categories and an edit button.
struct CategorySelector: View {
    @Binding var categories: [UserCategory]
    /// The category the user has tapped on.
    @Binding var selectedCategory: UserCategory?
    
    /// The width of the button borders.
    var lineWidth = 1.0
    
    /// The radius of the button borders.
    var cornerRadius = 5.0
    
    /// The dash style for the edit category button.
    var dashStyle: [CGFloat] = [5.0, 3.0]
    
    /// Whether to display the sheet with the form to add, edit and delete categories.
    @State private var showCategoryEditor: Bool = false
    
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
    
    /// Scrolls the scroll view to a category's button.
    ///
    /// If the user has not selected a category, this function has no effect.
    /// - Parameters:
    ///   - category: The category the user selected, can be nil.
    ///   - proxy: The `ScrollViewProxy` object to use for scrolling.
    private func scrollTo(_ category: UserCategory?, using proxy: ScrollViewProxy) {
        if let categoryId = selectedCategory?.id {
            withAnimation {
                proxy.scrollTo(categoryId, anchor: .trailing)
            }
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(categories) { category in
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
                        .id(category.id)
                    }
                    
                    Button {
                        showCategoryEditor = true
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
                }
                .padding(.horizontal)
                .onAppear {
                    // The async call is needed here so the animation happens after the view is rendered.
                    DispatchQueue.main.async {
                        scrollTo(selectedCategory, using: proxy)
                    }
                }
            }
            .sheet(isPresented: $showCategoryEditor) {
                // TODO: When a tag is updated, update all transactions that use new tag.
                // Even though the parent views are generally embeded in a navigation stack,
                // we have to add another one here to ensure the toolbar shows. Why?
                NavigationStack {
                    CategoryEditor(categories: $categories)
                        .environment(\.editMode, .constant(EditMode.active))
                        .navigationTitle("Edit Categories")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing){
                                Button("Done") {
                                    showCategoryEditor = false
                                    scrollTo(selectedCategory, using: proxy)
                                }
                            }
                        }
                }
            }
        }
    }
}


struct CategorySelector_Previews: PreviewProvider {
    static var previews: some View {
        Stateful(initialState: nil) { $userTag in
            CategorySelector(categories: .constant(DataModel().categories),
                             selectedCategory: $userTag)
        }
    }
}
