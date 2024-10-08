# Table of Contents

-   [Integer](#integer)
    -   [Summary](#summary)
    -   [Overview](#overview)
    -   [Example Code](#example-code)
-   [Boolean](#boolean)
    -   [Summary](#summary-1)
    -   [Overview](#overview-1)
    -   [Example Code](#example-code-1)
    -   [Conclusion](#conclusion)
-   [Address & Signer](#address--signer)
    -   [Address](#address)
    -   [Signer](#signer)
-   [String & Vector](#string--vector)
    -   [Summary](#summary-2)
    -   [Vector Overview](#vector-overview)
    -   [Overview String](#overview-string)
    -   [Conclusion](#conclusion-1)
-   [Map (Simple Map)](#map-simple-map)
    -   [Overview](#overview-2)
    -   [Example:](#example)
    -   [Additional SimpleMap
        Functions](#additional-simplemap-functions)

# Integer

## Summary

-   Move supports six unsigned integer types: `u8`, `u16`, `u32`, `u64`,
    `u128`, and `u256`.
-   Direct mathematical operations between different integer types are
    not allowed.
-   Type casting is necessary when performing operations with different
    integer types.
-   It's recommended to cast smaller types to larger types to avoid
    overflow risks.
-   The module demonstrates adding a `u8` and a `u64` by converting `u8`
    to `u64`.
-   A test function verifies the addition operation.
-   The code can be tested using the Move test command.

## Overview

Move supports six unsigned integer types: `u8`, `u16`, `u32`, `u64`,
`u128`, and `u256`. Values of these types range from 0 to a maximum that
depends on the size of the type. Although math can be done easily among
integers of the same type, it's not possible to do math directly between
integers of different type

``` move
fun plus_two_types(): u64 {
    let x: u8 = 10;
    let y: u64 = 60;
    // This will error
    x + y // x and y are different types -> failed to compile
}
```

To make this expression correct, you need to use two identical data
types; we will convert one of the two data types to match the other.

``` move
fun plus_two_types(): u64 {
    let x: u8 = 10;
    let y: u64 = 60;
    (x as u64) + y
}
```

> One of the things to pay attention to when using type casting, like
> the code above, is that we should only cast smaller types to larger
> types, and not the other way around. This helps to limit the risk of
> overflow.

## Example Code

This code defines a module in Move language that includes a function
`plus_two_types`, which adds a `u8` and a `u64` after converting the
`u8` to `u64`. The module also contains a test function
`test_plus_two_types` that verifies the addition operation.

``` move
module movement::integer_module {
    use std::debug::print;

    fun plus_two_types(x: u8, y: u64): u64 {
        (x as u64) + y
    }

    #[test]
    fun test_plus_two_types() {
        let result = plus_two_types(5, 100);
        print(&result);
    }
}
```

-   Execute test in the terminal

``` bash
aptos move test  -f integer_module
```

``` move
Running Move unit tests
[debug] 105
[ PASS    ] 0x1::integer_module::test_plus_two_integer
[debug] 105
[ PASS    ] 0x1::integer_module::test_plus_two_types
[ PASS    ] 0x1::integer_module::test_show_interger
Test result: OK. Total tests: 3; passed: 3; failed: 0
{
  "Result": "Success"
}
```

> [Full Code](./data_type/integer_type.move)

# Boolean

## Summary

-   Boolean is a primitive data type in Move representing `true` or
    `false` values
-   Essential for implementing logic and controlling program flow
-   Declared using the bool type (e.g., `let a: bool = true`)
-   Used in conditional statements and loops
-   Can be printed and tested in Move modules
-   Fundamental for effective programming and robust application
    development in Move

## Overview

Boolean types in Move are a primitive data type that represent two
possible values: `true` and `false`. They are essential for implementing
logic in your programs, allowing you to control the flow of execution
based on conditions.

### Introduction

In programming, Boolean types are used to represent truth values. They
are fundamental in decision-making processes, enabling conditional
statements and loops.

### Declaring Boolean Variables

You can declare Boolean variables using the bool type. Here’s how to do
it:

``` rust
let a: bool = true;   // Declaration of a Boolean variable with value true
let b: bool = false;  // Declaration of a Boolean variable with value false
```

## Example Code

Here’s the complete example demonstrating the declaration, usage, and
testing of Boolean types in Move:

``` move
module movement::boolean_type {
    use std::debug::print;

    fun bool_types() {
        let a: bool = true;
        let b: bool = false;
        print(&a);  // Outputs: true
        print(&b);  // Outputs: false
    }

    #[test]
    fun test_bool_types() {
        bool_types();  // Calls the bool_types function to test its output
    }
}
```

-   Run test on terminal

``` bash
aptos move test -f boolean_type
```

``` bash
Running Move unit tests
[debug] true
[debug] false
[ PASS    ] 0x1::boolean_type::test_bool_types
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

## Conclusion

Boolean types are a fundamental aspect of programming in Move, enabling
developers to implement logic and control flow effectively.
Understanding how to declare, use, and test Boolean types will enhance
your programming skills and improve your ability to write robust Move
applications.

# Address & Signer

## Address

### Summary

-   Address is a `256-bit` identifier representing locations in global
    storage in Move.
-   Addresses can store Modules and Resources, but are intentionally
    opaque and don't support arithmetic operations.
-   Address syntax includes named and numerical forms, with `@` prefix
    in expression contexts.
-   Signer represents authority over blockchain resources and is used
    for transaction execution.
-   Signer values are automatically generated by the Move VM and cannot
    be created through literals.
-   The `std::signer` module provides utility functions for working with
    signers.
-   Addresses are primarily used for global storage operations, while
    signers are used for transaction authorization.

### Address Overview

Address is an integrated data type in Move used to represent locations
(sometimes referred to as accounts) in global storage. An address value
is a `256-bit` (`32-byte`) identifier. At a specific address, two things
can be stored: a `Module` and a `Resource`.

Although an address is a `256-bit` integer, Move addresses are designed
to be intentionally opaque; they cannot be derived from integers, do not
support arithmetic operations, and cannot be altered. While there may be
interesting programs utilizing such features (for example, pointer
operators in C serve a similar role), Move does not allow such dynamic
behavior as it is designed from the ground up to support static
verification.

You can use address values at runtime (address-type values) to access
resources at that address. You cannot access modules at runtime through
address values.

### Address and Syntax:

Addresses have two forms: `named` or `numerical`. The syntax of named
addresses follows the same rules as any identifier name in Move. The
syntax of numerical addresses is not limited to hexadecimal values, and
any valid u256 numeric value can be used as an address value; for
example, `40`, `0xCAFE`, and `2024` are all valid numeric address
literals.

To distinguish when an address is being used in the context of an
expression or not, the syntax for using an address varies depending on
the context in which it is used:

-   When an address is used as an expression, it must be prefixed by the
    character @, for example: `@<numerical_value>` or
    `@<named_address_identifier>`.
-   Outside of expression contexts, an address can be written without
    the prefix @, for example: `<numerical_value>` or
    `<named_address_identifier>`.

### Declaring Address Variables

``` move
let addr1: address = @0x1;      //numerical address example
```

``` move
let addr2: address = @my_addrx; //named address example
```

### Primary purpose

-   The primary purpose of addresses is to interact with global storage
    operations.
-   Address values are used with the operations `exists`,
    `borrow_global`, `borrow_global_mut`, and `move_from`.
-   The only global storage operation that does not use an address is
    `move_to`, which uses a signer instead.

## Signer

### Signer Overview

Signer is a data type that represents the authority and control over a
resource or asset on the blockchain. The signer data type is used to
designate which account or entity is responsible for executing a
specific transaction or operation on the blockchain.

You can think of its native implementation as follows:

``` rust
struct signer has drop { a: address }
```

### Declaring Signer Variables

Signer values are special because they cannot be created through
literals or instruction-only constructs that can be generated by the
`MoveVM`. Before the VM executes a script with parameters of the signer
type, it will automatically generate `signer` values and pass them into
the code:

``` move
module movement::address_and_signer {
    use std::signer;

    // All structures that are saved to global storage must include the key attribute
    struct ResourceName has key {
        data: u64,
    }

    fun create_resource(new_data: u64, owner: &signer) {
        move_to(owner, ResourceName{
            data: new_data
        });
    }
}
```

`signer` Operations: The package `std::signer` in the standard library
module provides 2 utility functions for signer:

-   `signer::address_of(&signer)`: address - Returns the address wrapped
    by &signer.
-   `signer::borrow_address(&signer)`: &address - Returns a reference to
    the address wrapped by `&signer`.

``` move
module movement::address_and_signer {
    use std::signer;
    use std::debug::print;

    // All structures that are saved to global storage must include the key attribute
    struct ResourceName has key {
        data: u64,
    }

    fun create_resource(new_data: u64, owner: &signer) {
        move_to(owner, ResourceName{
            data: new_data
        });
        print(owner); // signer
        print(&signer::address_of(owner)); // address of signer
    }

    #[test(account = @0x1)]
    fun test_create_resource(account: &signer) {
        create_resource(10, account);
    }
}
```

-   Running test

``` bash
aptos move test -f address_and_signer
```

``` bash
[debug] signer(@0x1)
[debug] @0x1
[ PASS    ] 0x1::address_and_signer::test_create_resource
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

# String & Vector

## Summary

-   Move's primary collection type is `vector<T>`, a homogeneous,
    expandable/shrinkable collection of `T` values.
-   Vectors can be initialized with any data type, including primitive
    types, custom types, and nested vectors.
-   Key vector operations include adding elements, accessing by index,
    and removing elements.
-   Vector behavior depends on the capabilities of its element type `T`,
    especially for destruction and copying.
-   Move provides various built-in functions for vector manipulation,
    such as `push_back`, `pop_back`, and `borrow`.
-   Strings in Move are represented as `vector<u8>`, with utility
    functions for conversion and manipulation.

This document covers the fundamentals of working with vectors and
strings in Move, including creation, manipulation, and common
operations.

## Vector Overview

-   `vector<T>` is the only collection type provided by Move. A
    `vector<T>` is a homogeneous collection of T values that can be
    expanded or shrunk by adding/removing values from its "end".
-   A `vector<T>` can be initialized with any data type as T. For
    example, `vector<u8>`, `vector<address>`,
    `vector<0x42::MovementModule::ResourceType>`, and
    `vector<vector<u8>>`

``` rust
let byte_string_example: vector<u8> = b"Hello world"; //Byte strings are quoted string literals prefixed by a b
let hex_string_example: vector<u8> = x"48656c6c6f20776f726c64"; //Hex strings are quoted string literals prefixed by a x
```

### Add value into vector

The following code demonstrates how to add a value to the end of a
vector in Move:

-   The function `add_last_vec` takes a `u64` number as input and
    returns a `vector<u64>`.
-   It creates an empty vector using `vector::empty<u64>()`.
-   The `vector::push_back` function is used to add the input number to
    the end of the vector.
-   The `test_add_last_vec` function demonstrates how to use this
    function and print the resulting vector.

This example showcases basic vector operations in Move, including
creation, adding elements, and returning a vector from a function.

``` move
module movement::vector_type {
    use std::vector;
    use std::debug::print;

    fun add_last_vec(number: u64): vector<u64> {
        let list = vector::empty<u64>();

        vector::push_back(&mut list, number);
        return list
    }

    #[test]
    fun test_add_last_vec() {
        let vec = add_last_vec(500);
        print(&vec);
    }
}
```

### Get Value in vector by index

The following code demonstrates how to retrieve a value from a vector by
its index in Move:

-   The function `get_value_by_index_vec` takes a `u64` index as input
    and returns a `u64` value.
-   It creates a vector and populates it with three values: 10, 20, and
    30.
-   The `vector::borrow` function is used to access the element at the
    specified index. The `*` operator dereferences the borrowed value.
-   The `test_get_value_by_index_vec` function demonstrates how to use
    this function to retrieve and print a value from the vector.

This example illustrates how to access elements in a vector by their
index, which is a fundamental operation when working with vectors in
Move.

``` move
module movement::vector_type {
    use std::vector;
    use std::debug::print;

    fun get_value_by_index_vec(index: u64): u64 {
        let list = vector::empty<u64>();

        vector::push_back(&mut list, 10);
        vector::push_back(&mut list, 20);
        vector::push_back(&mut list, 30);
        return *vector::borrow(&list, index)
    }

    #[test]
    fun test_get_value_by_index_vec() {
        let value = get_value_by_index_vec(1);
        print(&value);
    }
}
```

### Take last value from vector

The following code demonstrates how to remove and return the last value
from a vector in Move:

-   The function `take_last_value_in_vec` creates a vector with three
    elements: 10, 20, and 30.
-   It uses `vector::pop_back` to remove and return the last
    element (30) from the vector.
-   The function returns a tuple containing the modified vector and the
    removed value.
-   The `test_take_last_value_in_vec` function shows how to use this
    function and print both the resulting vector and the removed value.

This example illustrates how to manipulate vectors by removing elements,
which is a common operation when working with dynamic collections in
Move.

``` move
module movement::vector_type {
    use std::vector;
    use std::debug::print;

    fun take_last_value_in_vec(): (vector<u64>, u64) {
        let list = vector::empty<u64>();

        vector::push_back(&mut list, 10);
        vector::push_back(&mut list, 20);
        vector::push_back(&mut list, 30);
        let take_value: u64 = vector::pop_back(&mut list);
        return (list, take_value)
    }

    #[test]
    fun test_take_last_value_in_vec() {
        let (list, take_value) = take_last_value_in_vec();
        print(&list);
        print(&take_value);
    }
}
```

### Destroying and Copying Vectors

-   Some behaviors of `vector<T>` depend on the capabilities of the
    element type `T`. For instance, vectors containing elements that
    can't be dropped can't be implicitly discarded like `v` in the
    example above. Instead, they must be explicitly destroyed using
    `vector::destroy_empty`.

Note: `vector::destroy_empty` will trigger a runtime error if the vector
is empty (contains zero elements).

``` move
fun destroy_any_vector<T>(vec: vector<T>) {
    vector::destroy_empty(vec) // deleting this line will cause a compiler error
}
```

-   Example:

``` move
module movement::vector_type {
    use std::vector;
    use std::debug::print;

    struct DropVector has drop {
        data: u64
    }

    fun add_last_vec(number: u64): vector<DropVector> {
        let list = vector::empty<DropVector>();

        vector::push_back(&mut list, DropVector { data: number });
        return list
    }

    #[test]
    fun test_add_vector() {
        let vec = add_last_vec(10);
        print(&vec);
    }

    #[test]
    #[expected_failure]
    fun test_failed_drop_vector() {
        let vec = add_last_vec(10);
        vector::destroy_empty(vec);
    }

    #[test]
    fun test_success_drop_vector() {
        let vec = add_last_vec(10);
        vector::pop_back(&mut vec);
        vector::destroy_empty(vec);
    }
}
```

-   Running test on terminal:

``` bash
aptos move test -f vector_type
```

``` bash
Running Move unit tests
[debug] [
  0x1::vector_type::DropVector {
    data: 10
  }
]
[ PASS ] 0x1::vector_type::test_add_vector
[ PASS ] 0x1::vector_type::test_failed_drop_vector
[ PASS ] 0x1::vector_type::test_success_drop_vector
Test result: OK. Total tests: 3; passed: 3; failed: 0
{
  "Result": "Success"
}
```

### Copy a vector

Similarly, vectors cannot be copied (using `copy`) unless the element
type has the `copy` capability. In other words, a `vector<T>` is
copyable only if `T` has the.

``` move
module movement::vector_type {
    use std::vector;
    use std::debug::print;

    struct DropVector has drop, copy {
        data: u64
    }

    fun add_last_vec(number: u64): vector<DropVector> {
        let list = vector::empty<DropVector>();

        vector::push_back(&mut list, DropVector { data: number });
        return list
    }

    #[test]
    fun test_success_drop_vector() {
        let vec = add_last_vec(10);
        vector::pop_back(&mut vec);
        vector::destroy_empty(vec);
    }

    #[test]
    fun test_clone_vector() {
        let vec = add_last_vec(10);
        let vec_copy = copy vec;
    }
}
```

-   Copying large `vectors` can be **expensive**, so the compiler
    requires explicit copies to make it easy to see where they occur.

### Additional Vector Functions

|                                                            |                                                                                                                                                                 |                                |
|------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------|
| Function                                                   | Description                                                                                                                                                     | Aborts?                        |
| —                                                          | —                                                                                                                                                               | —                              |
| `vector::empty<T>(): vector<T>`                            | Create an empty vector that can store values of type =T=                                                                                                        | Never                          |
| `vector::singleton<T>(t: T): vector<T>`                    | Create a vector of size 1 containing =t=                                                                                                                        | Never                          |
| `vector::push_back<T>(v: &mut vector<T>, t: T)`            | Add `t` to the end of `v`                                                                                                                                       | Never                          |
| `vector::pop_back<T>(v: &mut vector<T>): T`                | Remove and return the last element in `v`                                                                                                                       | If `v` is empty                |
| `vector::borrow<T>(v: &vector<T>, i: u64): &T`             | Return an immutable reference to the `T` at index `i`                                                                                                           | If `i` is not in bounds        |
| `vector::borrow_mut<T>(v: &mut vector<T>, i: u64): &mut T` | Return a mutable reference to the `T` at index `i`                                                                                                              | If `i` is not in bounds        |
| `vector::destroy_empty<T>(v: vector<T>)`                   | Delete `v`                                                                                                                                                      | If `v` is not empty            |
| `vector::append<T>(v1: &mut vector<T>, v2: vector<T>)`     | Add the elements in `v2` to the end of `v1`                                                                                                                     | Never                          |
| `vector::contains<T>(v: &vector<T>, e: &T): bool`          | Return true if `e` is in the vector `v`. Otherwise, returns false                                                                                               | Never                          |
| `vector::swap<T>(v: &mut vector<T>, i: u64, j: u64)`       | Swaps the elements at the `i=th and =j=th indices in the vector =v`                                                                                             | If `i` or `j` is out of bounds |
| `vector::reverse<T>(v: &mut vector<T>)`                    | Reverses the order of the elements in the vector `v` in place                                                                                                   | Never                          |
| `vector::index_of<T>(v: &vector<T>, e: &T): (bool, u64)`   | Return `(true, i)` if `e` is in the vector `v` at index `i`. Otherwise, returns `(false, 0)`                                                                    | Never                          |
| `vector::remove<T>(v: &mut vector<T>, i: u64): T`          | Remove the `i=th element of the vector =v`, shifting all subsequent elements. This is O(n) and preserves ordering of elements in the vector                     | If `i` is out of bounds        |
| `vector::swap_remove<T>(v: &mut vector<T>, i: u64): T`     | Swap the `i=th element of the vector =v` with the last element and then pop the element, This is O(1), but does not preserve ordering of elements in the vector | If `i` is out of bounds        |

## Overview String

In Move, String is not a native data type. Data in the MoveVM is stored
as bytes, so when using a string, the essence of the string will be a
`vector<u8>`, a sequence of characters encoded as bytes arranged
adjacently to create a string

``` move
module movement::string_type {
    use std::string::{String, utf8};
    use std::signer;
    use std::debug::print;

    fun vec_string() {
        let vec_string: vector<u8> = b"Hello by vector u8";
        let by_string: String = utf8(b"Hello by String");
        let by_vec: String = utf8(vec_string);
        print(&vec_string);
        print(&by_string);
        print(&by_vec);
    }

    #[test]
    fun test_vec_string() {
        vec_string()
    }
}
```

-   Running test on Terminal:

``` bash
aptos move test -f string_type
```

``` bash
Running Move unit tests
[debug] 0x48656c6c6f20627920766563746f72207538
[debug] "Hello by String"
[debug] "Hello by vector u8"
[ PASS ] 0x1::string_type::test_vec_string
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

## Conclusion

Vectors and strings are fundamental data structures in Move that provide
powerful capabilities for handling collections and text data. Here are
the key takeaways:

-   Vectors (`vector<T>`) offer a flexible, homogeneous collection type
    that can be used with any data type in Move.
-   Vector operations like adding, removing, and accessing elements are
    efficient and well-supported by built-in functions.
-   The behavior of vectors depends on the capabilities of their element
    type, particularly for operations like destruction and copying.
-   Strings in Move are represented as `vector<u8>`, leveraging the
    vector structure for character sequences.
-   Move provides utility functions for string manipulation, including
    conversion between `vector<u8>` and String types.

Understanding these concepts is crucial for effective programming in
Move, as they form the basis for many complex data structures and
algorithms. Proper use of vectors and strings can lead to more efficient
and maintainable code in Move-based smart contracts and applications.

# Map (Simple Map)

## Overview

`0x1::simple_map` This module provides a solution for map features. Maps
will have the following characteristics:

-   Keys point to Values: Each key is associated with a value.
-   Each key must be unique: No two keys are duplicated.
-   A Key can be found within `O(Log N)` time
-   Data is stored in order sorted by Key: Elements in maps are arranged
    based on the key.
-   Adding and removing elements takes `O(N)` time: The time to add or
    remove an element is proportional to the number of elements in the
    map.

## Example:

The code below demonstrates the usage of a SimpleMap in the Move
programming language:

1.  It defines a module called `SimpleMapType` within the `movement`
    module.
2.  The module imports necessary dependencies: `SimpleMap` from the
    `simple_map` module, `print` from the `debug` module, and `signer`
    from the standard library.
3.  A function `map_in_move` is defined that takes a signer reference as
    an argument and returns a `SimpleMap` with address keys and u64
    values.
4.  Inside `map_in_move`, a new SimpleMap is created using
    `simple_map::create()`.
5.  An element is added to the map using `simple_map::add()`, where the
    key is the signer's address and the value is 10.
6.  The function returns the created map.
7.  A test function `test_map_in_move` is defined using the `#[test]`
    attribute. It calls `map_in_move` and prints the resulting map.

This example showcases how to create, populate, and use a `SimpleMap` in
Move, demonstrating its basic operations and integration with other Move
concepts like signers and testing.

``` move
module movement::simple_map_module {
    use std::simple_map::{SimpleMap, Self};
    use std::debug::print;
    use std::signer;

    fun map_in_move(sign: &signer): SimpleMap<address, u64> {
        let mp: SimpleMap<address, u64> = simple_map::create();

        simple_map::add(&mut mp, signer::address_of(sign), 10);
        return mp
    }

    #[test(account = @0x1)]
    fun test_map_in_move(account: &signer) {
        let map = map_in_move(account);
        print(&map);
    }
}
```

-   Running test on Termial:

``` bash
aptos move test -f simple_map_module
```

``` bash
Running Move unit tests
[debug] 0x1::simple_map::SimpleMap<address, u64> {
  data: [
    0x1::simple_map::Element<address, u64> {
      key: @0x1,
      value: 10
    }
  ]
}
[ PASS    ] 0x1::simple_map_module::test_map_in_move
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

## Additional SimpleMap Functions

|                  |                                |                      |
|------------------|--------------------------------|----------------------|
| ****Function**** | ****Description****            | ****Return Value**** |
| —                | —                              | —                    |
| `length`         | Gets the number of elements    | `u64`                |
| `new`            | Creates an empty SimpleMap     | `SimpleMap<K, V>`    |
| `new_from`       | Creates from key-value vectors | `SimpleMap<K, V>`    |
| `create`         | Deprecated alias for=new=      | `SimpleMap<K, V>`    |
| `borrow`         | Borrows a value by key         | `&V`                 |
| `borrow_mut`     | Mutably borrows a value by key | `&mut V`             |
| `contains_key`   | Checks for key existence       | `bool`               |
| `destroy_empty`  | Destroys an empty map          | None                 |
| `add`            | Adds a key-value pair          | None                 |
| `add_all`        | Adds multiple key-value pairs  | None                 |
| `upsert`         | Inserts or updates a pair      | None                 |
| `keys`           | Gets all keys                  | `vector<K>`          |
| `values`         | Gets all values                | `vector<V>`          |
| `to_vec_pair`    | Converts to key-value vectors  | `(vector<K, V>)`     |
| `destroy`        | Destroys map with lambdas      | None                 |
| `remove`         | Removes and returns a pair     | `(K, V)`             |
| `find`           | Finds key index (internal)     | `Option<u64>`        |
