private func matcherMessage<T>(forType expectedType: T.Type) -> String {
    return "be a kind of \(String(describing: expectedType))"
}
private func matcherMessage(forClass expectedClass: AnyClass) -> String {
    return "be a kind of \(String(describing: expectedClass))"
}

/// A Nimble matcher that succeeds when the actual value is an instance of the given class.
public func beAKindOf<T>(_ expectedType: T.Type) -> Predicate<Any> {
    return Predicate.define { actualExpression in
        let message: ExpectationMessage

        let instance = try actualExpression.evaluate()
        guard let validInstance = instance else {
            message = .expectedCustomValueTo(matcherMessage(forType: expectedType), actual: "<nil>")
            return PredicateResult(status: .fail, message: message)
        }
        message = .expectedCustomValueTo(
            "be a kind of \(String(describing: expectedType))",
            actual: "<\(String(describing: type(of: validInstance))) instance>"
        )

        return PredicateResult(
            bool: validInstance is T,
            message: message
        )
    }
}

#if canImport(Darwin)
import class Foundation.NSObject

/// A Nimble matcher that succeeds when the actual value is an instance of the given class.
/// @see beAnInstanceOf if you want to match against the exact class
public func beAKindOf(_ expectedClass: AnyClass) -> Predicate<NSObject> {
    return Predicate.define { actualExpression in
        let message: ExpectationMessage
        let status: PredicateStatus

        let instance = try actualExpression.evaluate()
        if let validInstance = instance {
            status = PredicateStatus(bool: instance != nil && instance!.isKind(of: expectedClass))
            message = .expectedCustomValueTo(
                matcherMessage(forClass: expectedClass),
                actual: "<\(String(describing: type(of: validInstance))) instance>"
            )
        } else {
            status = .fail
            message = .expectedCustomValueTo(
                matcherMessage(forClass: expectedClass),
                actual: "<nil>"
            )
        }

        return PredicateResult(status: status, message: message)
    }
}

extension NMBPredicate {
    @objc public class func beAKindOfMatcher(_ expected: AnyClass) -> NMBPredicate {
        return NMBPredicate { actualExpression in
            return try beAKindOf(expected).satisfies(actualExpression).toObjectiveC()
        }
    }
}

#endif
