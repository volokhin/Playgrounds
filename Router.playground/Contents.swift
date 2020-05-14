import UIKit
import PlaygroundSupport

// MARK: - OrdersProvider

struct Order {
    let name: String
    let id: Int
}

class OrdersProvider: ISingleton {
    typealias Arguments = Void
    
    required init(container: IContainer, args: Void) { }
    
    func loadOrders(completion: @escaping ([Order]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion((0...99).map { Order(name: "Order", id: $0) })
        }
    }
}

// MARK: - OrderDetailsVM

class OrderDetailsVM: IPerRequest {
    typealias Arguments = Order
    
    let title: String
    
    required init(container: IContainer, args: Order) {
        self.title = "Details of \(args.name) #\(args.id)"
    }
}

// MARK: - OrderDetailsVC

class OrderDetailsVC: UIViewController, IHaveViewModel {
    typealias ViewModel = OrderDetailsVM
    
    private lazy var titleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24).isActive = true
    }
    
    func viewModelChanged(_ viewModel: OrderDetailsVM) {
        titleLabel.text = viewModel.title
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

// MARK: - OrdersVM

class OrdersVM: IPerRequest, INotifyOnChanged {
    typealias Arguments = Void
    
    var orders: [OrderVM] = []
    
    private let ordersProvider: OrdersProvider
    private let presenter: PresenterService
    
    required init(container: IContainer, args: Void) {
        self.ordersProvider = container.resolve()
        self.presenter = container.resolve()
    }
    
    func loadOrders() {
        ordersProvider.loadOrders() { [weak self] model in
            self?.orders = model.map { OrderVM(order: $0) }
            self?.changed.raise()
        }
    }
    
    func showOrderDetails(forOrderIndex index: Int) {
        let order = orders[index].order
        // Открываем экран с деталями заказа
        presenter.present(OrderDetailsVC.self, args: order)
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
        tableView.delegate = self
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

extension OrdersVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.showOrderDetails(forOrderIndex: indexPath.row)
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

let container = Container()
let vc = OrdersVC()
vc.viewModel = container.resolve()
PlaygroundPage.current.liveView = vc
print("Finish")
