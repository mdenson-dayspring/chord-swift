import Foundation

extension Chord {
    func pushType(_: ObjectType) throws -> () {
        // any -- type
        try stack.testUnderflow(n: 1)
        let a = try stack.pop()
        try stack.push(a.type)
    }
    
    func cvlit(_: ObjectType) throws -> () {
        // any -- any
        try stack.testUnderflow(n: 1)
        var a = try stack.pop()
        a.isExecutable = false
        try stack.push(a)
    }
    func cvx(_: ObjectType) throws -> () {
        // any -- any
        try stack.testUnderflow(n: 1)
        var a = try stack.pop()
        a.isExecutable = true
        try stack.push(a)
    }
    func xcheck(_: ObjectType) throws -> () {
        // any -- bool
        try stack.testUnderflow(n: 1)
        let a = try stack.pop()
        try stack.push(a.isExecutable)
    }
    
    func addTypeOperators(dict: DictionaryType) {
        dict.putAll(operators: [
            OperatorType(word: NameType("type"), native: pushType),
            OperatorType(word: NameType("cvlit"), native: cvlit),
            OperatorType(word: NameType("cvx"), native: cvx),
            OperatorType(word: NameType("xcheck"), native: xcheck),
        ])
    }
}
