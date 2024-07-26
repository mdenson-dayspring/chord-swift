import Foundation

class StringType: ObjectType, CustomStringConvertible, Sequence {
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
    
    var isExecutable: Bool {
        get { return false }
        set(newValue) { }
    }
    
    func toDouble() -> Double? { return nil }    
    func toInt() -> Int? { return nil }
    
    var description: String {
        var ret = "("
        ret += value.description
        ret += ")"
        return ret
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
}
