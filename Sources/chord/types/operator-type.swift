import Foundation

class OperatorType: ObjectType, CustomStringConvertible
{
    let name: NameType
    let native: (_: ObjectType) throws -> ()
    var def: ObjectType = NullType.NULL
    let immediate: Bool
    
    init(word: NameType, native: @escaping (_: ObjectType) throws -> (), def: ObjectType = NullType.NULL, immediate: Bool = false) {
        self.name = word
        self.native = native
        self.def = def
        self.immediate = immediate
    }
    
    var type: NameType {
        get { return NameType("operatortype")}
    }
    var isExecutable: Bool {
        get { return false }
        set(newValue) { }
    }
    func toDouble() -> Double? { return nil }
    func toInt() -> Int? { return nil }
    var valueAsString: StringType {
        get { return StringType(string: "--nostringtype--")}
    }
    var valueAsSyntaxString: StringType {
        get { return StringType(string: "op_\(name.stringValue)")}
    }
    public var description: String {
        return valueAsSyntaxString.stringValue
    }
}

