import Foundation

public final class Weak<T: AnyObject> {
    
    private let id: ObjectIdentifier?
    public private(set) weak var value: T?
    
    public var isAlive: Bool {
        return value != nil
    }
    
    public init(_ value: T?) {
        self.value = value
        if let value = value {
            id = ObjectIdentifier(value)
        } else {
            id = nil
        }
    }
}

extension Weak: Hashable {
    public static func == (lhs: Weak<T>, rhs: Weak<T>) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        if let id = id {
            hasher.combine(id)
        }
    }
}
