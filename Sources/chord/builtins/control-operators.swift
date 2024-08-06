import Foundation

extension Chord {
    func branch(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 2)
        if let procTrue = try stack.pop() as? ArrayType,
           let a = try stack.pop() as? Bool {
            if a {
                try execute(proc: procTrue)
            }
        } else {
            throw LError.runtimeError("Bad parameter")
        }
    }
    
    func branchElse(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 3)
        if let procFalse = try stack.pop() as? ArrayType,
           let procTrue = try stack.pop() as? ArrayType,
           let a = try stack.pop() as? Bool {
            if a {
                try execute(proc: procTrue)
            } else {
                try execute(proc: procFalse)
            }
        } else {
            throw LError.runtimeError("Bad parameter")
        }
    }
    
    func loopFor(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 4)
        if let proc = try stack.pop() as? ArrayType,
           let limit = try stack.pop().toDouble(),
           let increment = try stack.pop().toDouble(),
           let initial = try stack.pop().toDouble() {
            var integers = false
            if (limit.rounded() == limit && increment.rounded() == increment) {
                integers = true
            }
            var i = initial
            while (i <= limit && increment > 0) ||
                    (i >= limit && increment < 0) {
                if integers {
                    try stack.push(Int(i.rounded()))
                } else {
                    try stack.push(i)
                }
                try execute(proc: proc)
                i += increment
            }
        } else {
            throw LError.runtimeError("Bad parameter")
        }
    }
    
    func execWord(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 1)
        let o = try stack.pop()
        try execute(o)
    }
    
    func repl(_: ObjectType) throws -> () {
        print("Chord Version 0.9.2")
        print("Copyright © 2024 Matthew Denson")
        print("All rights reserved")
        printPrompt()
        while let line = readLine() {
            c.interpret(source: line)
            printPrompt()
        }
        print("")
        print("bye")
    }
    
    func startDefault(_: ObjectType) throws -> () {

    }
    
    func bind(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 1)
        guard let proc = try stack.pop() as? ArrayType, proc.isExecutable else {
            throw LError.typecheck
        }
        
        try stack.push(try bind(proc))
    }

    func bind(_ proc: ArrayType) throws -> ArrayType {
        var p = 0
        while p < proc.count {
            if let n = proc.get(p) as? NameType, n.isExecutable,
                let op = try dictionaryStack.load(key: n) as? OperatorType {
                proc.setPtr(ndx: p, element: op)
            } else if let inner = proc.get(p) as? ArrayType, inner.isExecutable {
                proc.setPtr(ndx: p, element: try bind(inner))
            }
            p += 1
        }
        return proc
    }
    func printPrompt() {
        if debugStack {
            c.printStack()
        } else if debugTop {
            c.printTop()
        }
        print("chord> ", terminator: "")
    }
    
    func addControlOperators(dict: DictionaryType) {
        dict.putAll(operators: [
            OperatorType(word: NameType("if"), native: branch),
            OperatorType(word: NameType("ifelse"), native: branchElse),
            OperatorType(word: NameType("for"), native: loopFor),
            OperatorType(word: NameType("exec"), native: execWord),
            OperatorType(word: NameType("bind"), native: bind),
            OperatorType(word: NameType("executive"), native: repl),
            OperatorType(word: NameType("start"), native: startDefault),
        ])
    }
}
