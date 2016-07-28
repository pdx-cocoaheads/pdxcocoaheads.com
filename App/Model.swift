//
//  Model.swift
//  pdxcocoaheads.com
//
//  Created by Ryan Arana on 7/27/16.
//
//

import Foundation

protocol ModelType {
    var id: Int? { get }
}

protocol ModelLayer {
    associatedtype Model: ModelType
    func readAll() -> ModelResult<Model>
    /// Adds the item to the database and returns it. If the item has a non-nil `id`
    /// this will act as an Update to an existing item.
    func create(item: Model) -> ModelResult<Model>
    func readItem(withID id: Int) -> ModelResult<Model>
    func delete(item: Model) -> ModelResult<Model>
}

enum ModelResult<Model: ModelType> {
    case create(Model)
    case read([Model])
    case update(Model)
    case delete(Model)
    case error(ModelError)
}

enum ModelError: ErrorProtocol {
    case NotFound(Int)
    case DatabaseError(String)
}
