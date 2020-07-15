import Foundation

public enum InstanceScope {
    case perRequst
    case singleton
}

public protocol IResolvable: AnyObject {
    associatedtype Arguments
    
    static var instanceScope: InstanceScope { get }
    init(container: IContainer, args: Arguments)
}

public protocol ISingleton: IResolvable where Arguments == Void { }
public extension ISingleton {
    static var instanceScope: InstanceScope {
        return .singleton
    }
}

public protocol IPerRequest: IResolvable { }
public extension IPerRequest {
    static var instanceScope: InstanceScope {
        return .perRequst
    }
}

public protocol IContainer: AnyObject {
    func resolve<T: IResolvable>(args: T.Arguments) -> T
}

public class Container {
    private var singletons: [ObjectIdentifier: AnyObject] = [:]
    public init() { }
    
    func makeInstance<T: IResolvable>(args: T.Arguments) -> T {
        return T(container: self, args: args)
    }
}

extension Container: IContainer {
    public func resolve<T: IResolvable>(args: T.Arguments) -> T {
        switch T.instanceScope {
        case .perRequst:
            return makeInstance(args: args)
        case .singleton:
            let key = ObjectIdentifier(T.self)
            if let cached = singletons[key], let instance = cached as? T {
                return instance
            } else {
                let instance: T = makeInstance(args: args)
                singletons[key] = instance
                return instance
            }
        }
    }
}

public extension IContainer {
    func resolve<T: IResolvable>() -> T where T.Arguments == Void {
        return resolve(args: ())
    }
}
