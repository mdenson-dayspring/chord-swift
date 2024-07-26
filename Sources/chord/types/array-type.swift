import Foundation

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
    
    var valueAsString: StringType {
        get { return StringType(string: "--nostringtype--")}
    }
    var valueAsSyntaxString: StringType {
        get {
            var contents = ""
            for v in value {
                contents += v.valueAsSyntaxString + " "
            }
            let ret: String
            if isExecutable {
                ret = "{\(contents.trimmingCharacters(in: .whitespaces))}"
            } else {
                ret = "[\(contents.trimmingCharacters(in: .whitespaces))]"
            }
            return StringType(string: ret)
        }
    }
    
    public var description: String {
        return valueAsSyntaxString.stringValue
    }
}
