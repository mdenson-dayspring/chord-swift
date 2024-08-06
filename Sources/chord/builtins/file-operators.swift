import Foundation
extension Chord {
    func runFile(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 1)
        if let f = try stack.pop() as? StringType {
            do {
                let text2 = try String(contentsOfFile: f.stringValue, encoding: .utf8)
                interpret(source: text2)
            }
            catch {
                throw LError.runtimeError("ioerror: \(error)")
            }
        } else {
            throw LError.typecheck
        }
    }
    func popPrintString(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 1)
        if let str = try stack.pop() as? StringType {
            print(str.stringValue, terminator: "")
        } else {
            throw LError.typecheck
        }
    }
    func popPrint(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 1)
        let a = try stack.pop()
        print(a.valueAsString.stringValue)
    }
    func popPrintSyntax(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 1)
        let a = try stack.pop()
        print(a.valueAsSyntaxString.stringValue)
    }
    func printStack(_: ObjectType) throws -> () {
        try stack.printStack()
    }
    
    func addFileOperators(dict: DictionaryType) {
        dict.putAll(operators: [
            OperatorType(word: NameType("run"),  native: runFile),
            OperatorType(word: NameType("print"),  native: popPrintString),
            OperatorType(word: NameType("="),  native: popPrint),
            OperatorType(word: NameType("=="),  native: popPrintSyntax),
            OperatorType(word: NameType("stack"), native: printStack),
            OperatorType(word: NameType("pstack"), native: printStack),
        ])
    }
}
