import Foundation

class Procedure: CustomStringConvertible {
    let context: ExecContext
    let proc: ArrayType
    var instPtr: Int
    
    var isTail: Bool {
        get {
            return instPtr == proc.count - 1
        }
    }
    var isFinished: Bool {
        get {
            return instPtr >= proc.count
        }
    }
    init(context: ExecContext, array: ArrayType) {
        self.context = context
        self.proc = array
        self.instPtr = 0
    }
    
    func step() throws {
        if let _ = proc.get(instPtr) as? ArrayType {
            // special handling to keep executable arrays
            //  from executing when executing an array of objects
            try context.chord.stack.push(proc.get(instPtr))
        } else {
            try context.execute(object: proc.get(instPtr))
        }
        instPtr += 1
    }
    
    public var description: String {
        return "Proc \(instPtr) \(proc)"
    }
}
