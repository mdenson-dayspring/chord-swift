import Foundation

extension Chord {
    func newArray(_: ObjectType) throws -> () {
        // int -- array
        try stack.testUnderflow(n: 1)
        if let n = try stack.pop().toInt() {
            try stack.push(ArrayType(size: n))
        }
    }

    func buildArrayToMark(_: ObjectType) throws -> () {
        // `mark` n1 n2 -- [/n1, /n2]
        // [ 1 2 add ] --> [3]
        // mark 5 4 3 counttomark array astore exch pop
        let count = stack.count(to: MarkType.MARK)
        if count > -1 {
            let a = ArrayType(size: count)
            for n in 1...count {
                a.setPtr(ndx: count - n, element: try stack.pop())
            }
            let _ = try stack.pop()
            try stack.push(a)
        }
    }
    
    func arrayLength(_: ObjectType) throws -> () {
        // array -- int
        try stack.testUnderflow(n: 1)
        if let a = try stack.pop() as? ArrayType {
            
            try stack.push(a.count)
        } else {
            throw LError.runtimeError("Bad parameter")
        }
    }
    
    func arrayGet(_: ObjectType) throws -> () {
        // array index -- any
        try stack.testUnderflow(n: 2)
        if let n = try stack.pop().toInt(),
           let a = try stack.pop() as? ArrayType {
            
            try stack.push(a.get(n))
        } else {
            throw LError.runtimeError("Bad parameter")
        }
    }
    
    func arrayPut(_: ObjectType) throws -> () {
        // array index any --
        try stack.testUnderflow(n: 3)
        let element = try stack.pop()
        if let n = try stack.pop().toInt(),
           let a = try stack.pop() as? ArrayType {
            
            a.setPtr(ndx: n, element: element)
        } else {
            throw LError.runtimeError("Bad parameter")
        }
    }
    
    func storeArray(_: ObjectType) throws -> () {
        // any0 ... anyn−1 array  -- array
        try stack.testUnderflow(n: 1)
        if let a = try stack.pop() as? ArrayType {
            try stack.testUnderflow(n: a.count)
            let count = a.count
            for n in 1...count {
                a.setPtr(ndx: count - n, element: try stack.pop())
            }
            try stack.push(a)
        }
    }

    func loadArray(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 1)
        if let a = try stack.pop() as? ArrayType {
            for el in a {
                try stack.push(el)
            }
            try stack.push(a)
        } else {
            throw LError.runtimeError("Bad parameter")
        }
    }
    
    func forallArray(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 2)
        if let proc = try stack.pop() as? ArrayType,
            let a = try stack.pop() as? ArrayType {
            for el in a {
                try stack.push(el)
                try execute(proc: proc)
            }
        } else {
            throw LError.runtimeError("Bad parameter")
        }
    }
    
    func addArrayNativeBuiltins() {
        words.append(contentsOf: [
            DictEntry(word: NameType("array"), native: newArray),
            DictEntry(word: NameType("["), native: mark),
            DictEntry(word: NameType("]"), native: buildArrayToMark),
            DictEntry(word: NameType("length"), native: arrayLength),
            DictEntry(word: NameType("get"), native: arrayGet),
            DictEntry(word: NameType("put"), native: arrayPut),
            DictEntry(word: NameType("astore"), native: storeArray),
            DictEntry(word: NameType("aload"), native: loadArray),
            DictEntry(word: NameType("forall"), native: forallArray),
        ])
    }
}
