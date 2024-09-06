import Foundation

class ExecContext: CustomStringConvertible {
    var chord: Chord
    var scanner: Scanner?
    var proc: Procedure?
    var obj: ObjectType?
    var objExecuted: Bool = false
    
    init(context: Chord, object: ObjectType) {
        self.chord = context
        
        if let proc = object as? ArrayType, proc.isExecutable {
            if proc.count > 1 {
                self.proc = Procedure(context: self, array: proc)
            } else if proc.count == 1 {
                let step = proc.get(0)
                if let name = step as? NameType, name.isExecutable {
                    findExecutable(step: step, name: name)
                } else {
                    self.obj = step
                }
            } else {
                self.obj = NullType.NULL
            }
        } else if let n = object as? NameType, n.isExecutable  {
            findExecutable(step: object, name: n)
        } else if let s = object as? StringType, s.isExecutable  {
            self.scanner = Scanner(source: s.stringValue)
        } else {
            self.obj = object
        }
    }
    var isTailOperation: Bool {
        get {
            if let _ = obj {
                return true
            } else if let p = proc {
                return p.isTail
            } else {
                return false
            }
        }
    }
    var isFinished: Bool {
        get {
            if let _ = obj {
                return objExecuted
            } else if let p = proc {
                return p.isFinished
            } else if let s = scanner {
                return s.isFinished
            } else {
                return false
            }
        }
    }
    
    func findExecutable(step: ObjectType, name: NameType) {
        do {
            let v = try lookupName(name: name)
            if let array = v as? ArrayType, array.isExecutable {
                self.proc = Procedure(context:self, array: array)
            } else if let op = v as? OperatorType {
                self.obj = op
            } else {
                self.obj = step
            }
        } catch {
            self.obj = step
        }
    }
    
    func step() throws {
        if let scan = scanner {
            lex(token: scan.scanToken())
        } else if let p = proc {
            try p.step()
        } else if let o = obj {
            objExecuted = true
            try execute(object: o)
        }
    }
    
    func lex(token: String) {
        guard let scanner = self.scanner else {
            print("no scanner")
            return
        }
        
        do {
            if token == "#" {
                scanner.scanComment()
            } else if token == "`" {
                // todo validate next token as a name
                let value = NameType(scanner.scanToken())
                if let w = chord.compileDef {
                    // push literal integer (compile)
                    w.append(value)
                } else {
                    // push literal integer (immediate)
                    try chord.stack.push(value)
                }
            } else if token == "(" {
                let value = StringType(string: scanner.scanString())
                if let w = chord.compileDef {
                    // push literal string (compile)
                    w.append(value)
                } else {
                    // push literal string (immediate)
                    try chord.stack.push(value)
                }
            } else if let value = token.integer {
                if let w = chord.compileDef {
                    // push literal integer (compile)
                    w.append(value)
                } else {
                    // push literal integer (immediate)
                    try chord.stack.push(value)
                }
            } else if let value = token.double {
                if let w = chord.compileDef {
                    // push literal double (compile)
                    w.append(value)
                } else {
                    // push literal integer (immediate)
                    try chord.stack.push(value)
                }
            } else {
                // execute word
                try execute(name: NameType(token))
            }
        } catch LError.runtimeError(let errorMessage) {
            print(errorMessage)
        } catch LError.notNumber {
            print("expected a number")
        } catch LError.notInteger {
            print("expected an integer")
        } catch {
            print("unexpected error")
        }
    }
    
    func lookupName(name: NameType) throws -> ObjectType {
        return try chord.dictionaryStack.load(key: name)
    }
    func execute(name: NameType) throws -> () {
        let value = try lookupName(name: name)
        if let op = value as? OperatorType {
            if !op.immediate, let w = chord.compileDef {
                name.isExecutable = true
                w.append(name)
            } else {
                try execute(object: value)
            }
        } else {
            // interpret word (immediate)
            if let w = chord.compileDef {
                name.isExecutable = true
                w.append(name)
            } else {
                try execute(object: value)
            }
        }
    }

    func execute(object obj: ObjectType) throws -> () {
        if let op = obj as? OperatorType {
            try op.native(op.def)
        } else if let name = obj as? NameType, name.isExecutable  {
            try execute(name: name)
        } else if let _ = obj as? NullType  {
            // do nothing
        } else if obj.isExecutable  {
            chord.executionStack.execute(obj)
        } else {
            try chord.stack.push(obj)
        }
    }
    
    public var description: String {
        if let s = scanner {
            return "EC: \(s)"
        } else if let p = proc {
            return "EC: \(p)"
        } else if let o = obj {
            return "EC: ObjectType \(o)"
        } else {
            return "EC: oops"
        }
    }
}
