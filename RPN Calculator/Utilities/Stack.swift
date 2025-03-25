//
//  Stack.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 07/03/25.
//

import Foundation

struct Stack<T> {
    var items: [T] = []
    
    mutating func push(_ element: T) {
        items.append(element)
    }
    
    mutating func pop() -> T? {
        items.popLast()
    }
    
    var peek: T? {
        items.last
    }
    
    var isEmpty: Bool {
        items.isEmpty
    }
}
