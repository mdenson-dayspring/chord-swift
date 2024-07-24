import Foundation

extension String {
    var isWhitespace: Bool {
        guard !isEmpty else { return true }
        
        let whitespaceChars = NSCharacterSet.whitespacesAndNewlines
        
        return self.unicodeScalars
            .filter { !whitespaceChars.contains($0) }
            .count == 0
    }
    
}
extension StringProtocol {
    var double: Double? { Double(self) }
    var float: Float? { Float(self) }
    var integer: Int? { Int(self) }
}
