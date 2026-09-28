import Foundation

// MARK: - Order Repository Protocol
protocol OrderRepositoryProtocol {
    func createOrder(order: Order) async throws -> Order
    func getOrder(orderId: String) async throws -> Order
    func getOrders() async throws -> [Order]
    func getActiveOrders() async throws -> [Order]
    func getPastOrders() async throws -> [Order]
    func cancelOrder(orderId: String) async throws -> Order
    func updateOrderStatus(orderId: String, status: OrderStatus) async throws -> Order
}

// MARK: - Order Repository Implementation
class OrderRepository: OrderRepositoryProtocol {
    static let shared = OrderRepository()
    
    private let orderService: OrderServiceProtocol
    
    private init(orderService: OrderServiceProtocol = OrderService.shared) {
        self.orderService = orderService
    }
    
    func createOrder(order: Order) async throws -> Order {
        return try await orderService.createOrder(order: order)
    }
    
    func getOrder(orderId: String) async throws -> Order {
        return try await orderService.getOrder(orderId: orderId)
    }
    
    func getOrders() async throws -> [Order] {
        return try await orderService.getOrders()
    }
    
    func getActiveOrders() async throws -> [Order] {
        let orders = try await getOrders()
        return orders.filter { $0.status.isActive }
    }
    
    func getPastOrders() async throws -> [Order] {
        let orders = try await getOrders()
        return orders.filter { $0.status.isCompleted }
    }
    
    func cancelOrder(orderId: String) async throws -> Order {
        return try await orderService.cancelOrder(orderId: orderId)
    }
    
    func updateOrderStatus(orderId: String, status: OrderStatus) async throws -> Order {
        return try await orderService.updateOrderStatus(orderId: orderId, status: status)
    }
}
