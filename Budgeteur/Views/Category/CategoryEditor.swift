//
//  CategoryEditor.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 11/10/22.
//

import SwiftUI

/// Displays the user defined categories in a list and allows the user to add, edit and delete categories.
///
/// The parent view should ensure that the environment variable `editMode` is set to `EditMode.active`.
struct CategoryEditor: View {
    /// The list of user defined categories.
    @Binding var categories: [UserCategory]
    
    /// The name that will be used to create a new category.
    @State private var newCategoryName = ""
    
    var body: some View {
        List {
            TextField("Add a new category!", text: $newCategoryName)
                .submitLabel(.done)
                .onSubmit {
                    categories.append(UserCategory(name: newCategoryName))
                    newCategoryName = ""
                }
            
            ForEach($categories) { $category in
                TextField(category.name, text: $category.name)
            }
            .onDelete { categoryIndices in
                categories.remove(atOffsets: categoryIndices)
            }
            .onMove { sourceIndices, destination in
                categories.move(fromOffsets: sourceIndices, toOffset: destination)
            }
        }
    }
}

struct CategoryEditor_Previews: PreviewProvider {
    static var previews: some View {
        CategoryEditor(categories: .constant(DataModel().categories))
            .environment(\.editMode, .constant(EditMode.active))
    }
}
