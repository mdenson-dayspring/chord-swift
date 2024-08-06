import Foundation

class DictionaryType: ObjectType, CustomStringConvertible
{
    var values: [DictEntry] = []
    
    func put(key: NameType, value: ObjectType) {
        values.append(DictEntry(key: key, value: value))
    }
    func put(op: OperatorType) {
        self.put(key: op.name, value: op)
    }
    func putAll(operators: [OperatorType]) {
        for op in operators {
            values.append(DictEntry(key: op.name, value: op))
        }
    }

    func load(key: NameType) throws -> ObjectType {
        for p in 1...values.count{
            if values[values.count - p].key == key {
                return values[values.count - p].value
            }
        }
        throw LError.undefined
    }
    
    var type: NameType {
        get { return NameType("dictionarytype")}
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
        get {
            var contents = ""
            for v in values {
                contents += v.valueAsSyntaxString + " "
            }
            let ret: String = "<<\(contents.trimmingCharacters(in: .whitespaces))>>"
            return StringType(string: ret)
        }
    }
    public var description: String {
        return valueAsSyntaxString.stringValue
    }
}

class DictEntry
{
    let key: NameType
    let value: ObjectType
    
    init(key: NameType, value: ObjectType = NullType.NULL) {
        self.key = key
        self.value = value
    }
    
    var valueAsString: StringType {
        get { return StringType(string: "\(key.valueAsString)->\(value.valueAsString)")}
    }
    var valueAsSyntaxString: StringType {
        get {
            return StringType(string: "\(key.valueAsSyntaxString.stringValue) \(value.valueAsSyntaxString.stringValue)")
        }
    }
}

