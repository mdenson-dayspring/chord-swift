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
            let c = nB - nA
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
            try stack.push(Int(c))
        } else {
            throw LError.notInteger
        }
    }
    func floor(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 1)
        let a = try stack.pop()
        if let rA = a.toDouble() {
            let c: Double = rA.rounded(.down)
            try stack.push(Int(c))
        } else {
            throw LError.notInteger
        }
    }    
    func round(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 1)
        let a = try stack.pop()
        if let rA = a.toDouble() {
            let c: Double = rA.rounded(.toNearestOrAwayFromZero)
            try stack.push(Int(c))
        } else {
            throw LError.notInteger
        }
    }    
    func truncate(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 1)
        let a = try stack.pop()
        if let rA = a.toDouble() {
            let c: Double = rA.rounded(.towardZero)
            try stack.push(Int(c))
        } else {
            throw LError.notNumber
        }
    }

    func _cos(_: ObjectType) throws -> () {
        // angle -- real Return cosine of angle degrees
        try stack.testUnderflow(n: 1)
        if let a = try stack.pop().toDouble() {
            try stack.push(cos(a * Double.pi / 180.0))
        } else {
            throw LError.notNumber
        }
    }
    func _sin(_: ObjectType) throws -> () {
        // angle -- real Return sine of angle degrees
        try stack.testUnderflow(n: 1)
        if let a = try stack.pop().toDouble() {
            try stack.push(sin(a * Double.pi / 180.0))
        } else {
            throw LError.notNumber
        }
    }
    func _tan(_: ObjectType) throws -> () {
        // angle -- real Return tangent of angle degrees
        try stack.testUnderflow(n: 1)
        if let a = try stack.pop().toDouble() {
            try stack.push(tan(a * Double.pi / 180.0))
        } else {
            throw LError.notNumber
        }
    }
    func _acos(_: ObjectType) throws -> () {
        // num denom -- angle Return arccosine of num/den in degrees
        try stack.testUnderflow(n: 2)
        if let denom = try stack.pop().toDouble(),
           let num = try stack.pop().toDouble() {
            if denom == 0.0 {
                throw LError.runtimeError("divide by zero")
            }
            try stack.push(acos(num / denom) * 180.0 / Double.pi)
        } else {
            throw LError.notNumber
        }
    }
    func _asin(_: ObjectType) throws -> () {
        // num denom -- angle Return arcsine of num/den in degrees
        try stack.testUnderflow(n: 2)
        if let denom = try stack.pop().toDouble(),
           let num = try stack.pop().toDouble() {
            if denom == 0.0 {
                throw LError.runtimeError("divide by zero")
            }
            try stack.push(asin(num / denom) * 180.0 / Double.pi)
        } else {
            throw LError.notNumber
        }
    }
    func _atan(_: ObjectType) throws -> () {
        // num denom -- angle Return arctangent of num/den in degrees
        try stack.testUnderflow(n: 2)
        if let denom = try stack.pop().toDouble(),
           let num = try stack.pop().toDouble() {
            if denom == 0.0 {
                throw LError.runtimeError("divide by zero")
            }
            try stack.push(atan(num / denom) * 180.0 / Double.pi)
        } else {
            throw LError.notNumber
        }
    }
    func _exp(_: ObjectType) throws -> () {
        // base exponent -- real Raise base to exponent power
        try stack.testUnderflow(n: 2)
        let e = try stack.pop()
        let b = try stack.pop()
        if let exponent = e.toInt(),
           let base = b.toInt() {
            try stack.push(Int(pow(Double(base), Double(exponent))))
        } else if let exponent = e.toDouble(),
           let base = b.toDouble() {
            try stack.push(pow(base, exponent))
        } else {
            throw LError.notNumber
        }
    }
    func _ln(_: ObjectType) throws -> () {
        // num -- real Return natural logarithm (base e)
        try stack.testUnderflow(n: 1)
        if let a = try stack.pop().toDouble() {
            try stack.push(log(a))
        } else {
            throw LError.notNumber
        }
    }
    func _log(_: ObjectType) throws -> () {
        // num -- real Return common logarithm (base 10)
        try stack.testUnderflow(n: 1)
        if let a = try stack.pop().toDouble() {
            try stack.push(log10(a))
        } else {
            throw LError.notNumber
        }
    }
    
    func _rand(_: ObjectType) throws -> () {
        //  -- int Generate pseudo-random integer
        try stack.push(Int(arc4random_uniform(UInt32.max)))
    }
    
    func addMathNativeBuiltins() {
        words.append(contentsOf: [
            DictEntry(word: NameType("+"), native: add),
            DictEntry(word: NameType("-"), native: sub),
            DictEntry(word: NameType("*"), native: mul),
            DictEntry(word: NameType("/"), native: div),
            
            DictEntry(word: NameType("mod"), native: mod),
            DictEntry(word: NameType("/int"), native: idiv),
            DictEntry(word: NameType("/mod"), native: divmod),

            DictEntry(word: NameType("abs"), native: _abs),
            DictEntry(word: NameType("neg"), native: neg),
            DictEntry(word: NameType("ceiling"), native: ceiling),
            DictEntry(word: NameType("floor"), native: floor),
            DictEntry(word: NameType("round"), native: round),
            DictEntry(word: NameType("truncate"), native: truncate),            
            
            DictEntry(word: NameType("cos"), native: _cos),
            DictEntry(word: NameType("sin"), native: _sin),
            DictEntry(word: NameType("tan"), native: _tan),
            DictEntry(word: NameType("acos"), native: _acos),
            DictEntry(word: NameType("asin"), native: _asin),
            DictEntry(word: NameType("atan"), native: _atan),
            DictEntry(word: NameType("exp"), native: _exp),
            DictEntry(word: NameType("ln"), native: _ln),
            DictEntry(word: NameType("log"), native: _log),
            
            DictEntry(word: NameType("rand"), native: _rand),
        ])
    }
    func compileMathBuiltins() {
        interpret(source: """
        `sq {dup *} def
        `sqrt {0.5 exp} def
        """)
    }
}
