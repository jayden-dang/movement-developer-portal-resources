# Table of Contents

-   [Summary](#summary)
-   [Writing/Reading resources](#writingreading-resources)
    -   [Break down](#break-down)
    -   [Using Global Storage in Move](#using-global-storage-in-move)
-   [Detroying a Resource](#detroying-a-resource)
    -   [Overview](#overview)
    -   [Full Code](#full-code)

# Summary

Key points about global storage in Move:

-   Global storage allows persistent data storage associated with
    addresses
-   Resources stored in global storage must have the 'key' ability
-   Use `move_to` to store data and 'borrow~global~' to access it
-   Always check if a resource exists before attempting to access it
-   Mutable access requires `borrow_global_mut` and proper access
    control
-   The `acquires` keyword is necessary for functions that access global
    storage
-   The `move_from` function removes a resource from an account or
    address.
-   Resources must have the "drop" ability to use `move_from`.
-   The "drop" ability prevents unintentional deletion of resources.
-   It allows control over whether resources can be deleted or should
    persist.
-   The code demonstrates how to implement and use `move_from` in a Move
    module.
-   The module includes functions for creating, modifying, and removing
    global storage.

# Writing/Reading resources

Based on the previous topic, we've learned how to create a resource and
store it in global storage. Now, let's explore how to access and
interact with data in global storage.

``` move
module movement::local_global_storage {
    use std::debug::print;
    use std::signer::address_of;

    struct GlobalData has key {
        value: u64
    }

    const EResourceNotExist: u64 = 33;

    public entry fun new_global(signer: &signer, value: u64) {
        let data = GlobalData {
            value: value
        } ;
        move_to(signer, data);
    }

    public entry fun change_value_from_global_storage(signer: &signer, value: u64) acquires GlobalData {
        let addr = address_of(signer);
        if (!check_global_storage_exists(addr)) {
            abort EResourceNotExist
        };

        let value_reference = &mut borrow_global_mut<GlobalData>(addr).value;
        *value_reference = *value_reference + value;
    }

    public fun check_global_storage_exists(addr: address): bool {
        exists<GlobalData>(addr)
    }

    #[view]
    public fun get_value_from_global_storage(addr: address): u64 acquires GlobalData {
        if (!check_global_storage_exists(addr)) {
            abort EResourceNotExist
        };
        let value_reference = borrow_global<GlobalData>(addr);
        value_reference.value
    }

    #[test(account = @0x1)]
    fun test_new_global(account: &signer) {
        new_global(account, 10);
    }
}
```

\> Running test:

``` bash
movement move test -f test_new_global
```

\> Result:

``` bash
Running Move unit tests
[ PASS    ] 0x5fdf6936671d4e4a89b686aff0b5a4dfe083babbaaa6e78f5daa8801f94938a6::local_global_storage::test_new_globalTest result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

## Break down

> Let's break down the code and explain it step by step:

### 1. Struct Definition

``` rust
struct GlobalData has key {
        value: u64
}
```

Here, we define a struct called `GlobalData` with the `key` ability,
allowing it to be stored in global storage. It contains a single field
`value` of type `u64`.

### 2. Error Constant

``` move
const EResourceNotExist: u64 = 33;
```

This defines an error code that will be used when a resource doesn't
exist in global storage.

### 3. Function to Create Global Storage

``` move
public entry fun new_global(signer: &signer, value: u64) {
    let data = GlobalData {
        value: value
    } ;
    move_to(signer, data);
}
```

This function creates a new `GlobalData` instance and moves it to the
signer's address in global storage.

### 4. Function to Modify Global Storage

``` move
public entry fun change_value_from_global_storage(signer: &signer, value: u64) acquires GlobalData {
    let addr = address_of(signer);
    if (!check_global_storage_exists(addr)) {
        abort EResourceNotExist
    };

    let value_reference = &mut borrow_global_mut&lt;GlobalData&gt;(addr).value;
    *value_reference = *value_reference + value;
}
```

This function modifies the value in global storage. It first checks if
the resource exists, then borrows a mutable reference to update the
value.

### 5. Function to Check Global Storage Existence

``` move
public fun check_global_storage_exists(addr: address): bool {
    exists&lt;GlobalData&gt;(addr)
}
```

This function checks if `GlobalData` exists at a given address.

### 6. Function to Read from Global Storage

``` move
#[view]
public fun get_value_from_global_storage(addr: address): u64 acquires GlobalData {
    if (!check_global_storage_exists(addr)) {
        abort EResourceNotExist
    };
    let value_reference = borrow_global&lt;GlobalData&gt;(addr);
    value_reference.value
}
```

This function reads the value from global storage. It first checks if
the resource exists, then borrows an immutable reference to read the
value.

## Using Global Storage in Move

1.  Create a new global storage entry:
    -   Use the `new_global` function, providing a signer and an initial
        value.
    -   This stores the data under the signer's address.
2.  Check if global storage exists:
    -   Use the `check_global_storage_exists` function, passing an
        address.
    -   This returns a boolean indicating whether the data exists.
3.  Modify data in global storage:
    -   Use the `change_value_from_global_storage` function.
    -   This function adds the provided value to the existing value in
        storage.
4.  Read data from global storage:
    -   Use the `get_value_from_global_storage` function, passing an
        address.
    -   This returns the current value stored at that address.

By following these steps, you can effectively work with global storage
in Move, ensuring proper data management and access across your smart
contract.

# Detroying a Resource

## Overview

Among the provided functions in the previous topics, we haven't yet
discussed `move_from`. This function removes a resource from an account
or address. It's crucial to note that to use `move_from` for a resource,
you must ensure the resource has the `drop` ability. Without this, the
compiler will throw an error. This safeguard prevents resources from
being unintentionally deleted, either accidentally or in cases where you
want resources to remain permanent. It allows you to control whether
resources can be deleted or should persist indefinitely.

-   Drop Ability

    ``` rust
    struct GlobalData has key, drop {
        value: u64
    }
    ```

-   `move_from` function

    ``` move
    public entry fun remove_resource_from_global_storage(account: &signer) acquires GlobalData {
        let rev = move_from<GlobalData>(address_of(account));
    }
    ```

## Full Code

``` move
module movement::local_global_storage {
    use std::debug::print;
    use std::signer::address_of;

    struct GlobalData has key, drop {
        value: u64
    }

    const EResourceNotExist: u64 = 33;
    const ENotEqual: u64 = 10;

    public entry fun new_global(signer: &signer, value: u64) {
        let data = GlobalData {
            value: value
        } ;
        move_to(signer, data);
    }

    public entry fun change_value_from_global_storage(signer: &signer, value: u64) acquires GlobalData {
        let addr = address_of(signer);
        if (!check_global_storage_exists(addr)) {
            abort EResourceNotExist
        };

        let value_reference = &mut borrow_global_mut<GlobalData>(addr).value;
        *value_reference = *value_reference + value;
    }

    public fun check_global_storage_exists(addr: address): bool {
        exists<GlobalData>(addr)
    }

    #[view]
    public fun get_value_from_global_storage(addr: address): u64 acquires GlobalData {
        if (!check_global_storage_exists(addr)) {
            abort EResourceNotExist
        };
        let value_reference = borrow_global<GlobalData>(addr);
        print(&value_reference.value);
        value_reference.value
    }

    public entry fun remove_resource_from_global_storage(account: &signer) acquires GlobalData {
        let rev = move_from<GlobalData>(address_of(account));
    }

    #[test(account = @0x1)]
    fun test_new_global(account: &signer) {
        new_global(account, 10);
    }

    #[test(account = @0x1)]
    fun test_change_value_global(account: &signer) acquires GlobalData {
        new_global(account, 10);
        change_value_from_global_storage(account, 10); // value should be equal 20
        let value = get_value_from_global_storage(address_of(account));
        assert!(value == 20, ENotEqual);
        // remove resource
        remove_resource_from_global_storage(account);
        assert!(!check_global_storage_exists(address_of(account)), EResourceNotExist);
    }
}
```

\> Running test:

``` bash
movement move test -f local_global_storage
```

\> Result:

``` bash
Running Move unit tests
[debug] 20
[ PASS    ] 0x5fdf6936671d4e4a89b686aff0b5a4dfe083babbaaa6e78f5daa8801f94938a6::local_global_storage::test_change_value_global
[ PASS    ] 0x5fdf6936671d4e4a89b686aff0b5a4dfe083babbaaa6e78f5daa8801f94938a6::local_global_storage::test_new_globalTest result: OK. Total tests: 2; passed: 2; failed: 0
{
  "Result": "Success"
}
```
