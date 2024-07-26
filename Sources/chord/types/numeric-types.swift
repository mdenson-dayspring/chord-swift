import Foundation

extension Int: ObjectType {
    var type: NameType {
        get { return NameType("integertype")}
    }
    var isExecutable: Bool {
        get { return false }
        set(newValue) { }
    }
    func toDouble() -> Double? {
        return Double(self)
    }
    func toInt() -> Int? {
        return self
    }
    
    var valueAsString: StringType {
        get { return StringType(string: "\(self)")}
    }
    var valueAsSyntaxString: StringType {
        get { return valueAsString}
    }
}

extension Double: ObjectType {
    var type: NameType {
        get { return NameType("realtype")}
    }
    var isExecutable: Bool {
        get { return false }
        set(newValue) { }
    }
    func toDouble() -> Double? {
        return self
    }
    func toInt() -> Int? {
        return nil
    }
    
    var valueAsString: StringType {
        get { return StringType(string: "\(self)")}
    }
    var valueAsSyntaxString: StringType {
        get { return valueAsString}
    }
}
