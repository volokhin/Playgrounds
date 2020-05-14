import UIKit
import PlaygroundSupport

// MARK: - OrdersProvider

struct Order {
    let name: String
    let id: Int
}

class OrdersProvider {
    func loadOrders(completion: @escaping ([Order]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion((0...99).map { Order(name: "Order", id: $0) })
        }
    }
}

// MARK: - OrderVM

class OrderVM {
    let order: Order
    var name: String {
        return "\(order.name) #\(order.id)"
    }
    init(order: Order) {
        self.order = order
    }
}

// MARK: - OrderVM

class OrdersVM: INotifyOnChanged {
    
    @Observable
    var orders: [OrderVM] = []
    
    private var ordersProvider: OrdersProvider
    
    init(ordersProvider: OrdersProvider) {
        self.ordersProvider = ordersProvider
    }
    
    func loadOrders() {
        ordersProvider.loadOrders() { [weak self] model in
            self?.orders = model.map { OrderVM(order: $0) }
            self?.changed.raise()
        }
    }
}

// MARK: - OrderCell

class OrderCell: UITableViewCell, IHaveViewModel {
    typealias ViewModel = OrderVM
    
    func viewModelChanged(_ viewModel: OrderVM) {
        textLabel?.text = viewModel.name
    }
}

// MARK: - OrdersVC

class OrdersVC: UIViewController, IHaveViewModel {
    typealias ViewModel = OrdersVM
    
    private lazy var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(OrderCell.self, forCellReuseIdentifier: "order")
        view.addSubview(tableView)
        viewModel?.loadOrders()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func viewModelChanged(_ viewModel: OrdersVM) {
        tableView.reloadData()
    }
}

extension OrdersVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.orders.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "order", for: indexPath)
        if let cell = cell as? IHaveAnyViewModel {
            cell.anyViewModel = viewModel?.orders[indexPath.row]
        }
        return cell
    }
}

// MARK: - Main

let vm = OrdersVM(ordersProvider: OrdersProvider())
let vc = OrdersVC()
vc.viewModel = vm

PlaygroundPage.current.liveView = vc
print("Finish")
