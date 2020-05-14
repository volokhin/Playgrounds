import Foundation

// MARK: - OrdersProvider

class OrdersProvider: ISingleton {
    required init(container: IContainer, args: Void) { }
    
    func loadOrders(for customerId: Int, date: Date) {
        print("Loading orders for customer '\(customerId)', date '\(date)'")
    }
}

// MARK: - OrdersProviderMock

class OrdersProviderMock: OrdersProvider {
    override func loadOrders(for customerId: Int, date: Date) {
        print("Loading mock orders for customer '\(customerId)', date '\(date)'")
    }
}

// MARK: - OrdersVM

class OrdersVM: IPerRequest {
    struct Args {
        let customerId: Int
        let date: Date
    }
    
    @Resolvable
    private var ordersProvider: OrdersProvider
    private let args: Args
    
    required init(container: IContainer, args: Args) {
       self.args = args
    }
    
    func loadOrders() {
        ordersProvider.loadOrders(for: args.customerId, date: args.date)
    }
}

// MARK: - Main

ContainerHolder.container = Container()
let viewModel: OrdersVM = ContainerHolder.container.resolve(args: .init(customerId: 42, date: Date()))
viewModel.loadOrders()

let containerMock = ContainerMock()
ContainerHolder.container = containerMock
containerMock.replace(OrdersProvider.self, with: OrdersProviderMock.self)
let viewModelWithMock: OrdersVM = containerMock.resolve(args: .init(customerId: 42, date: Date()))
viewModelWithMock.loadOrders()
print("Finish")
