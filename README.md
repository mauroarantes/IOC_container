# MyLibrary1

The Container class uses Inversion of Control (IoC) to resolve dependencies. First, registering the types then resolving with the dependencies.
This class is not thread safe, but the synchronize method returns thread safe views as Resolver type.

The test cases are checking the container's methods such as  register(), resolve() and removeAll().
