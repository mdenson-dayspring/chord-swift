import Foundation

class Procedure: CustomStringConvertible {
    let context: ExecContext
    let proc: ArrayType
    var instPtr: Int
    
    init(context: ExecContext, array: ArrayType) {
        self.context = context
        self.proc = array
        self.instPtr = 0
    }
    
    func step() throws -> ObjectType? {
        if let _ = proc.get(instPtr) as? ArrayType {
            // special handling to keep executable arrays
            //  from executing when executing an array of objects
            try context.chord.stack.push(proc.get(instPtr))
        } else {
            try context.execute(proc.get(instPtr))
        }
        instPtr += 1
        
        // tail recursion handling
        //  return last object in proc
        //  so that proc can be popped from
        //  execution stack before the final
        //  operation
        if instPtr == proc.count - 1 {
            return proc.get(instPtr)
        } else {
            return nil
        }
    }
    
    public var description: String {
        return "Proc \(instPtr) \(proc)"
    }
}
