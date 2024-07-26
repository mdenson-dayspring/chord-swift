import Foundation

protocol ObjectType: CustomStringConvertible
{
    var type: NameType {
        get
    }
    var isExecutable: Bool {
        get
        set
    }
    func toDouble() -> Double?
    func toInt() -> Int?
    var valueAsString: StringType {
        get
    }
    var valueAsSyntaxString: StringType {
        get
    }
}

class MarkType: ObjectType
{
    static let MARK = MarkType()
    var type: NameType {
        get { return NameType("marktype")}
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
        get { return StringType(string: "-mark-")}
    }
    public var description: String {
        return valueAsSyntaxString.stringValue
    }
}

class NullType: ObjectType, CustomStringConvertible
{
    static let NULL = NullType()
    var type: NameType {
        get { return NameType("nulltype")}
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
        get { return StringType(string: "-null-")}
    }
    public var description: String {
        return valueAsSyntaxString.stringValue
    }
}
