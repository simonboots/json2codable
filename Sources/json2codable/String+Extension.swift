extension String {
    func capitalizedFirst() -> String {
        guard let first = first else {
            return self
        }
        
        return first.uppercased() + self.dropFirst()
    }
    
    func singularize() -> String {
        guard hasSuffix("s") else {
            return self
        }
        return String(dropLast())
    }
}
