import Foundation

protocol MenuRepositoryProtocol: Sendable {
    func getCategories() async throws -> [Category]
    func getMenuItems(for categoryId: String?) async throws -> [MenuItem]
    func getMenuItem(id: String) async throws -> MenuItem
    func searchMenuItems(query: String) async throws -> [MenuItem]
}
