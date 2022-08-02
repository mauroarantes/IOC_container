//
//  Created by Mauro Arantes on 02/08/2022.
//

import Foundation

public final class Container {
    internal var services = [ServiceKey: ServiceEntryProtocol]()
    private let parent: Container?
    private var resolutionDepth = 0
    internal let lock: RecursiveLock

    internal init(
        parent: Container? = nil
    ) {
        self.parent = parent
        lock = parent.map { $0.lock } ?? RecursiveLock()
    }

    public convenience init(
        parent: Container? = nil,
        registeringClosure: (Container) -> Void = { _ in }
    ) {
        self.init(parent: parent)
        registeringClosure(self)
    }

    public func removeAll() {
        services.removeAll()
    }

    @discardableResult
    public func register<Service>(
        _ serviceType: Service.Type,
        name: String? = nil,
        factory: @escaping (Resolver) -> Service
    ) -> ServiceEntry<Service> {
        return _register(serviceType, factory: factory, name: name)
    }

    @discardableResult
    public func _register<Service, Arguments>(
        _ serviceType: Service.Type,
        factory: @escaping (Arguments) -> Any,
        name: String? = nil,
        option: ServiceKeyOption? = nil
    ) -> ServiceEntry<Service> {
        let key = ServiceKey(serviceType: Service.self, argumentsType: Arguments.self, name: name, option: option)
        let entry = ServiceEntry(
            serviceType: serviceType,
            argumentsType: Arguments.self,
            factory: factory
        )
        entry.container = self
        services[key] = entry


        return entry
    }

    public func synchronize() -> Resolver {
        return SynchronizedResolver(container: self)
    }
}

extension Container: _Resolver {
    public func _resolve<Service, Arguments>(
        name: String?,
        option: ServiceKeyOption? = nil,
        invoker: @escaping ((Arguments) -> Any) -> Any
    ) -> Service? {
        var resolvedInstance: Service?
        let key = ServiceKey(serviceType: Service.self, argumentsType: Arguments.self, name: name, option: option)

        if let entry = getEntry(for: key) {
            resolvedInstance = resolve(entry: entry, invoker: invoker)
        }

        if resolvedInstance == nil {
            resolvedInstance = resolveAsWrapper(name: name, option: option, invoker: invoker)
        }

        return resolvedInstance
    }

    fileprivate func resolveAsWrapper<Wrapper, Arguments>(
        name: String?,
        option: ServiceKeyOption?,
        invoker: @escaping ((Arguments) -> Any) -> Any
    ) -> Wrapper? {
        guard let wrapper = Wrapper.self as? InstanceWrapper.Type else { return nil }

        let key = ServiceKey(
            serviceType: wrapper.wrappedType, argumentsType: Arguments.self, name: name, option: option
        )

        if let entry = getEntry(for: key) {
            let factory = { [weak self] in self?.resolve(entry: entry, invoker: invoker) as Any? }
            return wrapper.init(inContainer: self, withInstanceFactory: factory) as? Wrapper
        } else {
            return wrapper.init(inContainer: self, withInstanceFactory: nil) as? Wrapper
        }
    }

    fileprivate func getRegistrations() -> [ServiceKey: ServiceEntryProtocol] {
        var registrations = parent?.getRegistrations() ?? [:]
        services.forEach { key, value in registrations[key] = value }
        return registrations
    }

    fileprivate var maxResolutionDepth: Int { return 200 }

    fileprivate func incrementResolutionDepth() {
        parent?.incrementResolutionDepth()
        guard resolutionDepth < maxResolutionDepth else {
            fatalError("Infinite recursive call for circular dependency has been detected. " +
                "To avoid the infinite call, 'initCompleted' handler should be used to inject circular dependency.")
        }
        resolutionDepth += 1
    }

    fileprivate func decrementResolutionDepth() {
        parent?.decrementResolutionDepth()
        assert(resolutionDepth > 0, "The depth cannot be negative.")

        resolutionDepth -= 1
    }
}

// MARK: - Resolver

extension Container: Resolver {
    public func resolve<Service>(_ serviceType: Service.Type) -> Service? {
        return resolve(serviceType, name: nil)
    }

    public func resolve<Service>(_: Service.Type, name: String?) -> Service? {
        return _resolve(name: name) { (factory: (Resolver) -> Any) in factory(self) }
    }

    fileprivate func getEntry(for key: ServiceKey) -> ServiceEntryProtocol? {
        if let entry = services[key] {
            return entry
        } else {
            return parent?.getEntry(for: key)
        }
    }

    fileprivate func resolve<Service, Factory>(
        entry: ServiceEntryProtocol,
        invoker: (Factory) -> Any
    ) -> Service? {
        incrementResolutionDepth()
        defer { decrementResolutionDepth() }

        let resolvedInstance = invoker(entry.factory as! Factory)

        if let completed = entry.initCompleted as? (Resolver, Any) -> Void,
            let resolvedInstance = resolvedInstance as? Service {
            completed(self, resolvedInstance)
        }

        return resolvedInstance as? Service
    }
}
