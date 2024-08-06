import Foundation

class Chord {
    var stack: Stack<ObjectType> = Stack<ObjectType>()
    var dictionaryStack: DictionaryType = DictionaryType()
    
    init(_ arguments: String) {
        dictionaryStack.putAll(operators: [
            OperatorType(word: NameType("{"), native: startCompile, immediate: true),
            OperatorType(word: NameType("}"), native: finishCompile, immediate: true),
        ])
        addBoolOperators(dict: dictionaryStack)
        addDictionaryOperators(dict: dictionaryStack)
        addControlOperators(dict: dictionaryStack)
        addStackOperators(dict: dictionaryStack)
        addMathOperators(dict: dictionaryStack)
        addTypeOperators(dict: dictionaryStack)
        addFileOperators(dict: dictionaryStack)
        addArrayOperators(dict: dictionaryStack)
        
        compileBoolBuiltins()
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
        let topFrame: Scanner = Scanner(source: source)
        
        while lex(token: topFrame.scanToken(), scanner: topFrame) != 1 { }
    }
    
    func lex(token: String, scanner: Scanner) -> Int {
        do {
            if token == Scanner.EOF {
                return 1
            } else if token == "#" {
                scanner.scanComment()
            } else if token == "`" {
                // todo validate next token as a name
                let value = NameType(scanner.scanToken())
                if let w = compileDef {
                    // push literal integer (compile)
                    w.append(value)
                } else {
                    // push literal integer (immediate)
                    try stack.push(value)
                }
            } else if token == "(" {
                let value = StringType(string: scanner.scanString())
                if let w = compileDef {
                    // push literal string (compile)
                    w.append(value)
                } else {
                    // push literal string (immediate)
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
    
    func execute(_ obj: ObjectType) throws -> () {
        if let op = obj as? OperatorType {
            try op.native(op.def)
        } else if let name = obj as? NameType, name.isExecutable  {
            try execute(name: name)
        } else if let array = obj as? ArrayType, array.isExecutable  {
            try execute(proc: array)
        } else {
            try stack.push(obj)
        }
    }
    
    func execute(name: NameType) throws -> () {
        let value = try dictionaryStack.load(key: name)
        if let op = value as? OperatorType {
            if !op.immediate, let w = compileDef {
                name.isExecutable = true
                w.append(name)
            } else {
                try execute(value)
            }
        } else {
            // interpret word (immediate)
            try execute(value)
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
}


