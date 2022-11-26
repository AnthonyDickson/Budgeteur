//
//  Sequence.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 26/11/22.
//

import Foundation

extension Sequence {
    /// Take the sum of an attribute of the elements in a sequence.
    /// - Parameter keypath: The key path of the attribute to sum.
    /// - Returns: The sum of the attribute.
    func sum(_ keypath: KeyPath<Element, Double>) -> Double {
        return reduce(0.0, { $0 + $1[keyPath: keypath] })
    }
}
