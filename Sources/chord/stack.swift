import Foundation


enum LError: Error {
    case runtimeError(String)
    case stackunderflow
    case typecheck
    case notInteger
    case notNumber
    case undefined
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
        print("\u{21a6} " + values.map({"\($0) "}).joined(), terminator: "")
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

