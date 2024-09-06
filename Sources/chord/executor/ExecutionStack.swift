import Foundation

class ExecutionStack {
    var chord: Chord?
    var contexts: [ExecContext] = Array<ExecContext>()
    
    private func pop() -> ExecContext? {
        if contexts.count > 0 {
            let v = contexts[contexts.count - 1]
            contexts.remove(at: contexts.count - 1)
            return v
        }
        return nil
    }
    private func push(_ v: ExecContext) -> () {
        contexts += [v]
    }
    
    private var top: ExecContext {
        get {
            return contexts[contexts.count - 1]
        }
    }
    var count: Int {
        get { return contexts.count }
    }
    
    func runLoop() {
        guard let _ = chord else {
            print("unexpected error (no context)")
            return
        }
        while count > 0 {
            let t = top
            if t.isFinished {
                _ = pop()
            } else {
                let prevCount = count
                do {
                    try t.step()
                    if t.isFinished && prevCount == count {
                        _ = pop()
                    }
                } catch {
                    print("unexpected error")
                }
            }
        }
    }

    func exitLoopContext() {
        while !(top is LoopContext) && count > 0 {
            let _ = pop()
        }
        if count > 0 {
            let _ = pop()
        }
    }
    
    func execute(_ obj: ObjectType) {
        guard let chord = self.chord else {
            return
        }
        push(ExecContext(context: chord, object: obj))
    }
    func execute(_ obj: LoopContext) {
        push(obj)
    }
}
