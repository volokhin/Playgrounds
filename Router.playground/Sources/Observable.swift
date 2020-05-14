import Foundation

@propertyWrapper
public struct Observable<T> {
    public let projectedValue = Event<T>()
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    public var wrappedValue: T {
        didSet {
            projectedValue.raise(wrappedValue)
        }
    }
}
