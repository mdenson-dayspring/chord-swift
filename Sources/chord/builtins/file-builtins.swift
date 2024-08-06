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
    
    func addFileNativeBuiltins() {
        words.append(contentsOf: [
            DictEntry(word: NameType("run"),  native: runFile),
            DictEntry(word: NameType("print"),  native: popPrintString),
            DictEntry(word: NameType("="),  native: popPrint),
            DictEntry(word: NameType("=="),  native: popPrintSyntax),
            DictEntry(word: NameType("stack"), native: printStack),
            DictEntry(word: NameType("pstack"), native: printStack),
        ])
    }
}
