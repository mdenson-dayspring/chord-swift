import Foundation

class Parser {
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
            if let _ = "()<>[]{}/#".firstIndex(of: char) {
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
            return Parser.EOF
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
}
