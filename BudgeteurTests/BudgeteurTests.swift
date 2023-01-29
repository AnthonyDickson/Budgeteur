//
//  BudgeteurTests.swift
//  BudgeteurTests
//
//  Created by Anthony Dickson on 9/10/22.
//

import XCTest
@testable import Budgeteur

final class BudgeteurTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }    

    /// I should be able to initialise ``DataManager`` class in memory without it crashing.
    func testCanLoadMemoryStore() throws {
        XCTAssertNoThrow({ DataManager(inMemory: true) })
    }
    
    /// I should be able to initialise ``DataManager`` class from disk without it crashing.
    func testCanLoadDiskStore() throws {
        XCTAssertNoThrow({ DataManager() })
    }
    

    /// I should be able to initialise ``DataManager`` class with sample data without it crashing.
    func testCanLoadPreviewStore() throws {
        XCTAssertNoThrow({ DataManager.preview })
    }
    
    ///  Given the preview store, when I query the store, then there should be transactions and user categories.
    func testPreviewStoreHasData() throws {
        let dataManager = DataManager.preview
        
        let transactions = try! dataManager.context.fetch(Transaction.fetchRequest())
        let categories = try! dataManager.context.fetch(UserCategory.fetchRequest())
        
        XCTAssertGreaterThan(transactions.count, 0, "Expected at least one transaction, got \(transactions.count)")
        XCTAssertGreaterThan(categories.count, 0, "Expected at least one category, got \(categories.count)")
    }

    /// Given an empty store, when I create a new transaction, then I should be able to query the store for the same transaction.
    func testCanCreateTransaction() throws {
        let store = DataManager(inMemory: true)
        
        let transaction = Transaction(insertInto: store.context, amount: 42.0)
        
        let fetchedTransaction = try! store.context.fetch(Transaction.fetchRequest()).first
        
        XCTAssertNotNil(fetchedTransaction, "Added transaction to store, but when queried the store did not return any transactions.")
        XCTAssertEqual(transaction, fetchedTransaction!, "The fetched transaction did not match the original transaction.")
    }

    /// Given an empty store, when I create a new user category, then I should be able to query the store for the same category.
    func testCanCreateUserCategory() throws {
        let store = DataManager(inMemory: true)
        
        let category = UserCategory(insertInto: store.context, name: "A Category", type: .expense)
        
        let fetchtedCategory = try! store.context.fetch(UserCategory.fetchRequest()).first
        
        XCTAssertNotNil(fetchtedCategory, "Added user category to store, but when queried the store did not return any categories.")
        XCTAssertEqual(category, fetchtedCategory!, "The fetched user category did not match the original category.")
    }
}
