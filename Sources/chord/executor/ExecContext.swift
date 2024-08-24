import Foundation

class ExecContext: CustomStringConvertible {
    var chord: Chord
    var scanner: Scanner?
    var proc: Procedure?
    var obj: ObjectType?
    
    init(context: Chord, object: ObjectType) {
        self.chord = context
        
        if let proc = object as? ArrayType, proc.isExecutable {
            if proc.count > 1 {
                self.proc = Procedure(context: self, array: proc)
            } else if proc.count == 1 {
                self.obj = proc.get(0)
            } else {
                self.obj = NullType.NULL
            }
        } else if let n = object as? NameType, n.isExecutable  {
            self.obj = n
        } else if let s = object as? StringType, s.isExecutable  {
            self.scanner = Scanner(source: s.stringValue)
        } else {
            self.obj = object
        }
    }
    
    func step() throws -> ObjectType? {
        if let scan = scanner {
            return lex(token: scan.scanToken())
        } else if let p = proc {
            return try p.step()
        } else if let o = obj {
            try execute(o)
            return NullType.NULL
        } else {
            // What to do with this?
            return NullType.NULL
        }
    }
    
    func lex(token: String) -> ObjectType? {
        guard let scanner = self.scanner else {
            print("no scanner")
            return NullType.NULL
        }
        
        do {
            if token == Scanner.EOF {
                return NullType.NULL
            } else if token == "#" {
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
        return nil
    }
    
    func execute(name: NameType) throws -> () {
        let value = try chord.dictionaryStack.load(key: name)
        if let op = value as? OperatorType {
            if !op.immediate, let w = chord.compileDef {
                name.isExecutable = true
                w.append(name)
            } else {
                try execute(value)
            }
        } else {
            // interpret word (immediate)
            if let w = chord.compileDef {
                name.isExecutable = true
                w.append(name)
            } else {
                try execute(value)
            }
        }
    }

    func execute(_ obj: ObjectType) throws -> () {
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
