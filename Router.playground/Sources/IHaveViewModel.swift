import Foundation

public protocol IHaveAnyViewModel: AnyObject {
    var anyViewModel: Any? { get set }
}

public protocol IHaveViewModel: IHaveAnyViewModel {
    associatedtype ViewModel
    
    var viewModel: ViewModel? { get set }
    func viewModelChanged()
    func viewModelChanged(_ viewModel: ViewModel)
}

private var viewModelKey: UInt8 = 0

public extension IHaveViewModel {
    
    var anyViewModel: Any? {
        get {
            return objc_getAssociatedObject(self, &viewModelKey)
        }
        set {
            (anyViewModel as? INotifyOnChanged)?.changed.unsubscribe(self)
            let viewModel = newValue as? ViewModel
            
            objc_setAssociatedObject(self, &viewModelKey, viewModel, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            viewModelChanged()
            if let viewModel = viewModel {
                viewModelChanged(viewModel)
            }
            
            (viewModel as? INotifyOnChanged)?.changed.subscribe(self) { this in
                this.viewModelChanged()
                if let viewModel = viewModel {
                    this.viewModelChanged(viewModel)
                }
            }
        }
    }
    
    var viewModel: ViewModel? {
        get {
            return anyViewModel as? ViewModel
        }
        set {
            anyViewModel = newValue
        }
    }
    
    func viewModelChanged() {
        
    }
    
    func viewModelChanged(_ viewModel: ViewModel) {
        
    }
}
