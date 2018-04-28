import Foundation

public final class StatementUpdateSQL: Statement {

    public private(set) var description: String = ""
    public var statementType: StatementType {
        return .update
    }

    public init(sql: String) {
        self.description = sql
    }
}

