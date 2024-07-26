import Foundation
extension Chord {
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
            DictEntry(word: NameType("print"),  native: popPrintString),
            DictEntry(word: NameType("="),  native: popPrint),
            DictEntry(word: NameType("=="),  native: popPrintSyntax),
            DictEntry(word: NameType("stack"), native: printStack),
            DictEntry(word: NameType("pstack"), native: printStack),
        ])
    }
}
