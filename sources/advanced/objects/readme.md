# Table of Contents

-   [Address Object & Create Object](#address-object--create-object)
-   [Named Objects](#named-objects)
-   [Object Ownership & Transfer
    Object](#object-ownership--transfer-object)
-   [Object Permissions & ObjectRefs](#object-permissions--objectrefs)
-   [Using ExtendRef](#using-extendref)
-   [Using TransferRef](#using-transferref)
-   [Using DeleteRef](#using-deleteref)

# Address Object & Create Object

### Summary

-   Objects are a key feature in the `aptos_framework`, enhancing code
    flexibility and adaptability.
-   They address limitations of structs such as lack of stable identity,
    limited extensibility, and data overload.
-   Objects maintain stable references, allow potential future
    extensions, and improve data organization.
-   Creation involves using functions like `object::create_object`,
    which generates a unique address for storing resources.
-   The process includes getting the owner's address, creating the
    object, generating an object signer, and moving the object to its
    address.
-   Different types of objects (normal, named, sticky) can be created
    with varying properties of deletability and address determinism.

### What is Object?

Objects are one of the most exciting features of the aptos~framework~.
They make your code extremely flexible and help developers be more
adaptable in designing and developing products. Objects are also used in
many of Aptos' standard code implementations, such as Digital Assets,
Coins, and Fungible Tokens.

In this lesson, we will explore what objects are and how they work.

### Limitations of Structs

Reflecting on our previous lessons about structs, we can see that while
using structs and a resource-centric approach has made Move very
flexible, there are still several limitations:

1.  Lack of Stable Identity: Structs can move freely between resources,
    making them difficult to track consistently.
2.  Limited Extensibility: Once defined, structs cannot be easily
    extended with new fields, even in upgradable modules.
3.  Data Overload: Storing numerous resources in accounts can lead to
    clutter, making it challenging to locate relevant data for specific
    decentralized applications (dApps).

**Using objects in this way allows us to:**

1.  Maintain a stable reference to our data via the object's address.
2.  Potentially extend the object's functionality in future upgrades.
3.  Keep related data grouped together, improving organization.

### Create a Object

``` move
module movement::object_module_entry {
    use aptos_framework::object;
    use std::debug::print;
    use std::signer;

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct ExampleObject has key {
        value: u64
    }

    public entry fun example_object(user: &signer, value: u64) {
        let owner_address = signer::address_of(user);
        print(&owner_address);

        let example_object_constructor_ref = &object::create_object(owner_address);
        print(example_object_constructor_ref);

        let object_signer = &object::generate_signer(example_object_constructor_ref);
        print(object_signer);

        move_to(object_signer, ExampleObject { value });

        let address_object = object::address_from_constructor_ref(example_object_constructor_ref);
        print(&address_object);
    }

    #[test(account = @0x1)]
    fun test_example_object(account: &signer) {
        example_object(account, 10);
    }
}
```

Certainly! I'll provide a step-by-step description of the
`example_object` function from the code you've selected. This function
demonstrates how to create and use objects:

1.  Function Signature:

``` move
public entry fun example_object(user: &signer, value: u64)
```

This function takes two parameters: a reference to a signer (the user)
and a u64 value.

1.  Get the owner's address:

``` move
let owner_address = signer::address_of(user);
```

This step retrieves the address of the signer and prints it.

1.  Create an object:

``` move
let example_object_constructor_ref = &object::create_object(owner_address);
```

Here, a new object is created using the=create~object~=function from
the=object=module. The constructor reference is stored. This function
returns a randomly generated and unique object address. This address
will be used to store resources instead of storing them directly in the
user's address. This approach reduces the storage burden on user
accounts, making it more optimized and flexible.

1.  Generate an object signer:

``` move
let object_signer = &object::generate_signer(example_object_constructor_ref);
```

This step generates a signer for the object using the constructor
reference.

1.  Move the ExampleObject to the object's address:

``` move
move_to(object_signer, ExampleObject { value });
```

This moves an instance of `ExampleObject` with the given value to the
address of the object signer.

1.  Get the object's address:

``` move
let address_object = object::address_from_constructor_ref(example_object_constructor_ref);
```

Finally, the function retrieves the address of the created object using
the constructor reference and prints it.

``` bash
[debug] @0x1 // Address Signer
[debug] 0x1::object::ConstructorRef { // Create address object
  self: @0xe46a3c36283330c97668b5d4693766b8626420a5701c18eb64026075c3ec8a0a,
  can_delete: true
}
[debug] signer(@0xe46a3c36283330c97668b5d4693766b8626420a5701c18eb64026075c3ec8a0a) // signer
[debug] @0xe46a3c36283330c97668b5d4693766b8626420a5701c18eb64026075c3ec8a0a
```

1.  Additionally, instead of retrieving the object's address, you can
    also directly obtain the object through this function:

``` move
let object_info = object::object_from_constructor_ref<ExampleObject>(example_object_constructor_ref);
```

Finally, the test results will return additional inner objects of that
struct:

``` move
[debug] 0x1::object::Object<0x6f409ba3234fa3b9a8baf7d442709ef51f39284f35dd7c06360fa0b55a0cd690::object_module_entry::ExampleObject> {
  inner: @0xe46a3c36283330c97668b5d4693766b8626420a5701c18eb64026075c3ec8a0a
}
```

In addition to the `object::create_object` function, we have other
functions to create objects:

-   `object::create_object`: A normal Object \| This type is `deletable`
    and has a `random address`
-   `object::create_named_object` : A named Object \| This type is
    `not deletable` and has a `deterministic address`
-   `object::create_sticky_object` : A sticky Object \| This type is
    also `not deletable` and has a `random address`

# Named Objects

### Summary

-   Named objects in Move allow for easy retrieval and manipulation of
    object data
-   The module demonstrates creation, retrieval, and modification of a
    Object
-   Named objects use a fixed address, making them more convenient than
    default or sticky objects
-   The module includes test functions to verify correct behavior of
    main functions
-   Global storage methods like `borrow_global` and `borrow_global_mut`
    are used to access object data

### Named Object

In the previous section, we learned about three types of Objects, among
which named objects will likely be the type we use most often because we
can initialize an object address that is fixed and can be easily
retrieved through the Object Name Address. As for default objects and
sticky objects, both create a random address. This makes it difficult to
use them for querying or listing information, but they also have their
uses in certain cases.

In this section, we will use named objects to easily obtain the address
for storing an object.

``` move
module movement::object_module_entry {
    use aptos_framework::object;
    use std::signer::address_of;
    use std::debug::print;

    const MOVEMENT_OBJECT_NAME: vector<u8> = b"MovementObjectName";

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct MovementObject has key {
        value: u64
    }

    fun init_module(owner: &signer) {
        let state_object_constructor_ref = &object::create_named_object(owner, MOVEMENT_OBJECT_NAME);
        let state_object_signer = &object::generate_signer(state_object_constructor_ref);
        move_to(state_object_signer, MovementObject {
            value: 10
        });
    }

    #[test_only]
    fun test_init_module(onwer: &signer) {
        init_module(onwer);
    }

    #[view]
    public fun get_object_address(owner: address): address {
        object::create_object_address(&owner, MOVEMENT_OBJECT_NAME)
    }

    #[test(account = @0x1)]
    fun test_get_object_address(account: &signer) {
        test_init_module(account);
        let owner = address_of(account);
        let addr = get_object_address(owner);
        print(&addr);
    }
}
```

``` bash
[debug] @0x52152ca68792cb72eb58f6497c1c8fbe69f5fc5d938edf2e74ed8da6ae816622 // Object Address
```

By using named objects, we can easily access the object and perform
changes or view data.

### Modify & Retrieve Object Value

To modify and retrieve data from objects, we still use global storage
methods like `borrow_global` and `borrow_global_mut`.

``` move
public fun get_value(owner: address): u64 acquires MovementObject {
    borrow_global<MovementObject>(get_object_address(owner)).value
}

public fun set_value(owner: address, new_value: u64) acquires MovementObject {
    let spider_dna = borrow_global_mut<MovementObject>(get_object_address(owner));
    spider_dna.value = new_value;
}
```

### Full Code

``` move
module movement::object_module_entry {
    use aptos_framework::object;
    use std::signer::address_of;
    use std::debug::print;

    const MOVEMENT_OBJECT_NAME: vector<u8> = b"MovementObjectName";

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct MovementObject has key {
        value: u64
    }

    fun init_module(owner: &signer) {
        let state_object_constructor_ref = &object::create_named_object(owner, MOVEMENT_OBJECT_NAME);
        let state_object_signer = &object::generate_signer(state_object_constructor_ref);
        move_to(state_object_signer, MovementObject {
            value: 10
        });
    }

    #[test_only]
    fun test_init_module(onwer: &signer) {
        init_module(onwer);
    }

    #[view]
    public fun get_object_address(owner: address): address {
        object::create_object_address(&owner, MOVEMENT_OBJECT_NAME)
    }

    public fun get_value(owner: address): u64 acquires MovementObject {
        borrow_global<MovementObject>(get_object_address(owner)).value
    }

    public fun set_value(owner: address, new_value: u64) acquires MovementObject {
        let spider_dna = borrow_global_mut<MovementObject>(get_object_address(owner));
        spider_dna.value = new_value;
    }

    #[test(account = @0x1)]
    fun test_get_object_address(account: &signer) {
        test_init_module(account);
        let addr = address_of(account);
        let value = get_object_address(addr);
        print(&value);
    }

    #[test(account = @0x1)]
    fun test_get_object(account: &signer) acquires MovementObject {
        test_init_module(account);
        let addr = address_of(account);
        let value = get_value(addr);
        assert!(value == 10, 0);
    }

    #[test(account = @0x1)]
    fun test_set_object(account: &signer) acquires MovementObject {
        test_init_module(account);
        let addr = address_of(account);
        set_value(addr, 20);
        let value = get_value(addr);
        assert!(value == 20, 1);
    }
}
```

### Function Descriptions

-   init~module~(owner: &signer) This function initializes the module by
    creating a named object and setting its initial value.

    -   Creates a named object using `object::create_named_object`
    -   Generates a signer for the object using
        `object::generate_signer`
    -   Moves a `MovementObject` with an initial value of 10 to the
        object's address

-   get~objectaddress~(owner: address): address This function retrieves
    the address of the named object for a given owner.

    -   Uses `object::create_object_address` to calculate the object's
        address
    -   Returns the calculated address

-   get~value~(owner: address): u64 This function retrieves the current
    value stored in the MovementObject for a given owner.

    -   Calls `get_object_address` to get the object's address
    -   Uses `borrow_global` to access the MovementObject at the
        calculated address
    -   Returns the `value` field from the MovementObject

-   set~value~(owner: address, new~value~: u64) This function updates
    the value stored in the MovementObject for a given owner.

    -   Calls `get_object_address` to get the object's address
    -   Uses `borrow_global_mut` to get a mutable reference to the
        MovementObject
    -   Updates the `value` field with the new value

-   Test Functions The module includes several test functions to verify
    the correct behavior of the main functions:

    -   `test_init_module`: Initializes the module for testing
    -   `test_get_object_address`: Tests the `get_object_address`
        function
    -   `test_get_object`: Tests the `get_value` function
    -   `test_set_object`: Tests the `set_value` function

# Object Ownership & Transfer Object

# Object Permissions & ObjectRefs

# Using ExtendRef

# Using TransferRef

# Using DeleteRef
