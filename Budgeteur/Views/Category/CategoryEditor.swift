//
//  CategoryEditor.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 25/11/22.
//

import SwiftUI


/// Displays the user defined categories in a list and allows the user to add, edit and delete categories.
///
/// The parent view should ensure that the environment variable `editMode` is set to `EditMode.active`.
struct CategoryEditor: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @EnvironmentObject private var dataManager: DataManager
    /// The list of user defined categories.
    @FetchRequest(sortDescriptors: [SortDescriptor(\UserCategory.name, order: .forward)]) private var categories: FetchedResults<UserCategory>
    
    /// The name that will be used to create a new category.
    @State private var newCategoryName = ""
    
    private func createCategoryAndReset() {
        if !newCategoryName.isEmpty {
            _ = dataManager.createUserCategory(name: newCategoryName)
            newCategoryName = ""
        }
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    TextField("Tag Name", text: $newCategoryName)
                        .submitLabel(.done)
                        .onSubmit(createCategoryAndReset)
                    
                    Spacer()
                    
                    Button("Add") {
                        createCategoryAndReset()
                    }
                    .disabled(newCategoryName.isEmpty)
                }
            }
            
            Section {
                if categories.isEmpty {
                    Text("No Tags")
                } else {
                    ForEach(categories) { category in
                        Text(category.name)
                        // TODO: Make categories editable
        //                TextField(category.name, text: $category.name)
                    }
                    .onDelete { categoryIndices in
                        DispatchQueue.main.async {
                            categoryIndices.map{ categories[$0] }.forEach { category in
                                dataManager.deleteUserCategory(category: category)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Edit Tags")
        .navigationBarTitleDisplayMode(.inline)
        // TODO: When editing, make sure we are only editing a temporary copy, and to only save the changes once the users taps save.
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading){
//                Button("Cancel", role: .cancel) {
//                    dismiss()
//                }
//                .foregroundColor(.red)
//            }
//            ToolbarItem(placement: .navigationBarTrailing){
//                Button("Save") {
//                    dismiss()
//                }
//            }
//        }
        .toolbar {
            ToolbarItem(placement: .primaryAction){
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

struct CategoryEditor_Previews: PreviewProvider {
    static var dataManager: DataManager = {
        let m: DataManager = .init(inMemory: true)
        
        _ = m.createUserCategory(name: "Foo")
        _ = m.createUserCategory(name: "Bar")
        
        return m
    }()
    
    static var previews: some View {
        CategoryEditor()
            .environmentObject(dataManager)
            .environment(\.managedObjectContext, dataManager.context)
    }
}
