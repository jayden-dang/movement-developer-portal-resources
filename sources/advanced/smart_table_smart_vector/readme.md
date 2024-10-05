# Table of Contents

- [Smart Vector](#smart-vector)
  - [Summary](#summary)
  - [Overview](#overview)
  - [Create a Smart Vector](#create-a-smart-vector)
  - [Running Test](#running-test)
  - [How Smart Vector works](#how-smart-vector-works)
  - [Additional Smart Vector
    Functions](#additional-smart-vector-functions)
- [Smart Table](#smart-table)
  - [Summary](#summary-1)
  - [Overview](#overview-1)
  - [Example](#example)
  - [Full Example](#full-example)
  - [Running Test](#running-test-1)
  - [Additional SimpleMap
    Functions](#additional-simplemap-functions)

# Smart Vector

## Summary

- Smart Vector is an advanced data structure in the Aptos Framework
  designed to optimize data management in large-scale applications.
- It combines the strengths of vectors, simple maps, and traditional
  tables while mitigating their weaknesses.
- Smart Vector uses a bucket system to efficiently store and access
  large amounts of data, potentially reducing gas fees and improving
  performance.
- The structure automatically divides elements into multiple buckets,
  optimizing both reading and writing processes.
- Smart Vector offers a solution to performance bottlenecks often
  encountered when scaling applications with conventional data
  structures.
- Implementation involves creating a SmartVector, adding elements, and
  storing it within a custom struct in the account's storage.

## Overview

As you progress beyond the foundational P0 course, you'll encounter more
complex data management challenges. While vectors and simple maps serve
well for small-scale projects, they often fall short when handling
larger datasets. To effectively scale your applications, it's crucial to
adopt more advanced data structures.

One common pitfall in software development is underestimating the
performance impact of data growth. As your application expands,
operations that were once swift on vectors and simple maps can become
significant bottlenecks, leading to increased processing time and
resource consumption.

Conventional tables present an alternative strategy, offering pinpoint
access to specific data elements. While this granular control can be
beneficial, it's essential to weigh the storage costs associated with
expanding these tables.

This is where smart tables and smart vector, a cutting-edge feature of
the Aptos Framework, come into play. These sophisticated data structures
are engineered to harness the strengths of vectors, simple maps, and
traditional tables while mitigating their weaknesses. By leveraging
smart tables & smart vector, developers can streamline data management,
potentially reducing gas fees and boosting overall system performance.

## Create a Smart Vector

```move
module movement::smart_vector_module {
    use aptos_std::smart_vector::{Self, SmartVector};

    struct MovementObject has key {
        value: SmartVector<u64>
    }

    fun init_module(caller: &signer) {
        let smartvec = smart_vector::new<u64>();
        smart_vector::push_back(&mut smartvec, 1);
        smart_vector::push_back(&mut smartvec, 2);
        smart_vector::push_back(&mut smartvec, 3);
        move_to(caller, MovementObject {
            value: smartvec
        });
    }
}
```

Certainly! I'll provide a step-by-step description of the functions used
in the smart vector module. This tutorial will break down the code and
explain each part:

1.  Module Declaration:

```move
module movement::smart_vector_module {
    // Module contents
}
```

This declares a new module named "smart~vectormodule~" within the
"movement" package.

1.  Importing the Smart Vector:

```move
use aptos_std::smart_vector::{Self, SmartVector};
```

This line imports the SmartVector type and its associated functions from
the Aptos standard library.

1.  Defining a Custom Struct:

```rust
struct MovementObject has key {
    value: SmartVector<u64>;
}
```

This defines a new struct called MovementObject with a SmartVector of
unsigned 64-bit integers (u64) as its value.

1.  Initializing the Module:

```move
fun init_module(caller: &signer) {
    // Function body
}
```

This function is called when the module is first published. It takes a
reference to the signer (account) publishing the module.

1.  Creating a New Smart Vector:

```move
let smartvec = smart_vector::new<u64>();
```

This creates a new SmartVector that will hold u64 values.

1.  Adding Elements to the Smart Vector:

```move
smart_vector::push_back(&mut smartvec, 1);
smart_vector::push_back(&mut smartvec, 2);
smart_vector::push_back(&mut smartvec, 3);
```

These lines add the values 1, 2, and 3 to the end of the SmartVector.

1.  Creating and Storing the MovementObject:

```move
move_to(caller, MovementObject {
    value: smartvec
});
```

This creates a new MovementObject with the SmartVector we just
populated, and stores it in the account's storage.

## Running Test

```move
module movement::smart_vector_module {
    use aptos_std::smart_vector::{Self, SmartVector};
    use std::debug::print;
    use std::signer::address_of;

    struct MovementObject has key {
        value: SmartVector<u64>
    }

    fun init_module(caller: &signer) {
        let smartvec = smart_vector::new<u64>();
        smart_vector::push_back(&mut smartvec, 1);
        smart_vector::push_back(&mut smartvec, 2);
        smart_vector::push_back(&mut smartvec, 3);
        move_to(caller, MovementObject {
            value: smartvec
        });
    }

    #[test_only]
    fun test_init_module(caller: &signer) {
        init_module(caller);
    }

    #[view]
    public fun get_length(addr: address): u64 acquires MovementObject {
        let vec = &borrow_global<MovementObject>(addr).value;
        smart_vector::length(vec)
    }

    #[test(caller = @0x1)]
    fun test_get_length(caller: &signer) acquires MovementObject {
        test_init_module(caller);
        let len = get_length(address_of(caller));
        print(&len);
    }
}
```

- Running test:

```bash
movement move test -f test_get_length
```

- Result:

```bash
Running Move unit tests
[debug] 3
[ PASS ] 0x5fdf6936671d4e4a89b686aff0b5a4dfe083babbaaa6e78f5daa8801f94938a6::smart_vector_module::test_get_length
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

## How Smart Vector works

If you deploy modules and create a smart vector object, you can check
the account data and you'll see an object like this:

```json
{
  "0x5fdf6936671d4e4a89b686aff0b5a4dfe083babbaaa6e78f5daa8801f94938a6::smart_vector_module::MovementObject": {
    "value": {
      "big_vec": {
        "vec": []
      },
      "bucket_size": {
        "vec": []
      },
      "inline_capacity": {
        "vec": []
      },
      "inline_vec": ["1", "2", "3"]
    }
  }
}
```

Here, the smart vector stores data in
`bucket=s, allowing it to hold a large number of elements while optimizing gas costs for users. Each =bucket`
is a standard vector that stores the elements of the smart vector.

```move
module movement::smart_vector_module {
    use aptos_std::smart_vector::{Self, SmartVector};
    use std::debug::print;
    use std::signer::address_of;

    struct MovementObject has key {
        value: SmartVector<u64>
    }

    fun init_module(caller: &signer) {
        let smartvec = smart_vector::new<u64>();
        let i = 0;
        while (i < 1000) {
            smart_vector::push_back(&mut smartvec, i);
            i = i + 1;
        };
        move_to(caller, MovementObject {
            value: smartvec
        });
    }

    #[test_only]
    fun test_init_module(caller: &signer) {
        init_module(caller);
    }

    #[view]
    public fun get_length(addr: address): u64 acquires MovementObject {
        let vec = &borrow_global<MovementObject>(addr).value;
        smart_vector::length(vec)
    }

    #[test(caller = @0x1)]
    fun test_get_length(caller: &signer) acquires MovementObject {
        test_init_module(caller);
        let len = get_length(address_of(caller));
        print(&len);
    }
}
```

In the example above, I input 1000 elements using a `while loop`. When
checking the result with the command `movement account list`, you'll see
the following output:

```json
{
  "0x696e90758094efbf0e2e9dc7fb9fbbde6c60d479bed1b1984cf62575fc864d96::smart_vector_module::MovementObject": {
    "value": {
      "big_vec": {
        "vec": [
          {
            "bucket_size": "128",
            "buckets": {
              "inner": {
                "handle": "0xfb918a6dc3e0db1a6bef0ebdf53554f0fc759c01018c5012071fe2c4a86e8b80"
              },
              "length": "8"
            },
            "end_index": "983"
          }
        ]
      },
      "bucket_size": {
        "vec": []
      },
      "inline_capacity": {
        "vec": []
      },
      "inline_vec": [
        "0",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        "10",
        "11",
        "12",
        "13",
        "14",
        "15",
        "16",
        "17"
      ]
    }
  }
},
```

Here, the smart vector automatically divides elements into multiple
buckets. For example, when you access elements from 0-100, it only
accesses the bucket containing those specific elements. This approach
optimizes both the reading and writing processes of the smart vector.

## Additional Smart Vector Functions

| Function            | Parameters                                                       | Description                                            | Return Value     |                                                                                 |                     |
| ------------------- | ---------------------------------------------------------------- | ------------------------------------------------------ | ---------------- | ------------------------------------------------------------------------------- | ------------------- | --- | --- |
| `new`               | None                                                             | Creates an empty SmartVector                           | `SmartVector<T>` |                                                                                 |                     |
| `empty`             | None                                                             | Creates an empty SmartVector (deprecated)              | `SmartVector<T>` |                                                                                 |                     |
| `empty_with_config` | `inline_capacity: u64`, `bucket_size: u64`                       | Creates an empty SmartVector with custom configuration | `SmartVector<T>` |                                                                                 |                     |
| `singleton`         | `element: T`                                                     | Creates a SmartVector with a single element            | `SmartVector<T>` |                                                                                 |                     |
| `destroy_empty`     | `self: SmartVector<T>`                                           | Destroys an empty SmartVector                          | None             |                                                                                 |                     |
| `destroy`           | `self: SmartVector<T>`                                           | Destroys a SmartVector                                 | None             |                                                                                 |                     |
| `clear`             | `self: &mut SmartVector<T>`                                      | Clears all elements from a SmartVector                 | None             |                                                                                 |                     |
| `borrow`            | `self: &SmartVector<T>`, `i: u64`                                | Borrows the i-th element                               | `&T`             |                                                                                 |                     |
| `borrow_mut`        | `self: &mut SmartVector<T>`, `i: u64`                            | Mutably borrows the i-th element                       | `&mut T`         |                                                                                 |                     |
| `append`            | `self: &mut SmartVector<T>`, `other: SmartVector<T>`             | Moves all elements from other to self                  | None             |                                                                                 |                     |
| `add_all`           | `self: &mut SmartVector<T>`, `vals: vector<T>`                   | Adds multiple values to the vector                     | None             |                                                                                 |                     |
| `to_vector`         | `self: &SmartVector<T>`                                          | Converts SmartVector to a native vector                | `vector<T>`      |                                                                                 |                     |
| `push_back`         | `self: &mut SmartVector<T>`, `val: T`                            | Adds an element to the end                             | None             |                                                                                 |                     |
| `pop_back`          | `self: &mut SmartVector<T>`                                      | Removes and returns the last element                   | `T`              |                                                                                 |                     |
| `remove`            | `self: &mut SmartVector<T>`, `i: u64`                            | Removes and returns the i-th element                   | `T`              |                                                                                 |                     |
| `swap_remove`       | `self: &mut SmartVector<T>`, `i: u64`                            | Swaps the i-th element with the last and removes it    | `T`              |                                                                                 |                     |
| `swap`              | `self: &mut SmartVector<T>`, `i: u64`, `j: u64`                  | Swaps the i-th and j-th elements                       | None             |                                                                                 |                     |
| `reverse`           | `self: &mut SmartVector<T>`                                      | Reverses the order of elements                         | None             |                                                                                 |                     |
| `index_of`          | `self: &SmartVector<T>`, `val: &T`                               | Finds the index of an element                          | `(bool, u64)`    |                                                                                 |                     |
| `contains`          | `self: &SmartVector<T>`, `val: &T`                               | Checks if an element exists                            | `bool`           |                                                                                 |                     |
| `length`            | `self: &SmartVector<T>`                                          | Returns the number of elements                         | `u64`            |                                                                                 |                     |
| `is_empty`          | `self: &SmartVector<T>`                                          | Checks if the vector is empty                          | `bool`           |                                                                                 |                     |
| `for_each`          | `self: SmartVector<T>`, `f: \                                    | T\                                                     | ~                | Applies a function to each element, consuming the vector                        | None                |
| ~for_each_reverse`  | `self: SmartVector<T>`, `f: \                                    | T\                                                     | ~                | Applies a function to each element in reverse order, consuming the vector       | None                |
| ~for_each_ref`      | `self: &SmartVector<T>`, `f: \                                   | &T\                                                    | ~                | Applies a function to a reference of each element                               | None                |
| ~for_each_mut`      | `self: &mut SmartVector<T>`, `f: \                               | &mut T\                                                | ~                | Applies a function to a mutable reference of each element                       | None                |
| ~enumerate_ref`     | `self: &SmartVector<T>`, `f: \                                   | (u64, &T)\                                             | ~                | Applies a function to each element with its index                               | None                |
| ~enumerate_mut`     |
| `foldr`             | `self: SmartVector<T>`, `init: Accumulator`, `f: \               | (T, Accumulator)\                                      | Accumulator`     | Folds the vector in reverse order into an accumulated value                     | `Accumulator`       |     |     |
| `map_ref`           | `self: &SmartVector<T1>`, `f: \                                  | &T1\                                                   | T2`              | Maps a function over references of the elements                                 | `SmartVector<T2>`   |     |     |
| `map`               | `self: SmartVector<T1>`, `f: \                                   | T1\                                                    | T2`              | Maps a function over the elements                                               | `SmartVector<T2>`   |     |     |
| `filter`            | `self: SmartVector<T>`, `p: \                                    | &T\                                                    | bool`            | Filters elements based on a predicate                                           | `SmartVector<T>`    |     |     |
| `zip`               | `self: SmartVector<T1>`, `v2: SmartVector<T2>`, `f: \            | (T1, T2)\                                              | ~                | Zips two SmartVectors and applies a function to each pair                       | None                |
| ~zip_reverse`       | `self: SmartVector<T1>`, `v2: SmartVector<T2>`, `f: \            | (T1, T2)\                                              | ~                | Zips two SmartVectors in reverse and applies a function to each pair            | None                |
| ~zip_ref`           | `self: &SmartVector<T1>`, `v2: &SmartVector<T2>`, `f: \          | (&T1, &T2)\                                            | ~                | Zips references of two SmartVectors and applies a function to each pair         | None                |
| ~zip_mut`           | `self: &mut SmartVector<T1>`, `v2: &mut SmartVector<T2>`, `f: \  | (&mut T1, &mut T2)\                                    | ~                | Zips mutable references of two SmartVectors and applies a function to each pair | None                |
| ~zip_map`           | `self: SmartVector<T1>`, `v2: SmartVector<T2>`, `f: \            | (T1, T2)\                                              | NewT`            |
| `zip_map_ref`       | `self: &SmartVector<T1>`, `v2: &SmartVector<T2>`, `f: \          | (&T1, &T2)\                                            | NewT`            | Zips references of two SmartVectors and maps a function over the pairs          | `SmartVector<NewT>` |     |     |

# Smart Table

## Summary

- Smart Table is a data structure in Move that stores data in multiple
  buckets for efficient access and gas optimization.
- It operates similarly to Smart Vector, improving speed and
  cost-efficiency in data management.
- The module demonstrates how to initialize, update, and retrieve data
  from a SmartTable.
- The code includes test functions to verify the correct operation of
  SmartTable operations.
- SmartTable uses address as keys and u64 as values in this example,
  suitable for tracking user points or balances.

## Overview

Similar to `Smart Vector`, which we explored in the previous article,
`Smart Table` operates on the same principle. Smart Table's data is
divided into multiple
`bucket=s for storage. Accessing, writing, and reading data in =Smart Table`
occurs independently within each `bucket` containing that data. This
organization improves speed and cost-efficiency while optimizing gas
usage for users.

## Example

```move
module movement::smart_table_module {
    use aptos_std::smart_table::{Self, SmartTable};

    struct MovementTableObject has key {
        value: SmartTable<address, u64>
    }

    fun init_module(caller: &signer) {
        let val = smart_table::new<address, u64>();
        smart_table::add(&mut val, address_of(caller), 0);
        move_to(caller, MovementTableObject {
            value: val
        });
    }
}
```

Let's break down the code and explain each function step-by-step:

### 1. Module Declaration

```move
module movement::smart_table_module {
    // Module contents
}
```

This declares a new module named "smart~tablemodule~" under the
"movement" address.

### 2. Importing Required Modules

```move
use aptos_std::smart_table::{Self, SmartTable};
```

This imports the SmartTable type and its associated functions from the
aptos~std~ library.

### 3. Defining a Custom Struct

```rust
struct MovementTableObject has key {
    value: SmartTable<address, u64>
}
```

This defines a new struct called MovementTableObject that contains a
SmartTable. The SmartTable uses address as keys and u64 as values.

### 4. Initialization Function

```move
fun init_module(caller: &signer) {
    // Function body
}
```

This function is called when the module is published. It takes a
reference to the signer (the account publishing the module) as an
argument.

### 5. Creating a New SmartTable

```move
let val = smart_table::new<address, u64>();
```

This creates a new SmartTable that uses address as keys and u64 as
values.

### 6. Adding an Initial Entry

```move
smart_table::add(&mut val, address_of(caller), 0);
```

This adds an initial entry to the SmartTable. The key is the address of
the caller, and the value is 0.

### 7. Moving the SmartTable to Storage

```move
move_to(caller, MovementTableObject {
    value: val
});
```

This creates a new MovementTableObject with the SmartTable we just
created and moves it to the storage of the caller's account. This
initialization sets up a SmartTable in the caller's account, ready to be
used for storing and managing data efficiently.

## Full Example

```move
module movement::smart_table_module {
    use aptos_std::smart_table::{Self, SmartTable};
    use std::debug::print;
    use std::signer::address_of;

    struct MovementTableObject has key {
        value: SmartTable<address, u64>
    }

    fun init_module(caller: &signer) {
        let val = smart_table::new<address, u64>();
        smart_table::add(&mut val, address_of(caller), 0);
        move_to(caller, MovementTableObject {
            value: val
        });
    }

    #[test_only]
    fun test_init_module(caller: &signer) {
        init_module(caller);
    }

    #[view]
    fun get_amount_point(addr: address): u64 acquires MovementTableObject {
        let table = &borrow_global<MovementTableObject>(addr).value;
        *smart_table::borrow(table, addr)
    }

    fun plus_point(addr: address, value: u64) acquires MovementTableObject {
        let table = &mut borrow_global_mut<MovementTableObject>(addr).value;
        let point = *smart_table::borrow_mut(table, addr);
        point = point + value;
        smart_table::upsert(table, addr, point);
    }

    #[test(caller = @0x1)]
    fun test_get_amount_point(caller: &signer) acquires MovementTableObject {
        test_init_module(caller);
        let amount = get_amount_point(address_of(caller));
        print(&amount);
    }

    #[test(caller = @0x1)]
    fun test_plus_amount_point(caller: &signer) acquires MovementTableObject {
        test_init_module(caller);
        plus_point(address_of(caller), 10);
        let amount = get_amount_point(address_of(caller));
        print(&amount);
    }
}
```

Certainly! I'll provide a step-by-step description of the functions in
the Smart Table module for a tutorial. Let's break down each function:

### 1. init~module~(caller: &signer)

This function initializes the module when it's published:

- Create a new SmartTable using `smart_table::new<address, u64>()`
- Add an initial entry to the table with the caller's address as the
  key and 0 as the value
- Create a new MovementTableObject with the SmartTable and move it to
  the caller's storage

### 2. test~initmodule~(caller: &signer)

This is a test-only function that calls init~module~:

- It's annotated with `#[test_only]`, meaning it's only used for
  testing
- It simply calls the init~module~ function with the provided caller

### 3. get~amountpoint~(addr: address): u64

This function retrieves the point amount for a given address:

- It's annotated with `#[view]`, indicating it's a read-only function
- Borrow the SmartTable from the MovementTableObject stored at the
  given address
- Use `smart_table::borrow` to get the value associated with the
  address
- Return the borrowed value (point amount)

### 4. plus~point~(addr: address, value: u64)

This function adds points to a given address:

- Borrow the SmartTable mutably from the MovementTableObject
- Get the current point value for the address using
  `smart_table::borrow_mut`
- Add the new value to the current point
- Update the SmartTable with the new point value using
  `smart_table::upsert`

### 5. test~getamountpoint~(caller: &signer)

This is a test function for get~amountpoint~:

- It's annotated with `#[test(caller = @0x1)]`, setting up a test
  environment
- Call test~initmodule~ to set up the initial state
- Call get~amountpoint~ with the caller's address
- Print the retrieved amount

### 6. test~plusamountpoint~(caller: &signer)

This is a test function for plus~point~:

- It's also annotated with `#[test(caller = @0x1)]`
- Call test~initmodule~ to set up the initial state
- Call plus~point~ to add 10 points to the caller's address
- Call get~amountpoint~ to retrieve the updated point amount
- Print the new amount

These functions demonstrate how to initialize, update, and retrieve data
from a SmartTable, as well as how to set up tests for these operations.

## Running Test

\> Running test:

```bash
movement move test -f smart_table_module
```

\> Result:

```bash
Running Move unit tests
[debug] 0
[ PASS ] 0x696e90758094efbf0e2e9dc7fb9fbbde6c60d479bed1b1984cf62575fc864d96::smart_table_module::test_get_amount_point
[debug] 10
[ PASS ] 0x696e90758094efbf0e2e9dc7fb9fbbde6c60d479bed1b1984cf62575fc864d96::smart_table_module::test_plus_amount_point
Test result: OK. Total tests: 2; passed: 2; failed: 0
{
  "Result": "Success"
}
```

## Additional SimpleMap Functions

| Function                      | Parameters                                                                                                    | Description                                                                               | Return Value                                     |                                                                  |                     |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- | ------------------------------------------------ | ---------------------------------------------------------------- | ------------------- | --- | --- |
| `new`                         | None                                                                                                          | Creates an empty SmartTable with default configurations                                   | `SmartTable<K, V>`                               |                                                                  |                     |
| `new_with_config`             | `num_initial_buckets: u64`, `split_load_threshold: u8`, `target_bucket_size: u64`                             | Creates an empty SmartTable with customized configurations                                | `SmartTable<K, V>`                               |                                                                  |                     |
| `destroy_empty`               | `self: SmartTable<K, V>`                                                                                      | Destroys an empty table                                                                   | None                                             |                                                                  |                     |
| `destroy`                     | `self: SmartTable<K, V>`                                                                                      | Destroys a table completely when V has `drop`                                             | None                                             |                                                                  |                     |
| `clear`                       | `self: &mut SmartTable<K, V>`                                                                                 | Clears a table completely when T has `drop`                                               | None                                             |                                                                  |                     |
| `add`                         | `self: &mut SmartTable<K, V>`, `key: K`, `value: V`                                                           | Adds a key-value pair to the table                                                        | None                                             |                                                                  |                     |
| `add_all`                     | `self: &mut SmartTable<K, V>`, `keys: vector<K>`, `values: vector<V>`                                         | Adds multiple key-value pairs to the table                                                | None                                             |                                                                  |                     |
| `unzip_entries`               | `entries: &vector<Entry<K, V>>`                                                                               | Unzips entries into separate key and value vectors                                        | `(vector<K>, vector<V>)`                         |                                                                  |                     |
| `to_simple_map`               | `self: &SmartTable<K, V>`                                                                                     | Converts a smart table to a simple~map~                                                   | `SimpleMap<K, V>`                                |                                                                  |                     |
| `keys`                        | `self: &SmartTable<K, V>`                                                                                     | Gets all keys in a smart table                                                            | `vector<K>`                                      |                                                                  |                     |
| `keys_paginated`              | `self: &SmartTable<K, V>`, `starting_bucket_index: u64`, `starting_vector_index: u64`, `num_keys_to_get: u64` | Gets keys from a smart table, paginated                                                   | `(vector<K>, Option<u64>, Option<u64>)`          |                                                                  |                     |
| `split_one_bucket`            | `self: &mut SmartTable<K, V>`                                                                                 | Splits one bucket into two                                                                | None                                             |                                                                  |                     |
| `bucket_index`                | `level: u8`, `num_buckets: u64`, `hash: u64`                                                                  | Returns the expected bucket index for a hash                                              | `u64`                                            |                                                                  |                     |
| `borrow`                      | `self: &SmartTable<K, V>`, `key: K`                                                                           | Borrows an immutable reference to the value associated with the key                       | `&V`                                             |                                                                  |                     |
| `borrow_with_default`         | `self: &SmartTable<K, V>`, `key: K`, `default: &V`                                                            | Borrows an immutable reference to the value, or returns the default if key not found      | `&V`                                             |                                                                  |                     |
| `borrow_mut`                  | `self: &mut SmartTable<K, V>`, `key: K`                                                                       | Borrows a mutable reference to the value associated with the key                          | `&mut V`                                         |                                                                  |                     |
| `borrow_mut_with_default`     | `self: &mut SmartTable<K, V>`, `key: K`, `default: V`                                                         | Borrows a mutable reference to the value, or inserts and returns default if key not found | `&mut V`                                         |                                                                  |                     |
| `contains`                    | `self: &SmartTable<K, V>`, `key: K`                                                                           | Checks if the table contains a key                                                        | `bool`                                           |                                                                  |                     |
| `remove`                      | `self: &mut SmartTable<K, V>`, `key: K`                                                                       | Removes and returns the value associated with the key                                     | `V`                                              |                                                                  |                     |
| `upsert`                      | `self: &mut SmartTable<K, V>`, `key: K`, `value: V`                                                           | Inserts a key-value pair or updates an existing one                                       | None                                             |                                                                  |                     |
| `length`                      | `self: &SmartTable<K, V>`                                                                                     | Returns the number of entries in the table                                                | `u64`                                            |                                                                  |                     |
| `load_factor`                 | `self: &SmartTable<K, V>`                                                                                     | Returns the load factor of the hashtable                                                  | `u64`                                            |                                                                  |                     |
| `update_split_load_threshold` | `self: &mut SmartTable<K, V>`, `split_load_threshold: u8`                                                     | Updates the split load threshold                                                          | None                                             |                                                                  |                     |
| `update_target_bucket_size`   | `self: &mut SmartTable<K, V>`, `target_bucket_size: u64`                                                      | Updates the target bucket size                                                            | None                                             |                                                                  |                     |
| `for_each_ref`                | `self: &SmartTable<K, V>`, `f: \                                                                              | &K, &V\                                                                                   | ~                                                | Applies a function to a reference of each key-value pair         | None                |
| ~for_each_mut`                | `self: &mut SmartTable<K, V>`, `f: \                                                                          | &K, &mut V\                                                                               | ~                                                | Applies a function to a mutable reference of each key-value pair | None                |
| ~map_ref`                     | `self: &SmartTable<K, V1>`, `f: \                                                                             | &V1\                                                                                      | V2`                                              | Maps a function over the values, producing a new SmartTable      | `SmartTable<K, V2>` |
| `any`                         | `self: &SmartTable<K, V>`, `p: \                                                                              | &K, &V\                                                                                   | bool`                                            | Checks if any key-value pair satisfies the predicate             | `bool`              |     |     |
| `borrow_kv`                   | `self: &Entry<K, V>`                                                                                          | Borrows references to the key and value of an entry                                       | `(&K, &V)`                                       |                                                                  |                     |
| `borrow_kv_mut`               | `self: &mut Entry<K, V>`                                                                                      | Borrows mutable references to the key and value of an entry                               | `(&mut K, &mut V)`                               |                                                                  |                     |
| `num_buckets`                 | `self: &SmartTable<K, V>`                                                                                     | Returns the number of buckets in the table                                                | `u64`                                            |                                                                  |                     |
| `borrow_buckets`              | `self: &SmartTable<K, V>`                                                                                     | Borrows a reference to the buckets of the table                                           | `&TableWithLength<u64, vector<Entry<K, V>>>`     |                                                                  |                     |
| `borrow_buckets_mut`          | `self: &mut SmartTable<K, V>`                                                                                 | Borrows a mutable reference to the buckets of the table                                   | `&mut TableWithLength<u64, vector<Entry<K, V>>>` |                                                                  |                     |
