import Foundation

class Chord {
    var stack: Stack<ObjectType> = Stack<ObjectType>()
    var words: [DictEntry] = []
    
    init(_ arguments: String) {
        words = [
            DictEntry(word: NameType("def"), native: defWord),
            DictEntry(word: NameType("{"), native: startCompile, immediate: true),
            DictEntry(word: NameType("}"), native: finishCompile, immediate: true),
        ]
        addControlNativeBuiltins()
        addStackNativeBuiltins()
        addMathNativeBuiltins()
        addTypeNativeBuiltins()
        addArrayNativeBuiltins()
        
        compileStackBuiltins()
        compileMathBuiltins()
        
        interpret(source: arguments)
    }
    
    func printStack() {
        do {
            try stack.printStack()
        } catch {
            print("! ", terminator: "")
        }
    }
    func printTop() {
        if let top = stack.top() {
            print("\(top) ", terminator: "")
        } else {
            print("- ", terminator: "")
        }
    }
    func interpret(source: String) {
        let topFrame: Parser = Parser(source: source)
        
        while lex(token: topFrame.scanToken(), parser: topFrame) != 1 { }
    }
    
    func lex(token: String, parser: Parser) -> Int {
        do {
            if token == Parser.EOF {
                return 1
            } else if token == "#" {
                parser.scanComment()
            } else if token == "/" {
                // todo validate next token as a name
                let value = NameType(parser.scanToken())
                if let w = compileDef {
                    // push literal integer (compile)
                    w.append(value)
                } else {
                    // push literal integer (immediate)
                    try stack.push(value)
                }
            } else if let value = token.integer {
                if let w = compileDef {
                    // push literal integer (compile)
                    w.append(value)
                } else {
                    // push literal integer (immediate)
                    try stack.push(value)
                }
            } else if let value = token.double {
                if let w = compileDef {
                    // push literal double (compile)
                    w.append(value)
                } else {
                    // push literal integer (immediate)
                    try stack.push(value)
                }
            } else {
                // execute word
                try execute(name: NameType(token))
            }
        } catch LError.runtimeError(let errorMessage) {
            print(errorMessage)
        } catch LError.notNumber {
            print("expected a number")
        } catch LError.notInteger {
            print("expected an integer")
        } catch {
            print("unexpected error")
        }
        return 0
    }
    
    func findWordIndex(_ token: NameType) -> Int {
        for p in 1...words.count{
            if words[words.count - p].word == token {
                return words.count - p
            }
        }
        return -1
    }
    
    func execute(_ obj: ObjectType) throws -> () {
        if let name = obj as? NameType, name.isExecutable  {
            try execute(name: name)
        } else if let array = obj as? ArrayType, array.isExecutable  {
            try execute(proc: array)
        } else {
            try stack.push(obj)
        }
    }
    
    func execute(name: NameType) throws -> () {
        let wordIndex = findWordIndex(name)
        if wordIndex >= 0 {
            let nextWord = words[wordIndex]
            if !nextWord.immediate, let w = compileDef {
                if let _ = nextWord.def as? NullType {
                    // compile call to word
                    name.isExecutable = true
                    w.append(name)
                } else if let array = nextWord.def as? ArrayType, array.isExecutable  {
                    // inline compile word
                    w.append(contentsOf: array)
                } else {
                    // insert word to get current value (not closure)
                    w.append(name)
                }
            } else {
                // interpret word (immediate)
                let w = words[wordIndex]
                try w.native(w.def)
            }
        } else {
            print("unknown word: \(name)")
        }
    }
    
    func execute(proc: ArrayType) throws -> () {
        var p = 0
        while p < proc.count {
            if let _ = proc.get(p) as? ArrayType {
                // special handling to keep executable arrays
                //  from executing when executing an array of objects
                try stack.push(proc.get(p))
            } else {
                try execute(proc.get(p))
            }
            p += 1
        }
    }
    
    var condStack: Stack<Int> = Stack<Int>()
    var contextStack: Stack<ArrayType> = Stack<ArrayType>()
    var compileDef: ArrayType?
    func startCompile(_: ObjectType) throws -> () {
        if let def = compileDef {
            try contextStack.push(def)
        }
        compileDef = ArrayType()
        compileDef?.isExecutable = true
    }
    func finishCompile(_: ObjectType) throws -> () {
        if let def = compileDef {
            if contextStack.count > 0 {
                let prev = try contextStack.pop()
                prev.append(def)
                compileDef = prev
            } else {
                try stack.push(def)
                compileDef = nil
            }
        }
    }
    func defWord(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 2)
        let v = try stack.pop()
        let NameType = try stack.pop()
        if let n = NameType as? NameType {
            let word = DictEntry(word: n, native: execute, def: v)
            words.append(contentsOf: [word])
        } else {
            throw LError.runtimeError("Unexpected parameter type")
        }
    }
}

class DictEntry {
    let word: NameType
    let native: (_: ObjectType) throws -> ()
    var def: ObjectType = NullType.NULL
    let immediate: Bool
    
    init(word: NameType, native: @escaping (_: ObjectType) throws -> (), def: ObjectType = NullType.NULL, immediate: Bool = false) {
        self.word = word
        self.native = native
        self.def = def
        self.immediate = immediate
    }
}

