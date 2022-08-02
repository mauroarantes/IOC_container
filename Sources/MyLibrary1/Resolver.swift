//
//  Created by Mauro Arantes on 02/08/2022.
//

public protocol Resolver {
    func resolve<Service>(_ serviceType: Service.Type) -> Service?

    func resolve<Service>(_ serviceType: Service.Type, name: String?) -> Service?
}
