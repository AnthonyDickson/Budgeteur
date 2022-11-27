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
    /// The name that will be used to create a new category.
    @State private var newCategoryName = ""
    
    /// The list of user defined categories.
    @FetchRequest(sortDescriptors: [SortDescriptor(\UserCategory.name, order: .forward)]) private var categories: FetchedResults<UserCategory>
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var dataManager: DataManager
    
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
                        TextField(category.name, text: Binding<String>(get: { category.name}, set: { category.name = $0 }))
                    }
                    .onDelete { categoryIndices in
                        categoryIndices.map{ categories[$0] }.forEach { category in
                            context.delete(category)
                        }
                    }
                }
            }
        }
        .navigationTitle("Edit Tags")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction){
                Button("Cancel", role: .cancel) {
                    context.rollback()
                    dismiss()
                }
                .foregroundColor(.red)
            }
            ToolbarItem(placement: .primaryAction){
                Button("Save") {
                    dataManager.save()
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
        m.save()
        
        return m
    }()
    
    static var previews: some View {
        NavigationStack {
            CategoryEditor()
                .environmentObject(dataManager)
            .environment(\.managedObjectContext, dataManager.context)
        }
    }
}
