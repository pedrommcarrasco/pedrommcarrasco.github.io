import Foundation

struct Discardable {

    func main() {

        example()

        var value = example()
        value.append(" with discardable")
        print(value)
    }
}

// MARK: Examples
extension Discardable {

    @discardableResult
    func example() -> String {
        let description = "This is an example"
        print(description)
        return description
    }
}
