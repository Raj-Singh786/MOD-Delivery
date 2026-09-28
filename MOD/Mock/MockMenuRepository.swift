import Foundation

// MARK: - Mock Menu Repository
class MockMenuRepository: MenuRepositoryProtocol {
    static let shared = MockMenuRepository()
    
    private init() {}
    
    func getCategories() async throws -> [MenuCategory] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        return MockData.categories.filter { $0.isActive }
    }
    
    func getMenuItems(categoryId: String? = nil) async throws -> [MenuItem] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        if let categoryId = categoryId {
            return MockData.menuItems.filter { $0.categoryId == categoryId && $0.isAvailable }
        }
        return MockData.menuItems.filter { $0.isAvailable }
    }
    
    func getMenuItem(id: String) async throws -> MenuItem {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        guard let item = MockData.menuItems.first(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        return item
    }
    
    func searchMenuItems(query: String) async throws -> [MenuItem] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
        
        return MockData.menuItems.filter { item in
            item.name.localizedCaseInsensitiveContains(query) ||
            item.description.localizedCaseInsensitiveContains(query)
        }
    }
}
