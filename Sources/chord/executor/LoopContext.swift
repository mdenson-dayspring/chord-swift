//
//  File.swift
//  
//
//  Created by Matthew Denson on 8/23/24.
//

import Foundation
class LoopContext: ExecContext {
    let loopProc: ArrayType
    
    init(context: Chord, proc: ArrayType) {
        self.loopProc = proc
        
        super.init(context: context, object: NullType.NULL)
    }
    
    override var isFinished: Bool {
        get {
            return false
        }
    }

    override func step() throws {
        try execute(object: loopProc)
    }
    
    override public var description: String {
        return "LC"
    }
}

class ForLoopContext: LoopContext {
    let initial: Double;
    let increment: Double;
    let limit: Double;
    let integers: Bool
    var current: Double
    var firstTime: Bool
    
    init(context: Chord, initial: Double, increment: Double, limit: Double, proc: ArrayType) {
        self.initial = initial
        self.increment = increment
        self.limit = limit
        
        if (limit.rounded() == limit && increment.rounded() == increment) {
            integers = true
        } else {
            integers = false
        }
        firstTime = true
        current = initial
        
        super.init(context: context, proc: proc)
    }
    
    override var isFinished: Bool {
        get {
            return !((current <= limit && increment > 0) ||
                (current >= limit && increment < 0))
        }
    }
    
    override func step() throws {
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
            
            try execute(object: loopProc)
        }
    }
    
    override public var description: String {
        return "FLC: \(current) \(initial) \(increment) \(limit)"
    }
}

class ForAllLoopContext: LoopContext {
    let array: ArrayType;
    var current: Int
    
    init(context: Chord, array: ArrayType, proc: ArrayType) {
        self.array = array

        current = -1
        
        super.init(context: context, proc: proc)
    }
    
    override var isFinished: Bool {
        get {
            return !(current < array.count)
        }
    }

    override func step() throws {
        current += 1

        if current < array.count {
            try chord.stack.push(array.get(current))
            
            try execute(object: loopProc)
        }
    }
    
    override public var description: String {
        return "FALC: \(current) \(array.count)"
    }
}

class RepeatLoopContext: LoopContext {
    var current: Int
    
    init(context: Chord, count: Int, proc: ArrayType) {
        current = count
        
        super.init(context: context, proc: proc)
    }
    
    override var isFinished: Bool {
        get {
            return !(current >= 0)
        }
    }

    override func step() throws {
        current -= 1

        if current >= 0 {
            try execute(object: loopProc)
        }
    }
    
    override public var description: String {
        return "RLC: \(current)"
    }
}
