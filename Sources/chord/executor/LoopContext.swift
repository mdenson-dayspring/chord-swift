//
//  File.swift
//  
//
//  Created by Matthew Denson on 8/23/24.
//

import Foundation
class LoopContext: ExecContext {
    override public var description: String {
        return "LC: oops"
    }
}

class ForLoopContext: LoopContext {
    let initial: Double;
    let increment: Double;
    let limit: Double;
    let loopProc: ArrayType
    let integers: Bool
    var current: Double
    var firstTime: Bool
    
    init(context: Chord, initial: Double, increment: Double, limit: Double, proc: ArrayType) {
        self.initial = initial
        self.increment = increment
        self.limit = limit
        self.loopProc = proc
        
        if (limit.rounded() == limit && increment.rounded() == increment) {
            integers = true
        } else {
            integers = false
        }
        firstTime = true
        current = initial
        
        super.init(context: context, object: NullType.NULL)
    }
    
    override func step() throws -> ObjectType? {
        if firstTime {
            firstTime = false
        } else {
            current += increment
        }

        if (current <= limit && increment > 0) ||
            (current >= limit && increment < 0) {
            if integers {
                try chord.stack.push(Int(current.rounded()))
            } else {
                try chord.stack.push(current)
            }
            
            try execute(loopProc)
            return nil
        } else {
            return NullType.NULL
        }
    }
    
    override public var description: String {
        return "FLC: \(current) \(initial) \(increment) \(limit)"
    }
}

class ForAllLoopContext: LoopContext {
    let array: ArrayType;
    let loopProc: ArrayType
    var current: Int
    
    init(context: Chord, array: ArrayType, proc: ArrayType) {
        self.array = array
        self.loopProc = proc

        current = -1
        
        super.init(context: context, object: NullType.NULL)
    }
    
    override func step() throws -> ObjectType? {
        current += 1

        if (current < array.count) {
            try chord.stack.push(array.get(current))
            
            try execute(loopProc)
            return nil
        } else {
            return NullType.NULL
        }
    }
    
    override public var description: String {
        return "FALC: \(current) \(array.count)"
    }
}
