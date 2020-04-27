extension String {
    /// Capitalize the first letter. Don't change any other letters.
    func capitalizedFirst() -> String {
        guard let first = first else {
            return self
        }
        
        return first.uppercased() + self.dropFirst()
    }
    
    /// Singularize a string by dropping the last character if string ends with "s"
    func singularize() -> String {
        guard hasSuffix("s") else {
            return self
        }
        return String(dropLast())
    }
}
