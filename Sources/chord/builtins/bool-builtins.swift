import Foundation

extension Chord {
    func _eq(_: ObjectType) throws -> () {
        // any any -- bool
        try stack.testUnderflow(n: 2)
        let rhs = try stack.pop()
        let lhs = try stack.pop()
        
        if let rhsint = rhs.toInt(),
           let lhsint = lhs.toInt() {
            try stack.push(rhsint == lhsint)
        } else if let rhsv = rhs.toDouble(),
                  let lhsv = lhs.toDouble() {
            try stack.push(rhsv == lhsv)
        } else if let rhsv = rhs as? StringType,
                  let lhsv = lhs as? StringType {
            try stack.push(rhsv == lhsv)
        } else {
            throw LError.typecheck
        }
    }
    func _ne(_: ObjectType) throws -> () {
        // any any -- bool
        try stack.testUnderflow(n: 2)
        let rhs = try stack.pop()
        let lhs = try stack.pop()
        
        if let rhsint = rhs.toInt(),
           let lhsint = lhs.toInt() {
            try stack.push(lhsint != rhsint)
        } else if let rhsv = rhs.toDouble(),
                  let lhsv = lhs.toDouble() {
            try stack.push(lhsv != rhsv)
        } else if let rhsv = rhs as? StringType,
                  let lhsv = lhs as? StringType {
            try stack.push(lhsv != rhsv)
        } else {
            throw LError.typecheck
        }

    }
    func _ge(_: ObjectType) throws -> () {
        // num|str num|str -- bool
        try stack.testUnderflow(n: 2)
        let rhs = try stack.pop()
        let lhs = try stack.pop()
        
        if let rhsint = rhs.toInt(),
           let lhsint = lhs.toInt() {
            try stack.push(lhsint >= rhsint)
        } else if let rhsv = rhs.toDouble(),
                  let lhsv = lhs.toDouble() {
            try stack.push(lhsv >= rhsv)
        } else if let rhsv = rhs as? StringType,
                  let lhsv = lhs as? StringType {
            try stack.push(lhsv >= rhsv)
        } else {
            throw LError.typecheck
        }
    }
    func _gt(_: ObjectType) throws -> () {
        // num|str num|str -- bool
        try stack.testUnderflow(n: 2)
        let rhs = try stack.pop()
        let lhs = try stack.pop()
        
        if let rhsint = rhs.toInt(),
           let lhsint = lhs.toInt() {
            try stack.push(lhsint > rhsint)
        } else if let rhsv = rhs.toDouble(),
                  let lhsv = lhs.toDouble() {
            try stack.push(lhsv > rhsv)
        } else if let rhsv = rhs as? StringType,
                  let lhsv = lhs as? StringType {
            try stack.push(lhsv > rhsv)
        } else {
            throw LError.typecheck
        }
    }
    func _le(_: ObjectType) throws -> () {
        // num|str num|str -- bool
        try stack.testUnderflow(n: 2)
        let rhs = try stack.pop()
        let lhs = try stack.pop()
        
        if let rhsint = rhs.toInt(),
           let lhsint = lhs.toInt() {
            try stack.push(lhsint <= rhsint)
        } else if let rhsv = rhs.toDouble(),
                  let lhsv = lhs.toDouble() {
            try stack.push(lhsv <= rhsv)
        } else if let rhsv = rhs as? StringType,
                  let lhsv = lhs as? StringType {
            try stack.push(lhsv <= rhsv)
        } else {
            throw LError.typecheck
        }

    }
    func _lt(_: ObjectType) throws -> () {
        // num|str num|str -- bool
        try stack.testUnderflow(n: 2)
        let rhs = try stack.pop()
        let lhs = try stack.pop()
        
        if let rhsint = rhs.toInt(),
           let lhsint = lhs.toInt() {
            try stack.push(lhsint < rhsint)
        } else if let rhsv = rhs.toDouble(),
                  let lhsv = lhs.toDouble() {
            try stack.push(lhsv < rhsv)
        } else if let rhsv = rhs as? StringType,
                  let lhsv = lhs as? StringType {
            try stack.push(lhsv < rhsv)
        } else {
            throw LError.typecheck
        }
    }
    
    func _and(_: ObjectType) throws -> () {
        // bool|int bool|int -- bool
        try stack.testUnderflow(n: 2)
        let rhs = try stack.pop()
        let lhs = try stack.pop()
        
        if let rhsbool = rhs as? Bool,
           let lhsbool = lhs as? Bool {
            try stack.push(lhsbool && rhsbool)
        } else if let rhsint = rhs.toInt(),
                  let lhsint = lhs.toInt() {
            try stack.push(rhsint & lhsint)
        } else {
            throw LError.typecheck
        }
    }
    func _not(_: ObjectType) throws -> () {
        // bool|int -- bool
        try stack.testUnderflow(n: 1)
        let val = try stack.pop()
        
        if let valbool = val as? Bool {
            try stack.push(!valbool)
        } else if let valint = val.toInt() {
            try stack.push(~valint)
        } else {
            throw LError.typecheck
        }
    }
    func _or(_: ObjectType) throws -> () {
        // bool|int bool|int -- bool
        try stack.testUnderflow(n: 2)
        let rhs = try stack.pop()
        let lhs = try stack.pop()
        
        if let rhsbool = rhs as? Bool,
           let lhsbool = lhs as? Bool {
            try stack.push(lhsbool || rhsbool)
        } else if let rhsint = rhs.toInt(),
                  let lhsint = lhs.toInt() {
            try stack.push(rhsint | lhsint)
        } else {
            throw LError.typecheck
        }
    }
    func _xor(_: ObjectType) throws -> () {
        // bool|int bool|int -- bool
        try stack.testUnderflow(n: 2)
        let rhs = try stack.pop()
        let lhs = try stack.pop()
        
        if let rhsbool = rhs as? Bool,
           let lhsbool = lhs as? Bool {
            try stack.push(!(lhsbool != rhsbool))
        } else if let rhsint = rhs.toInt(),
                  let lhsint = lhs.toInt() {
            try stack.push(rhsint ^ lhsint)
        } else {
            throw LError.typecheck
        }
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
