import Foundation

// MARK: - Mock Order Repository
class MockOrderRepository: OrderRepositoryProtocol {
    static let shared = MockOrderRepository()
    
    private var orders: [Order] = []
    
    private init() {}
    
    func createOrder(order: Order) async throws -> Order {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        var createdOrder = order
        createdOrder.status = .confirmed
        createdOrder.estimatedTime = Date().addingTimeInterval(1800) // 30 minutes from now
        createdOrder.loyaltyPointsEarned = Int(order.subtotal * Constants.loyaltyPointsPerRupee)
        
        orders.append(createdOrder)
        return createdOrder
    }
    
    func getOrder(orderId: String) async throws -> Order {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        guard let order = orders.first(where: { $0.id == orderId }) else {
            throw APIError.notFound
        }
        return order
    }
    
    func getOrders() async throws -> [Order] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        return orders.sorted { $0.createdAt > $1.createdAt }
    }
    
    func getActiveOrders() async throws -> [Order] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
        return orders.filter { $0.status.isActive }.sorted { $0.createdAt > $1.createdAt }
    }
    
    func getPastOrders() async throws -> [Order] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
        return orders.filter { $0.status.isCompleted }.sorted { $0.createdAt > $1.createdAt }
    }
    
    func cancelOrder(orderId: String) async throws -> Order {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
        
        guard let index = orders.firstIndex(where: { $0.id == orderId }) else {
            throw APIError.notFound
        }
        
        orders[index].status = .cancelled
        return orders[index]
    }
    
    func updateOrderStatus(orderId: String, status: OrderStatus) async throws -> Order {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        guard let index = orders.firstIndex(where: { $0.id == orderId }) else {
            throw APIError.notFound
        }
        
        orders[index].status = status
        return orders[index]
    }
}
