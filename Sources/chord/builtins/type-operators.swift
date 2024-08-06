import Foundation

extension Chord {
    func pushType(_: ObjectType) throws -> () {
        // any -- type
        try stack.testUnderflow(n: 1)
        let a = try stack.pop()
        try stack.push(a.type)
    }
    
    func addTypeOperators(dict: DictionaryType) {
        dict.putAll(operators: [
            OperatorType(word: NameType("type"), native: pushType),
        ])
    }
}
