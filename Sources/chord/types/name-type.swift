import Foundation

class NameType: StringType
{
    init(_ id: String) {
        super.init()
        self.value = id
    }
    
    var executable = false
    override var isExecutable: Bool {
        get { return executable }
        set(newValue) { executable = newValue }
    }
    
    override var type: NameType {
        get { return NameType("nametype")}
    }

    static func == (lhs: NameType, rhs: NameType) -> Bool {
        return lhs.value == rhs.value
    }
    
    override var valueAsSyntaxString: StringType {
        get { return  StringType(string: !executable ? "`\(value)" : "\(value)") }
    }
}
