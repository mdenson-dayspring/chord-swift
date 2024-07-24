import Foundation

extension Chord {
    func add(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 2)
        let a = try stack.pop()
        let b = try stack.pop()
        if let nA = a.toInt(), let nB = b.toInt() {
            let c = nA + nB
            try stack.push(c)
        } else if let rA = a.toDouble(), let rB = b.toDouble() {
            let c = rA + rB
            try stack.push(c)
        } else {
            throw LError.notNumber
        }
    }
    func sub(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 2)
        let a = try stack.pop()
        let b = try stack.pop()
        if let nA = a.toInt(), let nB = b.toInt() {
            let c = nB + nA
            try stack.push(c)
        } else if let rA = a.toDouble(), let rB = b.toDouble() {
            let c = rB - rA
            try stack.push(c)
        } else {
            throw LError.notNumber
        }
    }
    func mul(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 2)
        let a = try stack.pop()
        let b = try stack.pop()
        if let nA = a.toInt(), let nB = b.toInt() {
            let c = nA * nB
            try stack.push(c)
        } else if let rA = a.toDouble(), let rB = b.toDouble() {
            let c: Double = rB * rA
            try stack.push(c)
        } else {
            throw LError.notInteger
        }
    }
    func div(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 2)
        let a = try stack.pop()
        let b = try stack.pop()
        if let nA = a.toInt(), let nB = b.toInt() {
            let q: Double = Double(nB) / Double(nA)
            if q == q.rounded(.towardZero) {
                try stack.push(Int(q))
            } else {
                try stack.push(q)
            }
        } else if let rA = a.toDouble(), let rB = b.toDouble() {
            let q: Double = rB / rA
            try stack.push(q)
        } else {
            throw LError.notInteger
        }
    }
    func idiv(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 2)
        let a = try stack.pop()
        let b = try stack.pop()
        if let nA = a.toInt(), let nB = b.toInt() {
            let q: Double = (Double(nB) / Double(nA)).rounded(.towardZero)
            try stack.push(Int(q))
        } else {
            throw LError.notInteger
        }
    }
    func mod(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 2)
        let a = try stack.pop()
        let b = try stack.pop()
        if let nA = a.toInt(), let nB = b.toInt() {
            let r = nB % nA
            try stack.push(r)
        } else {
            throw LError.notInteger
        }
    }
    func divmod(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 2)
        let a = try stack.pop()
        let b = try stack.pop()
        if let nA = a.toInt(), let nB = b.toInt() {
            let q: Double = (Double(nB) / Double(nA)).rounded(.towardZero)
            let r = nB % nA
            try stack.push(r)
            try stack.push(Int(q))
        } else {
            throw LError.notInteger
        }
    }
    
    func _abs(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 1)
        let a = try stack.pop()
        if let nA = a.toInt() {
            let c = abs(nA)
            try stack.push(c)
        } else if let rA = a.toDouble() {
            let c: Double = abs(rA)
            try stack.push(c)
        } else {
            throw LError.notInteger
        }
    }
    func neg(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 1)
        let a = try stack.pop()
        if let nA = a.toInt() {
            let c = -nA
            try stack.push(c)
        } else if let rA = a.toDouble() {
            let c: Double = -rA
            try stack.push(c)
        } else {
            throw LError.notInteger
        }
    }
    func ceiling(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 1)
        let a = try stack.pop()
        if let rA = a.toDouble() {
            let c: Double = rA.rounded(.up)
            try stack.push(c)
        } else {
            throw LError.notInteger
        }
    }
    func floor(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 1)
        let a = try stack.pop()
        if let rA = a.toDouble() {
            let c: Double = rA.rounded(.down)
            try stack.push(c)
        } else {
            throw LError.notInteger
        }
    }    
    func round(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 1)
        let a = try stack.pop()
        if let rA = a.toDouble() {
            let c: Double = rA.rounded(.toNearestOrAwayFromZero)
            try stack.push(c)
        } else {
            throw LError.notInteger
        }
    }    
    func truncate(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 1)
        let a = try stack.pop()
        if let rA = a.toDouble() {
            let c: Double = rA.rounded(.towardZero)
            try stack.push(c)
        } else {
            throw LError.notNumber
        }
    }
    
    func addMathNativeBuiltins() {
        words.append(contentsOf: [
            DictEntry(word: NameType("add"), native: add),
            DictEntry(word: NameType("sub"), native: sub),
            DictEntry(word: NameType("mul"), native: mul),
            DictEntry(word: NameType("div"), native: div),
            
            DictEntry(word: NameType("idiv"), native: idiv),
            DictEntry(word: NameType("mod"), native: mod),
            DictEntry(word: NameType("/mod"), native: divmod),
            
            DictEntry(word: NameType("abs"), native: _abs),
            DictEntry(word: NameType("neg"), native: neg),
            DictEntry(word: NameType("ceiling"), native: ceiling),
            DictEntry(word: NameType("floor"), native: floor),
            DictEntry(word: NameType("round"), native: round),
            DictEntry(word: NameType("truncate"), native: truncate),
        ])
    }
    func compileMathBuiltins() {
        interpret(source: """
        /sq {dup mul} def
        """)
    }
}
