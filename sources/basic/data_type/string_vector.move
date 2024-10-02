module movement::vector_type {
    use std::vector;
    use std::debug;

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
        debug::print(&vec);
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

module movement::string_type {
    use std::string::{String, utf8};
    use std::debug;

    fun vec_string() {
        let vec_string: vector<u8> = b"Hello by vector u8";
        let by_string: String = utf8(b"Hello by String");
        let by_vec: String = utf8(vec_string);
        debug::print(&vec_string);
        debug::print(&by_string);
        debug::print(&by_vec);
    }

    #[test]
    fun test_vec_string() {
        vec_string()
    }
}
