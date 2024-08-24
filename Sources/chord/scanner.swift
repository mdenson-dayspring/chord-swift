import Foundation

class Scanner : CustomStringConvertible{
    static let EOF = "\u{04}"
    let source: String
    var ptr: Int = 0
    
    init(source:String) {
        self.source = source
    }
     
    func scanChar() -> Character? {
        if ptr >= source.count {
            return nil
        }
        let ndx = source.index(source.startIndex, offsetBy: ptr)
        let ret: Character = source[ndx]
        ptr += 1

        return ret
    }
    
    func scanToken() -> String {
        var ret = ""

        while let char = scanChar() {
            // handle delimiters
            //  (, ), <, >, [, ], {, }, /, and %
            if let _ = "()<>[]{}`#".firstIndex(of: char) {
                if ret != "" {
                    // return already scanned a token
                    ptr -= 1
                    break
                } else {
                    // return this delimiter as the next token
                    ret.append(char)
                    break
                }
            }
                
            // handle whitespace
            if char.isWhitespace && ret == "" {
                // compress whitespace between tokens
                continue
            } else if char.isWhitespace {
                // whitespace ends token
                break
            }
            
            ret.append(char)
        }
        
        if ret == "" {
            return Scanner.EOF
        } else {
            return ret
        }
    }
    
    func scanComment() -> () {
        while let char = scanChar() {
            if char.isNewline {
                break
            }
        }
    }
    
    func scanString() -> String {
        var countLeftParans = 1
        var ret = ""

        while let char = scanChar() {
            if char == ")" {
                countLeftParans -= 1
                if countLeftParans == 0 {
                    break
                }
                ret.append(char)
            } else if char == "(" {
                countLeftParans += 1
                ret.append(char)
            } else if char == "~" {
                if let c = scanChar() {
                    if c == "n" {
                        ret.append("\n")
                    } else if c == "r" {
                        ret.append("\r")
                    } else if c == "t" {
                        ret.append("\t")
                    } else if c == "b" {
                        ret.append("\u{8}")
                    } else if c == "f" {
                        ret.append("\u{c}")
                    } else if c == "~" {
                        ret.append("~")
                    } else if c == "(" {
                        ret.append("(")
                    } else if c == ")" {
                        ret.append(")")
                    } else if c == "\n" {
                        // if tilde at end of line ignore tilde and newline
                        // i,e. concatenate multi-line string into single line
                    } else {
                        // ignore (swallow) tilde
                        ret.append(c)
                    }
                }
            } else {
                ret.append(char)
            }
        }
        return ret
    }
    
    public var description: String {
        return "Scanner \(ptr) (\(source))"
    }
}
