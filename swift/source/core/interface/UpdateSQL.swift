import Foundation

extension Database {

    public func prepareUpdateSQL(sql: String) throws -> UpdateSQL {
        return try UpdateSQL(with: self, sql: sql)
    }

}

/// The chain call for updating
public final class UpdateSQL {
    private var core: Core
    private let statement: StatementUpdateSQL

    /// The number of changed rows in the most recent call.
    /// It should be called after executing successfully
    public var changes: Int?

    init(with core: Core, sql: String) throws {
        self.core = core
        self.statement = StatementUpdateSQL(sql: sql)
    }

    /// Execute the update chain call with row.
    ///
    /// - Parameter row: Column encodable row
    /// - Throws: `Error`
    public func execute(with row: [ColumnEncodable?] = []) throws {
        let recyclableHandleStatement: RecyclableHandleStatement = try core.prepare(statement)
        let handleStatement = recyclableHandleStatement.raw
        for (index, value) in row.enumerated() {
            let bindingIndex = index + 1
            if let archivedValue = value?.archivedValue() {
                handleStatement.bind(archivedValue, toIndex: bindingIndex)
            } else {
                handleStatement.bind(nil, toIndex: bindingIndex)
            }
        }
        try handleStatement.step()
        changes = handleStatement.changes
    }
}

extension UpdateSQL: CoreRepresentable {

    /// The tag of the related database.
    public var tag: Tag? {
        return core.tag
    }

    /// The path of the related database.
    public var path: String {
        return core.path
    }
}
