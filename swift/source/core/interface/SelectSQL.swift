import Foundation

extension Database {

    public func prepareSelectSQL(on propertyConvertibleList: [PropertyConvertible], sql: String, values: [ColumnEncodable] = []) throws -> SelectSQL {
        return try SelectSQL(with: self, on: propertyConvertibleList, sql: sql, values: values)
    }

}

public final class SelectSQL {

    private final var core: Core
    final var optionalRecyclableHandleStatement: RecyclableHandleStatement?
    final var statement: StatementSelectSQL

    private let keys: [CodingTableKeyBase]
    private let values: [ColumnEncodable]

    private lazy var decoder = TableDecoder(keys, on: optionalRecyclableHandleStatement!)

    init(with core: Core, on propertyConvertibleList: [PropertyConvertible], sql: String, values: [ColumnEncodable]) throws {
        keys = propertyConvertibleList.asCodingTableKeys()
        self.statement = StatementSelectSQL(sql: sql)
        self.core = core
        self.values = values
    }

    private func bindValues() throws {
        guard values.count > 0 else {
            return
        }
        let handleStatement = try lazyHandleStatement()
        for idx in 0..<values.count {
            handleStatement.bind(values[idx].archivedValue(), toIndex: idx + 1)
        }
    }

    deinit {
        try? finalize()
    }

    /// Get all selected objects according to the `CodingTableKey`.
    ///
    /// - Returns: Table decodable objects according to the `CodingTableKey`
    /// - Throws: `Error`
    public func allObjects() throws -> [Any] {
        let rootType = keys[0].rootType as? TableDecodableBase.Type
        assert(rootType != nil, "\(keys[0].rootType) must conform to TableDecodable protocol.")
        var objects: [Any] = []
        try bindValues()
        while try next() {
            objects.append(try rootType!.init(from: decoder))
        }
        return objects
    }

    /// Get all selected objects.
    ///
    /// - Parameter type: Type of table decodable object
    /// - Returns: Table decodable objects.
    /// - Throws: `Error`
    public func allObjects<Object: TableDecodable>(of type: Object.Type = Object.self) throws -> [Object] {
        assert(keys is [Object.CodingKeys], "Properties must belong to \(Object.self).CodingKeys.")
        var objects: [Object] = []
        try bindValues()
        while try next() {
            objects.append(try Object.init(from: decoder))
        }
        return objects
    }

    final func finalize() throws {
        if let recyclableHandleStatement = optionalRecyclableHandleStatement {
            try recyclableHandleStatement.raw.finalize()
            optionalRecyclableHandleStatement = nil
        }
    }

    final func lazyHandleStatement() throws -> HandleStatement {
        if optionalRecyclableHandleStatement == nil {
            optionalRecyclableHandleStatement = try core.prepare(statement)
        }
        return optionalRecyclableHandleStatement!.raw
    }

    //Since `next()` may throw errors, it can't conform to `Sequence` protocol to fit a `for in` loop.
    @discardableResult
    public final func next() throws -> Bool {
        do {
            return try lazyHandleStatement().step()
        } catch let error {
            try? finalize()
            throw error
        }
    }

}

extension SelectSQL: CoreRepresentable {
    /// The tag of the related database.
    public final var tag: Tag? {
        return core.tag
    }

    /// The path of the related database.
    public final var path: String {
        return core.path
    }
}
