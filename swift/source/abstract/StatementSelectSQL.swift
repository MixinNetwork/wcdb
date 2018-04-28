import Foundation

public final class StatementSelectSQL: Statement {

    public private(set) var description: String = ""
    public var statementType: StatementType {
        return .select
    }

    public init(sql: String) {
        self.description = sql
    }
}

