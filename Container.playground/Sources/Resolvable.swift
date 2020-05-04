import Foundation

public class ContainerHolder {
    public static var container: IContainer!
}

@propertyWrapper
public struct Resolvable<T: IResolvable> where T.Arguments == Void {
    private var instance: T?
    public init() { }
    
    public var wrappedValue: T {
        mutating get {
            if let instance = instance {
                return instance
            }
            let resolved = ContainerHolder.container.resolve() as T
            instance = resolved
            return resolved
        }
    }
}
