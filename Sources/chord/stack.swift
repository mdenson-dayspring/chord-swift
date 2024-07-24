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

    public var description: String { return "`mark`" }
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
    public var description: String { return "null" }
}
class NameType: ObjectType, Equatable, CustomStringConvertible
{
    let id: String
    init(_ id: String) {
        self.id = id
    }
    
    var type: NameType {
        get { return NameType("NameTypetype")}
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
    public var description: String {
        if isExecutable {
            return "\(id)"
        } else {
            return "/\(id)"
        }
    }
}
class  ArrayType: ObjectType, CustomStringConvertible, Sequence
{
    var value: [ObjectType]
    var count: Int {
        get { return value.count }
    }
    var executable = false
    var isExecutable: Bool {
        get { return executable }
        set(newValue) { executable = newValue }
    }
    init() {
        value = []
    }
    init(size: Int) {
        value = []
        for _ in 1...size {
            value.append(NullType.NULL)
        }
    }
    func get(_ ndx: Int) -> ObjectType {
        return value[ndx]
    }
    func append(_ newElement: ObjectType) {
        value.append(newElement)
    }
    func append(contentsOf: ArrayType) {
        value.append(contentsOf: contentsOf.value)
    }
    func setPtr(ndx: Int, element: ObjectType) {
        value[ndx] = element
    }
    func lastWordPtr() -> Int {
        return (value.count - 1)
    }
    
    func makeIterator() -> IndexingIterator<Array<ObjectType>> {
        return value.makeIterator()
    }
    
    var type: NameType {
        get { return NameType("arraytype")}
    }
    func toDouble() -> Double? { return nil }
    func toInt() -> Int? { return nil }
    
    public var description: String {
        var ret = ""
        if isExecutable {
            ret += "{ "
        } else {
            ret += "[ "
        }
        for v in value {
            ret += v.description + " "
        }
        if isExecutable {
            ret += "}"
        } else {
            ret += "]"
        }
        return ret
    }
}
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
}

enum LError: Error {
    case runtimeError(String)
    case notInteger
    case notNumber
}

struct Stack<T> {
    var values: [T] = []
    
    func top() -> T? {
        if values.count > 0 {
            return values[values.count - 1]
        } else {
            return nil
        }
    }
    
    func printStack() throws -> () {
        print("* " + values.map({"\($0) "}).joined(), terminator: "")
    }
    
    mutating func pop() throws -> T {
        if values.count > 0 {
            let v = values[values.count - 1]
            values.remove(at: values.count - 1)
            return v
        } else {
            throw LError.runtimeError("underflow")
        }
    }
    
    func testUnderflow(n: Int) throws -> () {
        if values.count < n {
            throw LError.runtimeError("underflow")
        }
    }
    
    mutating func push(_ v: T) throws -> () {
        values += [v]
    }
    
    var count: Int {
        get { return values.count }
    }
    
    mutating func clear() -> () {
        values = []
    }
    
    func count(to: MarkType) -> Int {
        for i in 1...values.count {
            if let _ = values[values.count - i] as? MarkType {
                return i - 1
            }
        }
        return -1
    }
}

