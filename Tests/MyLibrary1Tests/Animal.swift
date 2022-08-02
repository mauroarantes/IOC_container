//
//  Created by Mauro Arantes on 02/08/2022.
//

import Foundation

internal protocol Animal {
    var name: String? { get set }
}

internal class Cat: Animal {
    var name: String?
    var sleeping = false

    init() {}

    init(name: String) {
        self.name = name
    }

    init(name: String, sleeping: Bool) {
        self.name = name
        self.sleeping = sleeping
    }
}

internal class Siamese: Cat {}

internal class Dog: Animal {
    var name: String?

    init() {}

    init(name: String) {
        self.name = name
    }
}

internal struct Turtle: Animal {
    var name: String?
}
