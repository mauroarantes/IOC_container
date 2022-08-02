//
//  Created by Mauro Arantes on 02/08/2022.
//

import Foundation

public protocol ServiceKeyOption: CustomStringConvertible {
    func isEqualTo(_ another: ServiceKeyOption) -> Bool
    func hash(into: inout Hasher)
}

internal struct ServiceKey {
    internal let serviceType: Any.Type
    internal let argumentsType: Any.Type
    internal let name: String?
    internal let option: ServiceKeyOption?
    internal init(
        serviceType: Any.Type,
        argumentsType: Any.Type,
        name: String? = nil,
        option: ServiceKeyOption? = nil
    ) {
        self.serviceType = serviceType
        self.argumentsType = argumentsType
        self.name = name
        self.option = option
    }
}

extension ServiceKey: Hashable {
    public func hash(into hasher: inout Hasher) {
        ObjectIdentifier(serviceType).hash(into: &hasher)
        ObjectIdentifier(argumentsType).hash(into: &hasher)
        name?.hash(into: &hasher)
        option?.hash(into: &hasher)
    }
}

func == (lhs: ServiceKey, rhs: ServiceKey) -> Bool {
    return lhs.serviceType == rhs.serviceType
        && lhs.argumentsType == rhs.argumentsType
        && lhs.name == rhs.name
        && equalOptions(opt1: lhs.option, opt2: rhs.option)
}

private func equalOptions(opt1: ServiceKeyOption?, opt2: ServiceKeyOption?) -> Bool {
    switch (opt1, opt2) {
    case let (opt1?, opt2?): return opt1.isEqualTo(opt2)
    case (nil, nil): return true
    default: return false
    }
}
