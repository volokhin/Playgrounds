import Foundation

private var changedEventKey: UInt8 = 0

public protocol INotifyOnChanged {
    var changed: Event<Void> { get }
}

public extension INotifyOnChanged {
    var changed: Event<Void> {
        get {
            if let event = objc_getAssociatedObject(self, &changedEventKey) as? Event<Void> {
                return event
            } else {
                let event = Event<Void>()
                objc_setAssociatedObject(self, &changedEventKey, event, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return event
            }
        }
    }
}
