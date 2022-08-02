//
//  Created by Mauro Arantes on 02/08/2022.
//

import Foundation

internal protocol ServiceEntryProtocol: AnyObject {
    var factory: Any { get }
    var initCompleted: (Any)? { get }
    var serviceType: Any.Type { get }
}

public final class ServiceEntry<Service>: ServiceEntryProtocol {
    fileprivate var initCompletedActions: [(Resolver, Service) -> Void] = []
    internal let serviceType: Any.Type
    internal let argumentsType: Any.Type

    internal let factory: Any
    internal weak var container: Container?

    internal var initCompleted: Any? {
        guard !initCompletedActions.isEmpty else { return nil }

        return { [weak self] (resolver: Resolver, service: Any) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.initCompletedActions.forEach { $0(resolver, service as! Service) }
        }
    }

    internal init(serviceType: Service.Type, argumentsType: Any.Type, factory: Any) {
        self.serviceType = serviceType
        self.argumentsType = argumentsType
        self.factory = factory
    }
}
