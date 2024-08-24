import Foundation

class Chord {
    let interpVersion = "0.9.4"
    var stack: Stack<ObjectType> = Stack<ObjectType>()
    var dictionaryStack: DictionaryType = DictionaryType()
    var executionStack: ExecutionStack = ExecutionStack()
    
    init(_ arguments: String) {
        executionStack.chord = self
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
    
    func interpret(source: String) {
        let src = StringType(string: source)
        src.isExecutable = true
        executionStack.execute(src)
        executionStack.runLoop()
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


