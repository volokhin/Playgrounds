import UIKit

public class NavigationService: ISingleton {
    
    private unowned let container: IContainer
    
    private var topNavigationController: UINavigationController? {
        let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        let topViewController = findTopViewController(in: keyWindow?.rootViewController)
        return findNavigationController(in: topViewController)
    }
    
    public required init(container: IContainer, args: Void) {
        self.container = container
    }
    
    public func pushViewController<VC: UIViewController & IHaveViewModel>(
        _ viewController: VC.Type,
        args: VC.ViewModel.Arguments) where VC.ViewModel: IResolvable {
        
        let vc = VC()
        vc.viewModel = container.resolve(args: args)
        
        topNavigationController?.pushViewController(vc, animated: true)
    }
    
    public func popViewController() {
        topNavigationController?.popViewController(animated: true)
    }

    private func findTopViewController(in controller: UIViewController?) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return findTopViewController(in: navigationController.topViewController)
        } else if let tabController = controller as? UITabBarController,
            let selected = tabController.selectedViewController {
            return findTopViewController(in: selected)
        } else if let presented = controller?.presentedViewController {
            return findTopViewController(in: presented)
        }
        return controller
    }
    
    private func findNavigationController(in controller: UIViewController?) -> UINavigationController? {
        if let navigationController = controller as? UINavigationController {
            return navigationController
        } else if let navigationController = controller?.navigationController {
            return navigationController
        } else {
            for child in controller?.children ?? [] {
                if let navigationController = findNavigationController(in: child) {
                    return navigationController
                }
            }
        }
        return nil
    }
}

public extension NavigationService {
    func pushViewController<VC: UIViewController & IHaveViewModel>(
        _ viewController: VC.Type) where VC.ViewModel: IResolvable, VC.ViewModel.Arguments == Void {
        
        pushViewController(viewController, args: ())
    }
}
