import Foundation

@objc public class SSH: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}
