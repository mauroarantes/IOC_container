//
//  Created by Mauro Arantes on 02/08/2022.
//

import Foundation

internal final class RecursiveLock {
    private let lock = NSRecursiveLock()

    func sync<T>(action: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return action()
    }
}
