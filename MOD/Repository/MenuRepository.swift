import Foundation

// MARK: - Menu Repository Protocol
protocol MenuRepositoryProtocol {
    func getCategories() async throws -> [MenuCategory]
    func getMenuItems(categoryId: String?) async throws -> [MenuItem]
    func getMenuItem(id: String) async throws -> MenuItem
    func searchMenuItems(query: String) async throws -> [MenuItem]
}

// MARK: - Menu Repository Implementation
class MenuRepository: MenuRepositoryProtocol {
    static let shared = MenuRepository()
    
    private init() {}
    
    func getCategories() async throws -> [MenuCategory] {
        // In production, this would call the MenuService
        // For now, return mock data
        return MockData.categories.filter { $0.isActive }
    }
    
    func getMenuItems(categoryId: String? = nil) async throws -> [MenuItem] {
        // In production, this would call the MenuService
        // For now, return mock data
        if let categoryId = categoryId {
            return MockData.menuItems.filter { $0.categoryId == categoryId && $0.isAvailable }
        }
        return MockData.menuItems.filter { $0.isAvailable }
    }
    
    func getMenuItem(id: String) async throws -> MenuItem {
        // In production, this would call the MenuService
        // For now, return mock data
        guard let item = MockData.menuItems.first(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        return item
    }
    
    func searchMenuItems(query: String) async throws -> [MenuItem] {
        // In production, this would call the MenuService
        // For now, return mock data
        return MockData.menuItems.filter { item in
            item.name.localizedCaseInsensitiveContains(query) ||
            item.description.localizedCaseInsensitiveContains(query)
        }
    }
}
