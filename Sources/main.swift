import Foundation

let debugStack = true
let debugTop = true

var args = CommandLine.arguments
args.removeFirst()

var filenames = Array<String>()
var startSource:String = ""
var arguments = false
for a in args {
    if a == "--" {
        arguments = true
    } else {
        if arguments {
            startSource.append("\(a) ")
        } else {
            filenames.insert(a, at: 0)
        }
    }
}

var c = Chord("")
if filenames.count > 0 {
    c.interpret(source: filenames.map({"(\($0)) "}).joined() + String(filenames.count))
    c.interpret(source: """
`start {   
# (file1) ... (filen) n -- -
    1 1 3 -1 roll             # set up initial.increment.limit
    {pop run} for             # interpret contents of each file
} def
""")
}
c.interpret(source: "start")

if arguments {
    c.interpret(source: """
{\(startSource)}
exec                      # execute procedure with contents of inline source
count 0 gt {executive} if # if there are values left of the operand stack then start repl
""")
}

if !arguments && filenames.count == 0 {
    c.interpret(source: "executive")
}

