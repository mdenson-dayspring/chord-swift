import Foundation

let debugStack = true
let debugTop = true

var args = CommandLine.arguments
args.removeFirst()

var files:[String] = []
var startSource:String = ""
var arguments = false
for a in args {
    if a == "--" {
        arguments = true
    } else {
        if arguments {
            startSource.append("\(a) ")
        } else {
            files.append(a)
        }
    }
}

var c = Chord("")

for f in files {
    do {
        let text2 = try String(contentsOfFile: f, encoding: .utf8)
        c.interpret(source: text2)
    }
    catch {
        print("Error info: \(error)")
    }
}

c.interpret(source: startSource)
    
printPrompt()
while let line = readLine() {
    c.interpret(source: line)
    printPrompt()
}
print("")
print("bye")

func printPrompt() {
    if debugStack {
        c.printStack()
    } else if debugTop {
        c.printTop()
    }
    print("OK ", terminator: "")
}
