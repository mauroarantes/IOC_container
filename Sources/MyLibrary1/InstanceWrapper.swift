//
//  Created by Mauro Arantes on 02/08/2022.
//

protocol InstanceWrapper {
    static var wrappedType: Any.Type { get }
    init?(inContainer container: Container, withInstanceFactory factory: (() -> Any?)?)
}

public final class Lazy<Service>: InstanceWrapper {
    static var wrappedType: Any.Type { return Service.self }

    private let factory: () -> Any?
    private weak var container: Container?

    init?(inContainer container: Container, withInstanceFactory factory: (() -> Any?)?) {
        guard let factory = factory else { return nil }
        self.factory = factory
        self.container = container
    }

    private var _instance: Service?

    public var instance: Service {
        if let instance = _instance {
            return instance
        } else {
            _instance = makeInstance()
            return _instance!
        }
    }

    private func makeInstance() -> Service? {
        return factory() as? Service
    }
}

public final class Provider<Service>: InstanceWrapper {
    static var wrappedType: Any.Type { return Service.self }

    private let factory: () -> Any?

    init?(inContainer _: Container, withInstanceFactory factory: (() -> Any?)?) {
        guard let factory = factory else { return nil }
        self.factory = factory
    }

    public var instance: Service {
        return factory() as! Service
    }
}

extension Optional: InstanceWrapper {
    static var wrappedType: Any.Type { return Wrapped.self }

    init?(inContainer _: Container, withInstanceFactory factory: (() -> Any?)?) {
        self = factory?() as? Wrapped
    }
}
