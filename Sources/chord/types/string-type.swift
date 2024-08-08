import Foundation

class StringType: ObjectType, CustomStringConvertible, Sequence, Equatable, Comparable {
    var value: String
    
    init() {
        value = ""
    }
    init(string: String) {
        value = string
    }
    
    var type: NameType {
        get { return NameType("srringtype") }
    }
    
    var executable = false
    var isExecutable: Bool {
        get { return executable }
        set(newValue) { executable = newValue }
    }
    
    func toDouble() -> Double? { return nil }
    func toInt() -> Int? { return nil }
    
    var description: String {
        return valueAsSyntaxString.stringValue
    }
    
    func makeIterator() -> String.Iterator {
        return value.makeIterator()
    }
    var valueAsString: StringType {
        get { return self}
    }
    var valueAsSyntaxString: StringType {
        get {
            var ret = "("
            ret += value.description
            ret += ")"
            return StringType(string: ret)
        }
    }
    var stringValue: String {
        return value
    }
    
    static func < (lhs: StringType, rhs: StringType) -> Bool {
        lhs.value < rhs.value
    }
    static func == (lhs: StringType, rhs: StringType) -> Bool {
        lhs.value == rhs.value
    }
}
