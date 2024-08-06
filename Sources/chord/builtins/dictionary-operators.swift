import Foundation

extension Chord {
    func defWord(_: ObjectType) throws -> () {
        try stack.testUnderflow(n: 2)
        let v = try stack.pop()
        let NameType = try stack.pop()
        if let n = NameType as? NameType {
            dictionaryStack.put(key: n, value: v)
        } else {
            throw LError.runtimeError("Unexpected parameter type")
        }
    }

    func addDictionaryOperators(dict: DictionaryType) {
        dict.putAll(operators: [
            OperatorType(word: NameType("def"), native: defWord),
        ])
    }
}
