var args = CommandLine.arguments
args.removeFirst()

var c = Chord(args.joined(separator: " "))


c.interpret(source: """
/inches { 25.4 mul } def /inch { } def
/feet { 12 mul inches } def /foot { feet } def
/yards { 36 mul inches } def /yard { yards } def
""")

print("OK ", terminator: "")
while let line = readLine() {
    c.interpret(source: line)
    print("OK ", terminator: "")
}
print("")
print("bye")

