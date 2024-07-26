import Foundation

class NameType: ObjectType, Equatable, CustomStringConvertible
{
    let id: String
    init(_ id: String) {
        self.id = id
    }
    
    var type: NameType {
        get { return NameType("nametype")}
    }
    var executable = false
    var isExecutable: Bool {
        get { return executable }
        set(newValue) { executable = newValue }
    }
    func toDouble() -> Double? { return nil }
    func toInt() -> Int? { return nil }
    static func == (lhs: NameType, rhs: NameType) -> Bool {
        return lhs.id == rhs.id
    }
    
    var valueAsString: StringType {
        get { return StringType(string: "\(id)") }
    }
    var valueAsSyntaxString: StringType {
        get { return StringType(string: "`\(id)") }
    }

    public var description: String {
        return valueAsSyntaxString.stringValue
    }
}
