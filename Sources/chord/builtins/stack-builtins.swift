import Foundation

extension Chord {
    func pop(_: ObjectType) throws -> () {
        // ( n1 -- )
        try stack.testUnderflow(n: 1)
        _ = try stack.pop()
    }
    func exch(_: ObjectType) throws -> () {
        // ( n1 n2 -- n2 n1 )
        try stack.testUnderflow(n: 2)
        let n2 = try stack.pop()
        let n1 = try stack.pop()
        try stack.push(n2)
        try stack.push(n1)
    }
    func dup(_: ObjectType) throws -> () {
        // ( n1 -- n1 n1 )
        try stack.testUnderflow(n: 1)
        let n1 = try stack.pop()
        try stack.push(n1)
        try stack.push(n1)
    }
    func copy(_: ObjectType) throws -> () {
        // ( /n1 ... /nn n -- /n1 ... /nn /n1 ... /nn )
        try stack.testUnderflow(n: 1)
        if let n = try stack.pop().toInt() {
            try stack.testUnderflow(n: n)
            let a = ArrayType()
            for _ in 1...n {
                let e = try stack.pop()
                a.append(e)
            }
            for i in 1...n {
                try stack.push(a.get(n - i))
            }
            for i in 1...n {
                try stack.push(a.get(n - i))
            }
        } else {
            throw LError.runtimeError("bad paramaters")
        }
    }
    func index(_: ObjectType) throws -> () {
        // ( nn ... n0 n -- nn ... n0 nn )
        try stack.testUnderflow(n: 1)
        if let n = try stack.pop().toInt() {
            try stack.testUnderflow(n: n + 1)
            let a = ArrayType()
            for _ in 0...n {
                let e = try stack.pop()
                a.append(e)
            }
            for i in 0...n {
                try stack.push(a.get(n - i))
            }
            try stack.push(a.get(n))
        } else {
            throw LError.runtimeError("bad paramaters")
        }
    }
    func roll(_: ObjectType) throws -> () {
        // /a /b /c 3 -1 roll -- /b /c /a
        // /a /b /c 3  1 roll -- /c /a /b
        try stack.testUnderflow(n: 2)
        if let j = try stack.pop().toInt(),
           let n = try stack.pop().toInt(), n >= 0 {
            try stack.testUnderflow(n: n)
            if j != 0 {
                let a = ArrayType()
                for _ in 1...n {
                    let e = try stack.pop()
                    a.append(e)
                }
                for i in 1...n {
                    var p = (j - i + n) % n
                    if p < 0 { p += n }
                    try stack.push(a.get(p))
                }
            }
        } else {
            throw LError.runtimeError("bad paramaters")
        }
    }

    func clear(_: ObjectType) throws -> () {
        // ( n1 ... nn -- )
        stack.clear()
    }
    func count(_: ObjectType) throws -> () {
        // ( n1 ... nn -- n1 ... nn n )
        try stack.push(stack.count)
    }
    func mark(_: ObjectType) throws -> () {
        // ( -- `mark` )
        try stack.push(MarkType.MARK)
    }
    func cleartomark(_: ObjectType) throws -> () {
        // ( `mark` n1 ... nn -- )
        while stack.count > 0 {
            let e = try stack.pop()
            if let _ = e as? MarkType {
                break
            }
        }
    }
    func counttomark(_: ObjectType) throws -> () {
        // ( `mark` n1 ... nn -- `mark` n1 ... nn n )
        try stack.push(stack.count(to: MarkType.MARK))
    }
    
    func addStackNativeBuiltins() {
        words.append(contentsOf: [
            DictEntry(word: NameType("pop"), native: pop),
            DictEntry(word: NameType("exch"), native: exch),
            DictEntry(word: NameType("dup"), native: dup),
            
            DictEntry(word: NameType("copy"), native: copy),
            DictEntry(word: NameType("index"), native: index),
            DictEntry(word: NameType("roll"), native: roll),

            DictEntry(word: NameType("clear"), native: clear),
            DictEntry(word: NameType("count"), native: count),
            DictEntry(word: NameType("mark"), native: mark),
            DictEntry(word: NameType("cleartomark"), native: cleartomark),
            DictEntry(word: NameType("counttomark"), native: counttomark),

        ])
    }
    func compileStackBuiltins() {
        interpret(source: """
        `drop { pop } def
        `swap { exch } def
        `rot { 3 -1 roll } def
        `over { 1 index } def
        """)
    }
}
