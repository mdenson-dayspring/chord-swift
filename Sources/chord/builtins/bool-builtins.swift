import Foundation

extension Chord {
    func _eq(_: ObjectType) throws -> () {
        // any any -- bool
        try stack.testUnderflow(n: 2)
        let rhs = try stack.pop()
        let lhs = try stack.pop()
        
        try stack.push(true)
    }
    func _ne(_: ObjectType) throws -> () {
        // any any -- bool
        try stack.testUnderflow(n: 2)

        try stack.push(true)
    }
    func _ge(_: ObjectType) throws -> () {
        // any any -- bool
        try stack.testUnderflow(n: 2)

        try stack.push(true)
    }
    func _gt(_: ObjectType) throws -> () {
        // any any -- bool
        try stack.testUnderflow(n: 2)

        try stack.push(true)
    }
    func _le(_: ObjectType) throws -> () {
        // any any -- bool
        try stack.testUnderflow(n: 2)

        try stack.push(true)
    }
    func _lt(_: ObjectType) throws -> () {
        // any any -- bool
        try stack.testUnderflow(n: 2)

        try stack.push(true)
    }
    func _and(_: ObjectType) throws -> () {
        // any any -- bool
        try stack.testUnderflow(n: 2)

        try stack.push(true)
    }
    func _not(_: ObjectType) throws -> () {
        // any any -- bool
        try stack.testUnderflow(n: 1)

        try stack.push(true)
    }
    func _or(_: ObjectType) throws -> () {
        // any any -- bool
        try stack.testUnderflow(n: 2)

        try stack.push(true)
    }
    func _xor(_: ObjectType) throws -> () {
        // any any -- bool
        try stack.testUnderflow(n: 2)

        try stack.push(true)
    }

    func _true(_: ObjectType) throws -> () {
        //  -- true
        try stack.push(true)
    }
    func _false(_: ObjectType) throws -> () {
        //  -- false
        try stack.push(false)
    }
    
    func addBoolNativeBuiltins() {
        words.append(contentsOf: [
            DictEntry(word: NameType("eq"), native: _eq),
            DictEntry(word: NameType("ne"), native: _ne),
            DictEntry(word: NameType("ge"), native: _ge),
            DictEntry(word: NameType("gt"), native: _gt),
            DictEntry(word: NameType("le"), native: _le),
            DictEntry(word: NameType("lt"), native: _lt),

            DictEntry(word: NameType("and"), native: _and),
            DictEntry(word: NameType("not"), native: _not),
            DictEntry(word: NameType("or"), native: _or),
            DictEntry(word: NameType("xor"), native: _xor),

            DictEntry(word: NameType("true"), native: _true),
            DictEntry(word: NameType("false"), native: _false),

            DictEntry(word: NameType("true"), native: _true),
            DictEntry(word: NameType("false"), native: _false),
        ])
    }
    func compileBoolBuiltins() {
        interpret(source: """

        """)
    }
}
