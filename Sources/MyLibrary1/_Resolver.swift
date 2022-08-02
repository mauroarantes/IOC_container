//
//  Created by Mauro Arantes on 02/08/2022.
//

public protocol _Resolver {
    func _resolve<Service, Arguments>(
        name: String?,
        option: ServiceKeyOption?,
        invoker: @escaping ((Arguments) -> Any) -> Any
    ) -> Service?
}
