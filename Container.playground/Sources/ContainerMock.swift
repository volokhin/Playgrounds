import Foundation

public struct AnyResolvable {
    private let factory: (IContainer, Any) -> Any?
    
    public init<T: IResolvable>(resolvable: T.Type) {
        self.factory = { container, args in
            guard let args = args as? T.Arguments else { return nil }
            return T(container: container, args: args)
        }
    }
    
    func resolve(container: IContainer, args: Any) -> Any? {
        return factory(container, args)
    }
}

public final class ContainerMock: Container {
    private var substitutions: [ObjectIdentifier: AnyResolvable] = [:]
    
    public func replace<Type: IResolvable, SubstitutionType: IResolvable>(_ type: Type.Type, with substitution: SubstitutionType.Type) {
        let key = ObjectIdentifier(type)
        substitutions[key] = AnyResolvable(resolvable: substitution)
    }
    
    override func makeInstance<T: IResolvable>(args: T.Arguments) -> T {
        return makeSubstitution(args: args) ?? super.makeInstance(args: args)
    }
    
    private func makeSubstitution<T: IResolvable>(args: T.Arguments) -> T? {
        let key = ObjectIdentifier(T.self)
        let substitution = substitutions[key]
        let instance = substitution?.resolve(container: self, args: args)
        return instance as? T
    }
}
