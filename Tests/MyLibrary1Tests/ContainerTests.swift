//
//  Created by Mauro Arantes on 02/08/2022.
//

import XCTest
@testable import MyLibrary1

class ContainerTests: XCTestCase {
    var container: Container!

    override func setUpWithError() throws {
        container = Container()
    }

    // MARK: Resolution of a non-registered service
    func testContainerReturnsNilWithoutRegistration() {
        let animal = container.resolve(Animal.self)
        XCTAssertNil(animal)
    }

    func testContainerResolvesByRegisteredName() {
        container.register(Animal.self, name: "RegMimi") { _ in Cat(name: "Mimi") }
        container.register(Animal.self, name: "RegMew") { _ in Cat(name: "Mew") }
        container.register(Animal.self) { _ in Cat() }

        let mimi = container.resolve(Animal.self, name: "RegMimi") as? Cat
        let mew = container.resolve(Animal.self, name: "RegMew") as? Cat
        let noname = container.resolve(Animal.self) as? Cat
        XCTAssertEqual(mimi?.name, "Mimi")
        XCTAssertEqual(mew?.name, "Mew")
        XCTAssertNil(noname?.name)
    }

    // MARK: Removal of registered services
    func testContainerCanRemoveAllRegisteredServices() {
        container.register(Animal.self, name: "RegMimi") { _ in Cat(name: "Mimi") }
        container.register(Animal.self, name: "RegMew") { _ in Cat(name: "Mew") }
        container.removeAll()

        let mimi = container.resolve(Animal.self, name: "RegMimi")
        let mew = container.resolve(Animal.self, name: "RegMew")
        XCTAssertNil(mimi)
        XCTAssertNil(mew)
    }

    // MARK: Container hierarchy
    func testContainerResolvesServiceRegisteredOnParentContainer() {
        let parent = Container()
        let child = Container(parent: parent)

        parent.register(Animal.self) { _ in Cat() }
        let cat = child.resolve(Animal.self)
        XCTAssertNotNil(cat)
    }

    func testContainerDoesNotResolveServiceRegistredOnChildContainer() {
        let parent = Container()
        let child = Container(parent: parent)

        child.register(Animal.self) { _ in Cat() }
        let cat = parent.resolve(Animal.self)
        XCTAssertNil(cat)
    }

    func testContainerDoesNotCreateZombies() {
        let parent = Container()
        let child = Container(parent: parent)

        parent.register(Cat.self) { _ in Cat() }
        weak var weakCat = child.resolve(Cat.self)
        XCTAssertNil(weakCat)
    }

    #if !SWIFT_PACKAGE
    func testContainerDoesNotTerminateGraphPrematurely() {
        let parent = Container()
        let child = Container(parent: parent)

        child.register(Animal.self) { _ in Cat() }
        parent.register(Food.self) { _ in Sushi() }
        parent.register(PetOwner.self) {
            let owner = PetOwner(pet: child.resolve(Animal.self)!)
            owner.favoriteFood = $0.resolve(Food.self)
            return owner
        }

        _ = parent.resolve(PetOwner.self)
    }
    #endif
}
